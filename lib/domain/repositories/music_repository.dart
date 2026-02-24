import '../entities/track.dart';
import '../entities/lyrics.dart';

abstract class MusicRepository {
  /// Search for tracks using the Deezer API
  /// Returns a list of tracks matching the query
  Future<List<Track>> searchTracks({
    required String query,
    int index = 0,
    int limit = 50,
  });

  /// Get detailed information about a specific track
  Future<Track> getTrackDetails(int trackId);

  /// Get lyrics for a track from LRCLIB
  Future<Lyrics?> getLyrics({
    required String trackName,
    required String artistName,
    required String albumName,
    required int duration,
  });

  /// Check if device has internet connection
  Future<bool> get isConnected;

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged;
}
