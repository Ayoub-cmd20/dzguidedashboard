abstract class SettingsEvent {}

class ToggleTheme extends SettingsEvent {
  final bool isDark;
  ToggleTheme(this.isDark);
}

class ChangeLanguage extends SettingsEvent {
  final String language;
  ChangeLanguage(this.language);
}
