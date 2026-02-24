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

  /// Parse from iTunes Search API response
  factory TrackModel.fromJson(Map<String, dynamic> json) {
    // Duration is in milliseconds from iTunes, convert to seconds
    final durationMs = json['trackTimeMillis'] as int? ?? 0;
    final durationSec = (durationMs / 1000).round();

    return TrackModel(
      id: json['trackId'] as int? ?? 0,
      title: json['trackName'] as String? ?? 'Unknown Title',
      artistName: json['artistName'] as String? ?? 'Unknown Artist',
      albumName: json['collectionName'] as String? ?? 'Unknown Album',
      duration: durationSec,
      previewUrl: json['previewUrl'] as String?,
      albumCover: _extractArtwork(json),
    );
  }

  static String? _extractArtwork(Map<String, dynamic> json) {
    // iTunes provides different sizes: 30, 60, 100
    // Replace 100x100 with larger size for better quality
    final artwork = json['artworkUrl100'] as String?;
    if (artwork != null) {
      // Get higher resolution (600x600)
      return artwork.replaceAll('100x100bb', '600x600bb');
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': id,
      'trackName': title,
      'artistName': artistName,
      'collectionName': albumName,
      'trackTimeMillis': duration * 1000,
      'previewUrl': previewUrl,
      'artworkUrl100': albumCover,
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
