import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youmi_dev/features/auth/auth.dart';
import 'package:youmi_dev/providers/analytics_provider.dart';
import 'package:youmi_dev/providers/app_provider.dart';
import 'package:youmi_dev/providers/blueprint_provider.dart';
import 'package:youmi_dev/providers/execution_provider.dart';
import 'package:youmi_dev/providers/theme_provider.dart';

void main() {
  runApp(const YoumiApp());
}

class YoumiApp extends StatefulWidget {
  const YoumiApp({super.key});

  @override
  State<YoumiApp> createState() {
    return _YoumiAppState();
  }
}

class _YoumiAppState extends State<YoumiApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          return AppProvider();
        }),
        ChangeNotifierProvider(create: (context) {
          return BlueprintProvider();
        }),
        ChangeNotifierProvider(create: (context) {
          return ExecutionProvider();
        }),
        ChangeNotifierProxyProvider2<
          ExecutionProvider,
          BlueprintProvider,
          AnalyticsProvider
        >(
          create: (context) {
            return AnalyticsProvider();
          },
          update: (context, execution, blueprint, analytics) {
            if (analytics == null) {
              analytics = AnalyticsProvider();
            }
            analytics.syncData(
              instances: execution.items,
              templates: blueprint.templates,
              habits: blueprint.habits,
            );
            return analytics;
          },
        ),
        ChangeNotifierProvider(create: (context) {
          return ThemeProvider();
        }),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Youmi',
            theme: themeProvider.theme,
            themeAnimationDuration: const Duration(milliseconds: 320),
            themeAnimationCurve: Curves.easeOutCubic,
            home: const AuthPage(),
          );
        },
      ),
    );
  }
}
