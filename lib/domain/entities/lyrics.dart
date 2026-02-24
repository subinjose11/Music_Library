import 'package:equatable/equatable.dart';

class Lyrics extends Equatable {
  final String? plainLyrics;
  final String? syncedLyrics;

  const Lyrics({
    this.plainLyrics,
    this.syncedLyrics,
  });

  bool get hasLyrics => plainLyrics != null || syncedLyrics != null;

  String get displayLyrics => plainLyrics ?? syncedLyrics ?? 'No lyrics available';

  @override
  List<Object?> get props => [plainLyrics, syncedLyrics];
}
