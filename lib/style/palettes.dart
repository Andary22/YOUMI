// AppPalette definitions and concrete theme palette values.
import 'package:flutter/material.dart';

abstract class AppPalette {
  String get name;
  Brightness get brightness;
  bool get isDark;
  Color get background;
  Color get surface;
  Color get primary;
  Color get secondary;
  Color get text;
  Color get mutedText;
  Color get border;
}

class LightPalette implements AppPalette {
  const LightPalette();

  @override
  String get name => 'light';

  @override
  Brightness get brightness => Brightness.light;

  @override
  bool get isDark => false;

  @override
  Color get background => const Color(0xFFF7F5F2);

  @override
  Color get surface => const Color(0xFFFFFFFF);

  @override
  Color get primary => const Color(0xFF2F6D5D);

  @override
  Color get secondary => const Color(0xFF7B5A3A);

  @override
  Color get text => const Color(0xFF1C1B1A);

  @override
  Color get mutedText => const Color(0xFF6E6A65);

  @override
  Color get border => const Color(0xFFE3DED6);
}

class DarkPalette implements AppPalette {
  const DarkPalette();

  @override
  String get name => 'dark';

  @override
  Brightness get brightness => Brightness.dark;

  @override
  bool get isDark => true;

  @override
  Color get background => const Color(0xFF121210);

  @override
  Color get surface => const Color(0xFF1C1B19);

  @override
  Color get primary => const Color(0xFF6BC2A0);

  @override
  Color get secondary => const Color(0xFFB89C7D);

  @override
  Color get text => const Color(0xFFF4F0EA);

  @override
  Color get mutedText => const Color(0xFFB0AAA2);

  @override
  Color get border => const Color(0xFF2C2A27);
}

class GruvboxMaterialLightPalette implements AppPalette {
  const GruvboxMaterialLightPalette();

  @override
  String get name => 'gruvbox_material_light';

  @override
  Brightness get brightness => Brightness.light;

  @override
  bool get isDark => false;

  @override
  Color get background => const Color(0xFFF2E5BC);

  @override
  Color get surface => const Color(0xFFF2E5BC);

  @override
  Color get primary => const Color(0xFF45707A);

  @override
  Color get secondary => const Color(0xFF945E80);

  @override
  Color get text => const Color(0xFF654735);

  @override
  Color get mutedText => const Color(0xFFB47109);

  @override
  Color get border => const Color(0xFFF2E5BC);
}

class GruvboxMaterialDarkPalette implements AppPalette {
  const GruvboxMaterialDarkPalette();

  @override
  String get name => 'gruvbox_material_dark';

  @override
  Brightness get brightness => Brightness.dark;

  @override
  bool get isDark => true;

  @override
  Color get background => const Color(0xFF3C3836);

  @override
  Color get surface => const Color(0xFF3C3836);

  @override
  Color get primary => const Color(0xFF7DAEA3);

  @override
  Color get secondary => const Color(0xFFD3869B);

  @override
  Color get text => const Color(0xFFD4BE98);

  @override
  Color get mutedText => const Color(0xFFA9B665);

  @override
  Color get border => const Color(0xFF3C3836);
}

class CatppuccinLattePalette implements AppPalette {
  const CatppuccinLattePalette();

  @override
  String get name => 'catppuccin_latte';

  @override
  Brightness get brightness => Brightness.light;

  @override
  bool get isDark => false;

  @override
  Color get background => const Color(0xFFBCC0CC);

  @override
  Color get surface => const Color(0xFFACB0BE);

  @override
  Color get primary => const Color(0xFF1E66F5);

  @override
  Color get secondary => const Color(0xFFEA76CB);

  @override
  Color get text => const Color(0xFF5C5F77);

  @override
  Color get mutedText => const Color(0xFF6C6F85);

  @override
  Color get border => const Color(0xFFACB0BE);
}

class CatppuccinMochaPalette implements AppPalette {
  const CatppuccinMochaPalette();

  @override
  String get name => 'catppuccin_mocha';

  @override
  Brightness get brightness => Brightness.dark;

  @override
  bool get isDark => true;

  @override
  Color get background => const Color(0xFF45475A);

  @override
  Color get surface => const Color(0xFF585B70);

  @override
  Color get primary => const Color(0xFF89B4FA);

  @override
  Color get secondary => const Color(0xFFF5C2E7);

  @override
  Color get text => const Color(0xFFBAC2DE);

  @override
  Color get mutedText => const Color(0xFFA6ADC8);

  @override
  Color get border => const Color(0xFF585B70);
}

class NordDarkPalette implements AppPalette {
  const NordDarkPalette();

  @override
  String get name => 'nord_dark';

  @override
  Brightness get brightness => Brightness.dark;

  @override
  bool get isDark => true;

  @override
  Color get background => const Color(0xFF3B4252);

  @override
  Color get surface => const Color(0xFF4C566A);

  @override
  Color get primary => const Color(0xFF81A1C1);

  @override
  Color get secondary => const Color(0xFFB48EAD);

  @override
  Color get text => const Color(0xFFE5E9F0);

  @override
  Color get mutedText => const Color(0xFF4C566A);

  @override
  Color get border => const Color(0xFF4C566A);
}

class NordLightPalette implements AppPalette {
  const NordLightPalette();

  @override
  String get name => 'nord_light';

  @override
  Brightness get brightness => Brightness.light;

  @override
  bool get isDark => false;

  @override
  Color get background => const Color(0xFFECEFF4);

  @override
  Color get surface => const Color(0xFFE5E9F0);

  @override
  Color get primary => const Color(0xFF81A1C1);

  @override
  Color get secondary => const Color(0xFFB48EAD);

  @override
  Color get text => const Color(0xFF3B4252);

  @override
  Color get mutedText => const Color(0xFF4C566A);

  @override
  Color get border => const Color(0xFFE5E9F0);
}
