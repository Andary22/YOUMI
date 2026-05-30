// ThemeProvider: palette selection and ThemeData updates.
import 'package:flutter/material.dart';
import 'package:youmi_dev/style/palettes.dart';
import 'package:youmi_dev/style/theme_factory.dart';

class ThemeProvider extends ChangeNotifier {
  AppPalette _palette = const LightPalette();

  AppPalette get palette {
    return _palette;
  }

  ThemeData get theme {
    return buildTheme(_palette);
  }

  bool get isDark {
    return _palette.isDark;
  }

  void setPalette(AppPalette palette) {
    _palette = palette;
    notifyListeners();
  }

  void setPaletteByName(String name) {
    _palette = paletteFromName(name);
    notifyListeners();
  }

  void togglePalette() {
    if (isDark) {
      _palette = const LightPalette();
    } else {
      _palette = const DarkPalette();
    }
    notifyListeners();
  }
}
