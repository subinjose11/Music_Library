import '../../domain/entities/track.dart';

class TrackModel extends Track {
  const TrackModel({
    required super.id,
    required super.title,
    required super.artistName,
    required super.albumName,
    required super.duration,
    super.previewUrl,
    super.albumCover,
  });

  /// Parse from Deezer API response
  factory TrackModel.fromJson(Map<String, dynamic> json) {
    final artist = json['artist'] as Map<String, dynamic>?;
    final album = json['album'] as Map<String, dynamic>?;

    return TrackModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Unknown Title',
      artistName: artist?['name'] as String? ?? 'Unknown Artist',
      albumName: album?['title'] as String? ?? 'Unknown Album',
      duration: json['duration'] as int? ?? 0,
      previewUrl: json['preview'] as String?,
      albumCover: _extractArtwork(album),
    );
  }

  static String? _extractArtwork(Map<String, dynamic>? album) {
    if (album == null) return null;
    // Deezer provides: cover_small, cover_medium, cover_big, cover_xl
    return album['cover_xl'] as String? ??
        album['cover_big'] as String? ??
        album['cover_medium'] as String?;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': {'name': artistName},
      'album': {'title': albumName, 'cover_xl': albumCover},
      'duration': duration,
      'preview': previewUrl,
    };
  }

  Track toEntity() {
    return Track(
      id: id,
      title: title,
      artistName: artistName,
      albumName: albumName,
      duration: duration,
      previewUrl: previewUrl,
      albumCover: albumCover,
    );
  }
}
