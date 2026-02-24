import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/track.dart';
import '../blocs/library/library_bloc.dart';
import '../blocs/library/library_event.dart';
import '../blocs/library/library_state.dart';
import '../blocs/player/player_bloc.dart';
import '../blocs/player/player_event.dart';
import '../widgets/track_tile.dart';
import '../widgets/sticky_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/no_internet_widget.dart';
import 'track_details_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial tracks
    context.read<LibraryBloc>().add(const LoadInitialTracks());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      context.read<LibraryBloc>().add(const LoadMoreTracks());
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger at 80% of scroll
    return currentScroll >= maxScroll * 0.8;
  }

  void _onTrackTap(Track track) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TrackDetailsScreen(track: track),
      ),
    );
  }

  void _onPlayTrack(Track track) {
    context.read<PlayerBloc>().add(PlayTrack(track));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Your Library',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TrackSearchBar(
              onSearch: (query) {
                context.read<LibraryBloc>().add(SearchTracks(query));
              },
              onClear: () {
                context.read<LibraryBloc>().add(const ClearSearch());
              },
            ),
            Expanded(
              child: BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  if (state is LibraryInitial) {
                    return const Center(
                      child: Text(
                        'Welcome to Music Library',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    );
                  }

                  if (state is LibraryLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                      ),
                    );
                  }

                  if (state is LibraryError) {
                    if (state.message == 'NO INTERNET CONNECTION') {
                      return NoInternetWidget(
                        message: state.message,
                        onRetry: () {
                          context.read<LibraryBloc>().add(const LoadInitialTracks());
                        },
                      );
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.message,
                            style: const TextStyle(color: AppColors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<LibraryBloc>().add(const LoadInitialTracks());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is LibraryLoaded) {
                    if (state.tracks.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tracks found',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      );
                    }

                    return _buildTrackList(state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackList(LibraryLoaded state) {
    // Build flat list with headers for virtualization
    final items = <_ListItem>[];

    for (final entry in state.groupedTracks.entries) {
      items.add(_HeaderItem(letter: entry.key, count: entry.value.length));
      for (final track in entry.value) {
        items.add(_TrackItem(track: track));
      }
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          itemCount: items.length + (state.hasMore ? 1 : 0),
          // Use fixed extent for better performance
          itemBuilder: (context, index) {
            if (index >= items.length) {
              // Loading indicator at the end
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                  ),
                ),
              );
            }

            final item = items[index];
            if (item is _HeaderItem) {
              return StickyHeader(
                letter: item.letter,
                trackCount: item.count,
              );
            } else if (item is _TrackItem) {
              return TrackTile(
                track: item.track,
                onTap: () => _onTrackTap(item.track),
                onPlayTap: () => _onPlayTrack(item.track),
              );
            }
            return const SizedBox.shrink();
          },
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
        ),
        // Track count indicator
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${state.tracks.length} tracks',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        // Loading more indicator
        if (state.isLoadingMore)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Loading more...',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Helper classes for list items
abstract class _ListItem {}

class _HeaderItem extends _ListItem {
  final String letter;
  final int count;

  _HeaderItem({required this.letter, required this.count});
}

class _TrackItem extends _ListItem {
  final Track track;

  _TrackItem({required this.track});
}
