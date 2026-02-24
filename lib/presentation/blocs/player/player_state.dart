import 'package:equatable/equatable.dart';

import '../../../domain/entities/track.dart';

enum RepeatMode { off, all, one }

class PlayerState extends Equatable {
  final Track? currentTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final List<Track> queue;
  final int currentIndex;
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;

  const PlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.queue = const [],
    this.currentIndex = 0,
    this.isShuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
  });

  bool get hasTrack => currentTrack != null;

  bool get hasNext => currentIndex < queue.length - 1;

  bool get hasPrevious => currentIndex > 0;

  double get progress {
    if (duration.inMilliseconds == 0) return 0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  String get positionText => _formatDuration(position);

  String get durationText => _formatDuration(duration);

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  PlayerState copyWith({
    Track? currentTrack,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    List<Track>? queue,
    int? currentIndex,
    bool? isShuffleEnabled,
    RepeatMode? repeatMode,
    bool clearTrack = false,
  }) {
    return PlayerState(
      currentTrack: clearTrack ? null : (currentTrack ?? this.currentTrack),
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }

  @override
  List<Object?> get props => [
        currentTrack,
        isPlaying,
        position,
        duration,
        queue,
        currentIndex,
        isShuffleEnabled,
        repeatMode,
      ];
}
