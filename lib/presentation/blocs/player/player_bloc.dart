import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/track.dart';
import 'player_event.dart';
import 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  Timer? _positionTimer;

  PlayerBloc() : super(const PlayerState()) {
    on<PlayTrack>(_onPlayTrack);
    on<PauseTrack>(_onPauseTrack);
    on<ResumeTrack>(_onResumeTrack);
    on<StopTrack>(_onStopTrack);
    on<SeekTo>(_onSeekTo);
    on<UpdatePosition>(_onUpdatePosition);
    on<AddToQueue>(_onAddToQueue);
    on<PlayNext>(_onPlayNext);
    on<PlayPrevious>(_onPlayPrevious);
    on<ClearQueue>(_onClearQueue);
    on<ToggleShuffle>(_onToggleShuffle);
    on<ToggleRepeat>(_onToggleRepeat);
  }

  void _onPlayTrack(PlayTrack event, Emitter<PlayerState> emit) {
    _stopPositionTimer();

    final duration = Duration(seconds: event.track.duration);

    // Add to queue if not already there
    List<Track> newQueue = List.from(state.queue);
    int trackIndex = newQueue.indexWhere((t) => t.id == event.track.id);

    if (trackIndex == -1) {
      newQueue.add(event.track);
      trackIndex = newQueue.length - 1;
    }

    emit(state.copyWith(
      currentTrack: event.track,
      isPlaying: true,
      position: Duration.zero,
      duration: duration,
      queue: newQueue,
      currentIndex: trackIndex,
    ));

    _startPositionTimer();
  }

  void _onPauseTrack(PauseTrack event, Emitter<PlayerState> emit) {
    _stopPositionTimer();
    emit(state.copyWith(isPlaying: false));
  }

  void _onResumeTrack(ResumeTrack event, Emitter<PlayerState> emit) {
    if (state.hasTrack) {
      emit(state.copyWith(isPlaying: true));
      _startPositionTimer();
    }
  }

  void _onStopTrack(StopTrack event, Emitter<PlayerState> emit) {
    _stopPositionTimer();
    emit(state.copyWith(
      isPlaying: false,
      position: Duration.zero,
      clearTrack: true,
    ));
  }

  void _onSeekTo(SeekTo event, Emitter<PlayerState> emit) {
    if (state.hasTrack) {
      emit(state.copyWith(position: event.position));
    }
  }

  void _onUpdatePosition(UpdatePosition event, Emitter<PlayerState> emit) {
    if (state.isPlaying && state.hasTrack) {
      if (event.position >= state.duration) {
        // Track finished
        _handleTrackEnd(emit);
      } else {
        emit(state.copyWith(position: event.position));
      }
    }
  }

  void _handleTrackEnd(Emitter<PlayerState> emit) {
    _stopPositionTimer();

    if (state.repeatMode == RepeatMode.one) {
      // Repeat current track
      emit(state.copyWith(position: Duration.zero));
      _startPositionTimer();
    } else if (state.hasNext) {
      // Play next track
      final nextIndex = state.currentIndex + 1;
      final nextTrack = state.queue[nextIndex];
      emit(state.copyWith(
        currentTrack: nextTrack,
        currentIndex: nextIndex,
        position: Duration.zero,
        duration: Duration(seconds: nextTrack.duration),
      ));
      _startPositionTimer();
    } else if (state.repeatMode == RepeatMode.all && state.queue.isNotEmpty) {
      // Repeat queue from beginning
      final firstTrack = state.queue[0];
      emit(state.copyWith(
        currentTrack: firstTrack,
        currentIndex: 0,
        position: Duration.zero,
        duration: Duration(seconds: firstTrack.duration),
      ));
      _startPositionTimer();
    } else {
      // Stop playback
      emit(state.copyWith(
        isPlaying: false,
        position: Duration.zero,
      ));
    }
  }

  void _onAddToQueue(AddToQueue event, Emitter<PlayerState> emit) {
    final newQueue = List.from(state.queue)..add(event.track);
    emit(state.copyWith(queue: List.from(newQueue)));
  }

  void _onPlayNext(PlayNext event, Emitter<PlayerState> emit) {
    if (state.hasNext) {
      _stopPositionTimer();
      final nextIndex = state.currentIndex + 1;
      final nextTrack = state.queue[nextIndex];
      emit(state.copyWith(
        currentTrack: nextTrack,
        currentIndex: nextIndex,
        position: Duration.zero,
        duration: Duration(seconds: nextTrack.duration),
        isPlaying: true,
      ));
      _startPositionTimer();
    }
  }

  void _onPlayPrevious(PlayPrevious event, Emitter<PlayerState> emit) {
    _stopPositionTimer();

    // If more than 3 seconds into the track, restart it
    if (state.position.inSeconds > 3) {
      emit(state.copyWith(position: Duration.zero));
      _startPositionTimer();
      return;
    }

    if (state.hasPrevious) {
      final prevIndex = state.currentIndex - 1;
      final prevTrack = state.queue[prevIndex];
      emit(state.copyWith(
        currentTrack: prevTrack,
        currentIndex: prevIndex,
        position: Duration.zero,
        duration: Duration(seconds: prevTrack.duration),
        isPlaying: true,
      ));
      _startPositionTimer();
    } else {
      emit(state.copyWith(position: Duration.zero));
      _startPositionTimer();
    }
  }

  void _onClearQueue(ClearQueue event, Emitter<PlayerState> emit) {
    _stopPositionTimer();
    emit(const PlayerState());
  }

  void _onToggleShuffle(ToggleShuffle event, Emitter<PlayerState> emit) {
    emit(state.copyWith(isShuffleEnabled: !state.isShuffleEnabled));
  }

  void _onToggleRepeat(ToggleRepeat event, Emitter<PlayerState> emit) {
    final nextMode = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    emit(state.copyWith(repeatMode: nextMode));
  }

  void _startPositionTimer() {
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isPlaying && state.hasTrack) {
        add(UpdatePosition(state.position + const Duration(seconds: 1)));
      }
    });
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  @override
  Future<void> close() {
    _stopPositionTimer();
    return super.close();
  }
}
