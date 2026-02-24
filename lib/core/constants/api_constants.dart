class ApiConstants {
  ApiConstants._();

  // Deezer API (no authentication required)
  static const String deezerBaseUrl = 'https://api.deezer.com';
  static const String deezerSearchEndpoint = '/search';
  static const String deezerTrackEndpoint = '/track';

  // LRCLIB API for lyrics
  static const String lrclibBaseUrl = 'https://lrclib.net/api';
  static const String lrclibGetEndpoint = '/get';

  // Pagination
  static const int pageSize = 50;

  // Query terms for fetching 50k+ tracks
  static const List<String> queryTerms = [
    'love', 'life', 'time', 'night', 'day', 'heart', 'world',
    'dream', 'music', 'dance', 'rock', 'pop', 'jazz', 'blues',
    'baby', 'girl', 'man', 'woman', 'home', 'away', 'fire',
    'water', 'sun', 'moon', 'star', 'sky', 'rain', 'wind',
    'happy', 'sad', 'crazy', 'beautiful', 'forever', 'never',
    'hello', 'goodbye', 'tonight', 'party', 'street', 'city',
    'soul', 'funk', 'disco', 'electronic', 'acoustic', 'live',
    'remix', 'cover', 'original', 'classic', 'new', 'old',
    'summer', 'winter', 'spring', 'fall', 'christmas', 'holiday',
    'hip hop', 'r&b', 'country', 'metal', 'punk', 'indie',
    'alternative', 'folk', 'reggae', 'latin', 'african', 'asian',
  ];
}
