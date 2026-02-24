import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/exceptions.dart';
import '../../../domain/repositories/music_repository.dart';
import 'track_details_event.dart';
import 'track_details_state.dart';

class TrackDetailsBloc extends Bloc<TrackDetailsEvent, TrackDetailsState> {
  final MusicRepository repository;

  TrackDetailsBloc({required this.repository})
      : super(const TrackDetailsInitial()) {
    on<LoadTrackDetails>(_onLoadTrackDetails);
    on<ClearTrackDetails>(_onClearTrackDetails);
  }

  Future<void> _onLoadTrackDetails(
    LoadTrackDetails event,
    Emitter<TrackDetailsState> emit,
  ) async {
    emit(const TrackDetailsLoading());

    try {
      // Load track details from API
      final track = await repository.getTrackDetails(event.trackId);

      // Emit track details with loading lyrics indicator
      emit(TrackDetailsLoaded(
        track: track,
        isLoadingLyrics: true,
      ));

      // Load lyrics separately (non-blocking)
      try {
        final lyrics = await repository.getLyrics(
          trackName: event.trackName,
          artistName: event.artistName,
          albumName: event.albumName,
          duration: event.duration,
        );

        emit(TrackDetailsLoaded(
          track: track,
          lyrics: lyrics,
          isLoadingLyrics: false,
        ));
      } catch (e) {
        // Lyrics loading failed, but we still have track details
        emit(TrackDetailsLoaded(
          track: track,
          isLoadingLyrics: false,
        ));
      }
    } on NetworkException catch (e) {
      emit(TrackDetailsError(message: e.message));
    } catch (e) {
      emit(TrackDetailsError(message: 'Failed to load track details'));
    }
  }

  void _onClearTrackDetails(
    ClearTrackDetails event,
    Emitter<TrackDetailsState> emit,
  ) {
    emit(const TrackDetailsInitial());
  }
}
