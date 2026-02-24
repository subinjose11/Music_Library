import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class StickyHeader extends StatelessWidget {
  final String letter;
  final int trackCount;

  const StickyHeader({
    super.key,
    required this.letter,
    required this.trackCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.surface,
      child: Row(
        children: [
          Text(
            letter,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($trackCount)',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String letter;
  final int trackCount;

  StickyHeaderDelegate({
    required this.letter,
    required this.trackCount,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return StickyHeader(
      letter: letter,
      trackCount: trackCount,
    );
  }

  @override
  double get maxExtent => 32;

  @override
  double get minExtent => 32;

  @override
  bool shouldRebuild(covariant StickyHeaderDelegate oldDelegate) {
    return letter != oldDelegate.letter || trackCount != oldDelegate.trackCount;
  }
}
