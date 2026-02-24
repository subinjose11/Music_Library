import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../blocs/player/player_bloc.dart';
import '../blocs/player/player_event.dart';
import '../blocs/player/player_state.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        if (!state.hasTrack) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'No track playing',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.white,
                          size: 32,
                        ),
                      ),
                      const Text(
                        'Now Playing',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Album art
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: state.currentTrack!.albumCover != null
                              ? Image.network(
                                  state.currentTrack!.albumCover!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
                        ),
                      ),
                    ),
                  ),
                ),
                // Track info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        state.currentTrack!.title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.currentTrack!.artistName,
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                        ),
                        child: Slider(
                          value: state.progress.clamp(0.0, 1.0),
                          onChanged: (value) {
                            final position = Duration(
                              milliseconds:
                                  (value * state.duration.inMilliseconds)
                                      .round(),
                            );
                            context.read<PlayerBloc>().add(SeekTo(position));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.positionText,
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              state.durationText,
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Playback controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Shuffle button
                      IconButton(
                        onPressed: () {
                          context.read<PlayerBloc>().add(const ToggleShuffle());
                        },
                        icon: Icon(
                          Icons.shuffle,
                          color: state.isShuffleEnabled
                              ? AppColors.accent
                              : AppColors.grey,
                        ),
                      ),
                      // Previous button
                      IconButton(
                        onPressed: state.hasPrevious ||
                                state.position.inSeconds > 3
                            ? () {
                                context
                                    .read<PlayerBloc>()
                                    .add(const PlayPrevious());
                              }
                            : null,
                        icon: Icon(
                          Icons.skip_previous,
                          color: state.hasPrevious ||
                                  state.position.inSeconds > 3
                              ? AppColors.white
                              : AppColors.greyDark,
                          size: 40,
                        ),
                      ),
                      // Play/Pause button
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (state.isPlaying) {
                              context
                                  .read<PlayerBloc>()
                                  .add(const PauseTrack());
                            } else {
                              context
                                  .read<PlayerBloc>()
                                  .add(const ResumeTrack());
                            }
                          },
                          icon: Icon(
                            state.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: AppColors.background,
                            size: 40,
                          ),
                        ),
                      ),
                      // Next button
                      IconButton(
                        onPressed: state.hasNext
                            ? () {
                                context
                                    .read<PlayerBloc>()
                                    .add(const PlayNext());
                              }
                            : null,
                        icon: Icon(
                          Icons.skip_next,
                          color: state.hasNext
                              ? AppColors.white
                              : AppColors.greyDark,
                          size: 40,
                        ),
                      ),
                      // Repeat button
                      IconButton(
                        onPressed: () {
                          context.read<PlayerBloc>().add(const ToggleRepeat());
                        },
                        icon: Icon(
                          state.repeatMode == RepeatMode.one
                              ? Icons.repeat_one
                              : Icons.repeat,
                          color: state.repeatMode != RepeatMode.off
                              ? AppColors.accent
                              : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
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
}
