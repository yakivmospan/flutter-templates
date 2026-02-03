import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/repository/settings_repository.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SettingsRepository settingsRepository;

  ThemeBloc({required this.settingsRepository}) : super(ThemeLight()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final isDark = await settingsRepository.isDarkMode();
    emit(isDark ? ThemeDark() : ThemeLight());
  }

  Future<void> _onToggleTheme(
      ToggleTheme event, Emitter<ThemeState> emit) async {
    final isDark = state is ThemeDark;
    await settingsRepository.setDarkMode(!isDark);
    emit(isDark ? ThemeLight() : ThemeDark());
  }
}

// ---- Event -----
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object> get props => [];
}
class LoadTheme extends ThemeEvent {}
class ToggleTheme extends ThemeEvent {}


// ---- State -----
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}
class ThemeLight extends ThemeState {}
class ThemeDark extends ThemeState {}