import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/track.dart';
import '../blocs/player/player_bloc.dart';
import '../blocs/player/player_state.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  final VoidCallback? onPlayTap;

  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, playerState) {
        final isCurrentTrack = playerState.currentTrack?.id == track.id;
        final isPlaying = isCurrentTrack && playerState.isPlaying;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: track.albumCover != null
                    ? Image.network(
                        track.albumCover!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        cacheWidth: 96,
                        cacheHeight: 96,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              if (isCurrentTrack)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Icon(
                        isPlaying
                            ? Icons.equalizer
                            : Icons.pause,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isCurrentTrack ? AppColors.accent : AppColors.white,
            ),
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  track.artistName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ID: ${track.id}',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.grey.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    track.formattedDuration,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              if (onPlayTap != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onPlayTap,
                  icon: const Icon(
                    Icons.play_circle_filled,
                    color: AppColors.accent,
                    size: 32,
                  ),
                ),
              ],
            ],
          ),
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.surfaceLight,
      child: const Icon(
        Icons.music_note,
        color: AppColors.greyDark,
      ),
    );
  }
}
