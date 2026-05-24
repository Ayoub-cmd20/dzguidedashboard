import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState(
    themeMode: ThemeMode.light,
    locale: const Locale('en'),
    languageName: 'English',
  )) {
    on<ToggleTheme>((event, emit) {
      emit(state.copyWith(
        themeMode: event.isDark ? ThemeMode.dark : ThemeMode.light,
      ));
    });

    on<ChangeLanguage>((event, emit) {
      Locale newLocale;
      switch (event.language) {
        case 'French':
          newLocale = const Locale('fr');
          break;
        case 'Arabic':
          newLocale = const Locale('ar');
          break;
        default:
          newLocale = const Locale('en');
      }
      emit(state.copyWith(
        locale: newLocale,
        languageName: event.language,
      ));
    });
  }
}
