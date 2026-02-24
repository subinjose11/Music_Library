import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/track.dart';
import '../../domain/entities/lyrics.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/music_remote_datasource.dart';

class MusicRepositoryImpl implements MusicRepository {
  final MusicRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MusicRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Track>> searchTracks({
    required String query,
    int index = 0,
    int limit = 50,
  }) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException();
    }

    final trackModels = await remoteDataSource.searchTracks(
      query: query,
      offset: index,
      limit: limit,
    );

    return trackModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Track> getTrackDetails(int trackId) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException();
    }

    final trackModel = await remoteDataSource.getTrackDetails(trackId);
    return trackModel.toEntity();
  }

  @override
  Future<Lyrics?> getLyrics({
    required String trackName,
    required String artistName,
    required String albumName,
    required int duration,
  }) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException();
    }

    final lyricsModel = await remoteDataSource.getLyrics(
      trackName: trackName,
      artistName: artistName,
      albumName: albumName,
      duration: duration,
    );

    return lyricsModel?.toEntity();
  }

  @override
  Future<bool> get isConnected => networkInfo.isConnected;

  @override
  Stream<bool> get onConnectivityChanged => networkInfo.onConnectivityChanged;
}
