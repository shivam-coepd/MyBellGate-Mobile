import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/config/app_config.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_getThemeModeFromConfig());

  static ThemeMode _getThemeModeFromConfig() {
    final mode = AppConfig.themeMode;
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  void updateTheme(ThemeMode themeMode) async {
    emit(themeMode);
    String modeString = 'system';
    if (themeMode == ThemeMode.light) {
      modeString = 'light';
    } else if (themeMode == ThemeMode.dark) {
      modeString = 'dark';
    }
    await AppConfig.setThemeMode(modeString);
  }
}
