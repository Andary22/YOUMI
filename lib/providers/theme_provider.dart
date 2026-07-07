// ThemeProvider: palette selection and ThemeData updates.
import 'package:flutter/material.dart';
import 'package:youmi_dev/style/palettes.dart';
import 'package:youmi_dev/style/theme_factory.dart';

class ThemeProvider extends ChangeNotifier {
  AppPalette _palette = const LightPalette();
  ThemeData? _themeCache;

  AppPalette get palette {
    return _palette;
  }

  ThemeData get theme {
    return _themeCache ??= buildTheme(_palette);
  }

  bool get isDark {
    return _palette.isDark;
  }

  void setPalette(AppPalette palette) {
    if (_palette.name == palette.name) {
      return;
    }
    _palette = palette;
    _themeCache = null;
    notifyListeners();
  }

  void setPaletteByName(String name) {
    final nextPalette = paletteFromName(name);
    if (_palette.name == nextPalette.name) {
      return;
    }
    _palette = nextPalette;
    _themeCache = null;
    notifyListeners();
  }

  void togglePalette() {
    if (isDark) {
      _palette = const LightPalette();
    } else {
      _palette = const DarkPalette();
    }
    _themeCache = null;
    notifyListeners();
  }
}
