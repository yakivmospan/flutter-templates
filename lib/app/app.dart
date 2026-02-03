import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/repository/settings_repository.dart';
import '../presentation/localization/localization.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/theme/theme.dart';
import '../presentation/theme/theme_block.dart';
import 'app_dependencies.dart';

void main() {
  setupAppDependencies();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(
        settingsRepository: getIt<SettingsRepository>(),
      )..add(LoadTheme()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Personal Finance Tracker',
            theme: appTheme,
            darkTheme: appDarkTheme,
            themeMode: state is ThemeDark ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
            ],
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
