import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../domain/entities/track.dart';
import '../blocs/player/player_bloc.dart';
import '../blocs/player/player_event.dart';
import '../blocs/track_details/track_details_bloc.dart';
import '../blocs/track_details/track_details_event.dart';
import '../blocs/track_details/track_details_state.dart';
import '../widgets/no_internet_widget.dart';

class TrackDetailsScreen extends StatelessWidget {
  final Track track;

  const TrackDetailsScreen({
    super.key,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TrackDetailsBloc>()
        ..add(LoadTrackDetails(
          trackId: track.id,
          trackName: track.title,
          artistName: track.artistName,
          albumName: track.albumName,
          duration: track.duration,
        )),
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.read<PlayerBloc>().add(PlayTrack(track));
          },
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play'),
        ),
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: BlocBuilder<TrackDetailsBloc, TrackDetailsState>(
                builder: (context, state) {
                  if (state is TrackDetailsLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
                    );
                  }

                  if (state is TrackDetailsError) {
                    if (state.message == 'NO INTERNET CONNECTION') {
                      return NoInternetWidget(
                        message: state.message,
                        onRetry: () {
                          context.read<TrackDetailsBloc>().add(LoadTrackDetails(
                                trackId: track.id,
                                trackName: track.title,
                                artistName: track.artistName,
                                albumName: track.albumName,
                                duration: track.duration,
                              ));
                        },
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.grey),
                        ),
                      ),
                    );
                  }

                  if (state is TrackDetailsLoaded) {
                    return _buildTrackDetails(context, state);
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

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          track.title,
          style: const TextStyle(
            color: AppColors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 4,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (track.albumCover != null)
              Image.network(
                track.albumCover!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderImage(),
              )
            else
              _buildPlaceholderImage(),
            // Gradient overlay for better text visibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 100,
          color: AppColors.greyDark,
        ),
      ),
    );
  }

  Widget _buildTrackDetails(BuildContext context, TrackDetailsLoaded state) {
    final detailedTrack = state.track;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Track Info Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context,
                    icon: Icons.person,
                    label: 'Artist',
                    value: detailedTrack.artistName,
                  ),
                  const Divider(color: AppColors.surfaceLight),
                  _buildInfoRow(
                    context,
                    icon: Icons.album,
                    label: 'Album',
                    value: detailedTrack.albumName,
                  ),
                  const Divider(color: AppColors.surfaceLight),
                  _buildInfoRow(
                    context,
                    icon: Icons.timer,
                    label: 'Duration',
                    value: detailedTrack.formattedDuration,
                  ),
                  const Divider(color: AppColors.surfaceLight),
                  _buildInfoRow(
                    context,
                    icon: Icons.tag,
                    label: 'Track ID',
                    value: detailedTrack.id.toString(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Lyrics Section
          const Text(
            'Lyrics',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          if (state.isLoadingLyrics)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              ),
            )
          else if (state.lyrics != null && state.lyrics!.hasLyrics)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(
                  state.lyrics!.displayLyrics,
                  style: const TextStyle(
                    color: AppColors.white,
                    height: 1.8,
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.lyrics_outlined,
                        size: 48,
                        color: AppColors.greyDark,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No lyrics available',
                        style: TextStyle(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.accent,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
