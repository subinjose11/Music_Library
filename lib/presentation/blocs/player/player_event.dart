import 'package:equatable/equatable.dart';

import '../../../domain/entities/track.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayTrack extends PlayerEvent {
  final Track track;

  const PlayTrack(this.track);

  @override
  List<Object?> get props => [track];
}

class PauseTrack extends PlayerEvent {
  const PauseTrack();
}

class ResumeTrack extends PlayerEvent {
  const ResumeTrack();
}

class StopTrack extends PlayerEvent {
  const StopTrack();
}

class SeekTo extends PlayerEvent {
  final Duration position;

  const SeekTo(this.position);

  @override
  List<Object?> get props => [position];
}

class UpdatePosition extends PlayerEvent {
  final Duration position;

  const UpdatePosition(this.position);

  @override
  List<Object?> get props => [position];
}

class AddToQueue extends PlayerEvent {
  final Track track;

  const AddToQueue(this.track);

  @override
  List<Object?> get props => [track];
}

class PlayNext extends PlayerEvent {
  const PlayNext();
}

class PlayPrevious extends PlayerEvent {
  const PlayPrevious();
}

class ClearQueue extends PlayerEvent {
  const ClearQueue();
}

class ToggleShuffle extends PlayerEvent {
  const ToggleShuffle();
}

class ToggleRepeat extends PlayerEvent {
  const ToggleRepeat();
}
