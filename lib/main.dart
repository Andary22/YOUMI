import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:youmi_dev/features/app_shell.dart'; later, remove feature imports and use this instead.
import 'package:youmi_dev/providers/app_provider.dart';
import 'package:youmi_dev/providers/blueprint_provider.dart';
import 'package:youmi_dev/providers/execution_provider.dart';
import 'package:youmi_dev/providers/theme_provider.dart';
import 'package:youmi_dev/style/palettes.dart';

//this main is currently a placeholder.
/*
 * do not push any modifcations to this, we will later integrate all views and
 * the app_shell here. feel free to modify this to test your work but do not
 * commit changes to this, I will reject your PR if it modifies this file.
*/

void main() {
  runApp(const YoumiApp());
}

class YoumiApp extends StatelessWidget {
  const YoumiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => BlueprintProvider()),
        ChangeNotifierProvider(create: (_) => ExecutionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        // ThemeProvider owns ThemeData and rebuilds MaterialApp on changes.
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Youmi',
            theme: themeProvider.theme,
            home: const ThemeShowcase(),
          );
        },
      ),
    );
  }
}

class ThemeShowcase extends StatelessWidget {
  const ThemeShowcase({super.key});

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final selectedPalette = _palettes.firstWhere(
      (palette) => palette.name == themeProvider.palette.name,
      orElse: () => _palettes.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Showcase'),
        actions: [
          IconButton(
            onPressed: themeProvider.togglePalette,
            icon: Icon(
              themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Theme Provider Usage', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Use ThemeProvider to switch palettes, and Theme.of(context) for UI colors.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AppPalette>(
            initialValue: selectedPalette,
            decoration: const InputDecoration(labelText: 'Active palette'),
            items: _palettes
                .map(
                  (palette) => DropdownMenuItem(
                    value: palette,
                    child: Text(palette.name),
                  ),
                )
                .toList(),
            onChanged: (palette) {
              if (palette != null) {
                themeProvider.setPalette(palette);
              }
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sample content', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Buttons, text, and fields inherit the palette via ThemeData.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Primary'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Secondary'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Text field',
                    hintText: 'Uses themed borders',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
