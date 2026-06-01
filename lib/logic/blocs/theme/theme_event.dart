abstract class ThemeEvent {}

class LoadTheme extends ThemeEvent {}

class ToggleGlobalTheme extends ThemeEvent {
  final bool isDark;
  ToggleGlobalTheme(this.isDark);
}
