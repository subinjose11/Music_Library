import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/track.dart';
import '../../../domain/repositories/music_repository.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final MusicRepository repository;

  // Track loading state
  final List<Track> _allTracks = [];
  int _currentQueryIndex = 0;
  int _currentOffset = 0;
  bool _hasMoreData = true;
  StreamSubscription<bool>? _connectivitySubscription;

  LibraryBloc({required this.repository}) : super(const LibraryInitial()) {
    on<LoadInitialTracks>(_onLoadInitialTracks);
    on<LoadMoreTracks>(_onLoadMoreTracks);
    on<SearchTracks>(_onSearchTracks);
    on<FilterByLetter>(_onFilterByLetter);
    on<ClearSearch>(_onClearSearch);
    on<ConnectivityChanged>(_onConnectivityChanged);

    // Listen to connectivity changes (handle gracefully if plugin not available)
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    try {
      _connectivitySubscription = repository.onConnectivityChanged.listen(
        (isConnected) => add(ConnectivityChanged(isConnected)),
        onError: (error) {
          // Connectivity plugin not available, ignore
        },
      );
    } catch (e) {
      // Connectivity plugin not available on this platform
    }
  }

  String get _currentQuery {
    if (_currentQueryIndex < ApiConstants.queryTerms.length) {
      return ApiConstants.queryTerms[_currentQueryIndex];
    }
    return '';
  }

  Map<String, List<Track>> _groupTracksByLetter(List<Track> tracks) {
    final grouped = <String, List<Track>>{};
    for (final track in tracks) {
      final letter = track.firstLetter;
      grouped.putIfAbsent(letter, () => []).add(track);
    }
    // Sort keys alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (var key in sortedKeys) key: grouped[key]!};
  }

  Future<void> _onLoadInitialTracks(
    LoadInitialTracks event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoading());

    try {
      _allTracks.clear();
      _currentQueryIndex = 0;
      _currentOffset = 0;
      _hasMoreData = true;

      final tracks = await repository.searchTracks(
        query: _currentQuery,
        index: 0,
        limit: ApiConstants.pageSize,
      );

      _allTracks.addAll(tracks);
      _currentOffset = tracks.length;

      // Check if we need to load more queries
      if (tracks.length < ApiConstants.pageSize) {
        _currentQueryIndex++;
        _currentOffset = 0;
      }

      emit(LibraryLoaded(
        tracks: List.unmodifiable(_allTracks),
        groupedTracks: _groupTracksByLetter(_allTracks),
        hasMore: _hasMoreData,
        currentQuery: _currentQuery,
      ));
    } on NetworkException catch (e) {
      emit(LibraryError(message: e.message));
    } catch (e) {
      emit(LibraryError(message: 'Failed to load tracks: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMoreTracks(
    LoadMoreTracks event,
    Emitter<LibraryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LibraryLoaded || currentState.isLoadingMore) {
      return;
    }

    if (!_hasMoreData) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final tracks = await repository.searchTracks(
        query: _currentQuery,
        index: _currentOffset,
        limit: ApiConstants.pageSize,
      );

      if (tracks.isEmpty) {
        // Move to next query term
        _currentQueryIndex++;
        _currentOffset = 0;

        // Check if we've exhausted all queries
        if (_currentQueryIndex >= ApiConstants.queryTerms.length) {
          _hasMoreData = false;
        }
      } else {
        // Add only unique tracks (by ID)
        final existingIds = _allTracks.map((t) => t.id).toSet();
        final uniqueTracks =
            tracks.where((t) => !existingIds.contains(t.id)).toList();
        _allTracks.addAll(uniqueTracks);
        _currentOffset += tracks.length;

        // If we got less than page size, move to next query
        if (tracks.length < ApiConstants.pageSize) {
          _currentQueryIndex++;
          _currentOffset = 0;
        }
      }

      emit(LibraryLoaded(
        tracks: List.unmodifiable(_allTracks),
        groupedTracks: _groupTracksByLetter(_allTracks),
        hasMore: _hasMoreData,
        currentQuery: _currentQuery,
        isLoadingMore: false,
        searchQuery: currentState.searchQuery,
        filterLetter: currentState.filterLetter,
      ));
    } on NetworkException catch (e) {
      emit(LibraryError(
        message: e.message,
        previousTracks: _allTracks,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onSearchTracks(
    SearchTracks event,
    Emitter<LibraryState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      add(const ClearSearch());
      return;
    }

    // First, filter local tracks for instant results
    final localResults = _allTracks
        .where((track) =>
            track.title.toLowerCase().contains(query.toLowerCase()) ||
            track.artistName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    emit(LibraryLoaded(
      tracks: localResults,
      groupedTracks: _groupTracksByLetter(localResults),
      hasMore: true,
      currentQuery: query,
      searchQuery: query,
    ));

    // Then fetch from API for more results
    try {
      final apiResults = await repository.searchTracks(
        query: query,
        index: 0,
        limit: ApiConstants.pageSize * 2,
      );

      // Combine local and API results, removing duplicates
      final existingIds = localResults.map((t) => t.id).toSet();
      final combinedResults = [
        ...localResults,
        ...apiResults.where((t) => !existingIds.contains(t.id)),
      ];

      emit(LibraryLoaded(
        tracks: combinedResults,
        groupedTracks: _groupTracksByLetter(combinedResults),
        hasMore: false,
        currentQuery: query,
        searchQuery: query,
      ));
    } on NetworkException catch (e) {
      // Keep local results but show error
      if (localResults.isEmpty) {
        emit(LibraryError(message: e.message));
      }
    } catch (e) {
      // Keep local results on error
    }
  }

  Future<void> _onFilterByLetter(
    FilterByLetter event,
    Emitter<LibraryState> emit,
  ) async {
    final filteredTracks =
        _allTracks.where((track) => track.firstLetter == event.letter).toList();

    emit(LibraryLoaded(
      tracks: filteredTracks,
      groupedTracks: _groupTracksByLetter(filteredTracks),
      hasMore: false,
      currentQuery: _currentQuery,
      filterLetter: event.letter,
    ));
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<LibraryState> emit,
  ) {
    emit(LibraryLoaded(
      tracks: List.unmodifiable(_allTracks),
      groupedTracks: _groupTracksByLetter(_allTracks),
      hasMore: _hasMoreData,
      currentQuery: _currentQuery,
    ));
  }

  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<LibraryState> emit,
  ) {
    if (!event.isConnected) {
      final currentState = state;
      if (currentState is LibraryLoaded) {
        emit(LibraryError(
          message: 'NO INTERNET CONNECTION',
          previousTracks: currentState.tracks,
        ));
      } else {
        emit(const LibraryError(message: 'NO INTERNET CONNECTION'));
      }
    } else {
      // Reconnected - reload if we were in error state
      final currentState = state;
      if (currentState is LibraryError && currentState.previousTracks != null) {
        emit(LibraryLoaded(
          tracks: currentState.previousTracks!,
          groupedTracks: _groupTracksByLetter(currentState.previousTracks!),
          hasMore: _hasMoreData,
          currentQuery: _currentQuery,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
