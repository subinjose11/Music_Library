import 'package:equatable/equatable.dart';

import '../../../domain/entities/track.dart';
import '../../../domain/entities/lyrics.dart';

abstract class TrackDetailsState extends Equatable {
  const TrackDetailsState();

  @override
  List<Object?> get props => [];
}

class TrackDetailsInitial extends TrackDetailsState {
  const TrackDetailsInitial();
}

class TrackDetailsLoading extends TrackDetailsState {
  const TrackDetailsLoading();
}

class TrackDetailsLoaded extends TrackDetailsState {
  final Track track;
  final Lyrics? lyrics;
  final bool isLoadingLyrics;

  const TrackDetailsLoaded({
    required this.track,
    this.lyrics,
    this.isLoadingLyrics = false,
  });

  TrackDetailsLoaded copyWith({
    Track? track,
    Lyrics? lyrics,
    bool? isLoadingLyrics,
  }) {
    return TrackDetailsLoaded(
      track: track ?? this.track,
      lyrics: lyrics ?? this.lyrics,
      isLoadingLyrics: isLoadingLyrics ?? this.isLoadingLyrics,
    );
  }

  @override
  List<Object?> get props => [track, lyrics, isLoadingLyrics];
}

class TrackDetailsError extends TrackDetailsState {
  final String message;

  const TrackDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}
