import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:youmi_dev/features/app_shell.dart'; later, remove feature imports and use this instead.
import 'package:youmi_dev/providers/app_provider.dart';
import 'package:youmi_dev/providers/blueprint_provider.dart';
import 'package:youmi_dev/providers/execution_provider.dart';


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
      ],
      child: const Placeholder(),
    );
  }
}
