import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MusicCategory {
  final String name;
  final Color color;

  const MusicCategory({required this.name, required this.color});

  static const List<MusicCategory> defaultCategories = [
    MusicCategory(name: 'Pop', color: Color(0xFFE13300)),
    MusicCategory(name: 'Hip-Hop', color: Color(0xFFBA5D07)),
    MusicCategory(name: 'Rock', color: Color(0xFF8400E7)),
    MusicCategory(name: 'R&B', color: Color(0xFF1E3264)),
    MusicCategory(name: 'Electronic', color: Color(0xFF148A08)),
    MusicCategory(name: 'Jazz', color: Color(0xFF509BF5)),
    MusicCategory(name: 'Classical', color: Color(0xFFAF2896)),
    MusicCategory(name: 'Country', color: Color(0xFFE8115B)),
    MusicCategory(name: 'Latin', color: Color(0xFFDC148C)),
    MusicCategory(name: 'Indie', color: Color(0xFF477D95)),
    MusicCategory(name: 'Metal', color: Color(0xFF503750)),
    MusicCategory(name: 'Folk', color: Color(0xFF1DB954)),
  ];
}
