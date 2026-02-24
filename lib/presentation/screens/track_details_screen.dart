import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection_container.dart';
import '../../domain/entities/track.dart';
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
                        child: CircularProgressIndicator(),
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
                        child: Text(state.message),
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
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          track.title,
          style: const TextStyle(
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
                    Colors.black54,
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
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 100,
          color: Colors.white24,
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
          Card(
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
                  const Divider(),
                  _buildInfoRow(
                    context,
                    icon: Icons.album,
                    label: 'Album',
                    value: detailedTrack.albumName,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    icon: Icons.timer,
                    label: 'Duration',
                    value: detailedTrack.formattedDuration,
                  ),
                  const Divider(),
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
          Text(
            'Lyrics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          if (state.isLoadingLyrics)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.lyrics != null && state.lyrics!.hasLyrics)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectableText(
                  state.lyrics!.displayLyrics,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.8,
                      ),
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.lyrics_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No lyrics available',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 32),
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
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
