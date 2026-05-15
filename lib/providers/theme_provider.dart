// ThemeProvider: palette selection and ThemeData updates.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youmi_dev/style/palettes.dart';
import 'package:youmi_dev/style/theme_factory.dart';

class ThemeProvider extends ChangeNotifier {
  static const List<AppPalette> _palettes = [
    LightPalette(),
    DarkPalette(),
    GruvboxMaterialLightPalette(),
    GruvboxMaterialDarkPalette(),
    CatppuccinLattePalette(),
    CatppuccinMochaPalette(),
    NordLightPalette(),
    NordDarkPalette(),
  ];

  AppPalette _palette = const LightPalette();

  AppPalette get palette => _palette;

  ThemeData get theme => buildTheme(_palette);

  bool get isDark => _palette.isDark;

  List<AppPalette> get palettes => _palettes;

  void setPalette(AppPalette palette) {
    _palette = palette;
    notifyListeners();
  }

  void togglePalette() {
    _palette = isDark ? const LightPalette() : const DarkPalette();
    notifyListeners();
  }
}
