import 'package:equatable/equatable.dart';

abstract class TrackDetailsEvent extends Equatable {
  const TrackDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Load track details and lyrics
class LoadTrackDetails extends TrackDetailsEvent {
  final int trackId;
  final String trackName;
  final String artistName;
  final String albumName;
  final int duration;

  const LoadTrackDetails({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.albumName,
    required this.duration,
  });

  @override
  List<Object?> get props => [trackId, trackName, artistName, albumName, duration];
}

/// Clear track details when leaving screen
class ClearTrackDetails extends TrackDetailsEvent {
  const ClearTrackDetails();
}
