import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final String languageName;

  SettingsState({
    required this.themeMode,
    required this.locale,
    required this.languageName,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    String? languageName,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      languageName: languageName ?? this.languageName,
    );
  }
}
