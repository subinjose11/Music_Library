import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial tracks starting with query 'a'
class LoadInitialTracks extends LibraryEvent {
  const LoadInitialTracks();
}

/// Load more tracks for infinite scroll
class LoadMoreTracks extends LibraryEvent {
  const LoadMoreTracks();
}

/// Search for tracks with user query
class SearchTracks extends LibraryEvent {
  final String query;

  const SearchTracks(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter tracks by first letter (A-Z, 0-9)
class FilterByLetter extends LibraryEvent {
  final String letter;

  const FilterByLetter(this.letter);

  @override
  List<Object?> get props => [letter];
}

/// Clear search and return to full library
class ClearSearch extends LibraryEvent {
  const ClearSearch();
}

/// Connectivity changed
class ConnectivityChanged extends LibraryEvent {
  final bool isConnected;

  const ConnectivityChanged(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}
