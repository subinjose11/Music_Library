import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'di/injection_container.dart' as di;
import 'presentation/blocs/library/library_bloc.dart';
import 'presentation/blocs/player/player_bloc.dart';
import 'presentation/screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MusicLibraryApp());
}

class MusicLibraryApp extends StatelessWidget {
  const MusicLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<LibraryBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<PlayerBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Music Library',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const MainShell(),
      ),
    );
  }
}
