import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode themeMode;

  ThemeState(this.themeMode);

  bool get isDarkMode => themeMode == ThemeMode.dark;
}
