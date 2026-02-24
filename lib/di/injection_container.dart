import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../core/network/network_info.dart';
import '../data/datasources/music_remote_datasource.dart';
import '../data/repositories/music_repository_impl.dart';
import '../domain/repositories/music_repository.dart';
import '../presentation/blocs/library/library_bloc.dart';
import '../presentation/blocs/track_details/track_details_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(
    () => LibraryBloc(repository: sl()),
  );

  sl.registerFactory(
    () => TrackDetailsBloc(repository: sl()),
  );

  // Repository
  sl.registerLazySingleton<MusicRepository>(
    () => MusicRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<MusicRemoteDataSource>(
    () => MusicRemoteDataSourceImpl(client: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );

  // External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
}
