import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/track.dart';
import 'album_card.dart';

class HorizontalSection extends StatelessWidget {
  final String title;
  final List<Track> tracks;
  final void Function(Track)? onTrackTap;
  final VoidCallback? onSeeAllTap;
  final double itemSize;

  const HorizontalSection({
    super.key,
    required this.title,
    required this.tracks,
    this.onTrackTap,
    this.onSeeAllTap,
    this.itemSize = 150,
  });

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAllTap != null)
                TextButton(
                  onPressed: onSeeAllTap,
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: itemSize + 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tracks.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final track = tracks[index];
              return AlbumCard(
                track: track,
                size: itemSize,
                onTap: () => onTrackTap?.call(track),
              );
            },
          ),
        ),
      ],
    );
  }
}
