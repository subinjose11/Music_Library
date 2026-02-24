import 'package:equatable/equatable.dart';

class Track extends Equatable {
  final int id;
  final String title;
  final String artistName;
  final String albumName;
  final int duration;
  final String? previewUrl;
  final String? albumCover;

  const Track({
    required this.id,
    required this.title,
    required this.artistName,
    required this.albumName,
    required this.duration,
    this.previewUrl,
    this.albumCover,
  });

  String get firstLetter {
    if (title.isEmpty) return '#';
    final first = title[0].toUpperCase();
    if (RegExp(r'[A-Z]').hasMatch(first)) {
      return first;
    }
    if (RegExp(r'[0-9]').hasMatch(first)) {
      return '0-9';
    }
    return '#';
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artistName,
        albumName,
        duration,
        previewUrl,
        albumCover,
      ];
}
