import 'package:equatable/equatable.dart';

import '../../../domain/entities/track.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {
  const LibraryInitial();
}

class LibraryLoading extends LibraryState {
  const LibraryLoading();
}

class LibraryLoaded extends LibraryState {
  final List<Track> tracks;
  final Map<String, List<Track>> groupedTracks;
  final bool hasMore;
  final String currentQuery;
  final bool isLoadingMore;
  final String? searchQuery;
  final String? filterLetter;

  const LibraryLoaded({
    required this.tracks,
    required this.groupedTracks,
    required this.hasMore,
    required this.currentQuery,
    this.isLoadingMore = false,
    this.searchQuery,
    this.filterLetter,
  });

  LibraryLoaded copyWith({
    List<Track>? tracks,
    Map<String, List<Track>>? groupedTracks,
    bool? hasMore,
    String? currentQuery,
    bool? isLoadingMore,
    String? searchQuery,
    String? filterLetter,
  }) {
    return LibraryLoaded(
      tracks: tracks ?? this.tracks,
      groupedTracks: groupedTracks ?? this.groupedTracks,
      hasMore: hasMore ?? this.hasMore,
      currentQuery: currentQuery ?? this.currentQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      filterLetter: filterLetter ?? this.filterLetter,
    );
  }

  @override
  List<Object?> get props => [
        tracks,
        groupedTracks,
        hasMore,
        currentQuery,
        isLoadingMore,
        searchQuery,
        filterLetter,
      ];
}

class LibraryError extends LibraryState {
  final String message;
  final List<Track>? previousTracks;

  const LibraryError({
    required this.message,
    this.previousTracks,
  });

  @override
  List<Object?> get props => [message, previousTracks];
}
