import '../../domain/entities/lyrics.dart';

class LyricsModel extends Lyrics {
  const LyricsModel({
    super.plainLyrics,
    super.syncedLyrics,
  });

  factory LyricsModel.fromJson(Map<String, dynamic> json) {
    return LyricsModel(
      plainLyrics: json['plainLyrics'] as String?,
      syncedLyrics: json['syncedLyrics'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plainLyrics': plainLyrics,
      'syncedLyrics': syncedLyrics,
    };
  }

  Lyrics toEntity() {
    return Lyrics(
      plainLyrics: plainLyrics,
      syncedLyrics: syncedLyrics,
    );
  }
}
