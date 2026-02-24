import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/track_model.dart';
import '../models/lyrics_model.dart';

abstract class MusicRemoteDataSource {
  /// Search for tracks using Deezer API
  Future<List<TrackModel>> searchTracks({
    required String query,
    int offset = 0,
    int limit = 50,
  });

  /// Get track details from Deezer API
  Future<TrackModel> getTrackDetails(int trackId);

  /// Get lyrics from LRCLIB API
  Future<LyricsModel?> getLyrics({
    required String trackName,
    required String artistName,
    required String albumName,
    required int duration,
  });
}

class MusicRemoteDataSourceImpl implements MusicRemoteDataSource {
  final http.Client client;

  MusicRemoteDataSourceImpl({required this.client});

  @override
  Future<List<TrackModel>> searchTracks({
    required String query,
    int offset = 0,
    int limit = 50,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.deezerBaseUrl}${ApiConstants.deezerSearchEndpoint}'
      '?q=${Uri.encodeComponent(query)}'
      '&limit=$limit'
      '&index=$offset',
    );

    try {
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final results = jsonData['data'] as List<dynamic>?;

        if (results == null || results.isEmpty) {
          return [];
        }

        return results
            .map((trackJson) =>
                TrackModel.fromJson(trackJson as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to search tracks',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<TrackModel> getTrackDetails(int trackId) async {
    final uri = Uri.parse(
      '${ApiConstants.deezerBaseUrl}${ApiConstants.deezerTrackEndpoint}/$trackId',
    );

    try {
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        if (jsonData.containsKey('error')) {
          throw ServerException(
            message: 'Track not found',
            statusCode: 404,
          );
        }

        return TrackModel.fromJson(jsonData);
      } else {
        throw ServerException(
          message: 'Failed to get track details',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<LyricsModel?> getLyrics({
    required String trackName,
    required String artistName,
    required String albumName,
    required int duration,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.lrclibBaseUrl}${ApiConstants.lrclibGetEndpoint}'
      '?track_name=${Uri.encodeComponent(trackName)}'
      '&artist_name=${Uri.encodeComponent(artistName)}'
      '&album_name=${Uri.encodeComponent(albumName)}'
      '&duration=$duration',
    );

    try {
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return LyricsModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        // Lyrics not found - return null
        return null;
      } else {
        throw ServerException(
          message: 'Failed to get lyrics',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      // For lyrics, we don't want to throw on errors - just return null
      return null;
    }
  }
}
