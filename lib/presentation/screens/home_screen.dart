import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/track.dart';
import '../blocs/library/library_bloc.dart';
import '../blocs/library/library_state.dart';
import '../blocs/player/player_bloc.dart';
import '../blocs/player/player_event.dart';
import '../widgets/horizontal_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<LibraryBloc, LibraryState>(
          builder: (context, state) {
            if (state is LibraryLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              );
            }

            if (state is LibraryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.grey,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              );
            }

            if (state is LibraryLoaded) {
              return _buildContent(context, state.tracks);
            }

            return _buildWelcome(context);
          },
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            color: AppColors.accent,
            size: 80,
          ),
          SizedBox(height: 24),
          Text(
            'Welcome to Music Library',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Search for music to get started',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Track> tracks) {
    if (tracks.isEmpty) {
      return _buildWelcome(context);
    }

    // Split tracks into different sections
    final recentTracks = tracks.take(10).toList();
    final popularTracks = tracks.length > 10
        ? tracks.skip(5).take(10).toList()
        : tracks.take(5).toList();
    final moreTracks = tracks.length > 20
        ? tracks.skip(15).take(10).toList()
        : tracks.reversed.take(5).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Greeting header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _getGreeting(),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Recent section
          HorizontalSection(
            title: 'Recently Played',
            tracks: recentTracks,
            onTrackTap: (track) => _playTrack(context, track),
          ),
          const SizedBox(height: 24),
          // Popular section
          HorizontalSection(
            title: 'Popular Now',
            tracks: popularTracks,
            onTrackTap: (track) => _playTrack(context, track),
          ),
          const SizedBox(height: 24),
          // More section
          HorizontalSection(
            title: 'Discover More',
            tracks: moreTracks,
            onTrackTap: (track) => _playTrack(context, track),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  void _playTrack(BuildContext context, Track track) {
    context.read<PlayerBloc>().add(PlayTrack(track));
  }
}
