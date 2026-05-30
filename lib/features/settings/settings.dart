import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youmi_dev/features/auth/auth.dart';
import 'package:youmi_dev/providers/app_provider.dart';
import 'package:youmi_dev/providers/theme_provider.dart';
import 'package:youmi_dev/style/palettes.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() {
    return _SettingsViewState();
  }
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _profileLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<AppProvider>(context, listen: false).currentUser;
    if (!_profileLoaded && user != null) {
      _emailController.text = user.email;
      _profileLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final appProvider = context.watch<AppProvider>();

    const palettes = appPalettes;

    AppPalette selectedPalette = themeProvider.palette;
    for (int i = 0; i < palettes.length; i++) {
      if (palettes[i].name == themeProvider.palette.name) {
        selectedPalette = palettes[i];
        break;
      }
    }
    VoidCallback? updatePasswordPressed;
    if (appProvider.isBusy) {
      updatePasswordPressed = null;
    } else {
      updatePasswordPressed = () async {
        final newPassword = _passwordController.text.trim();
        if (newPassword.isEmpty) {
          _showMessage('Enter a new password');
          return;
        }
        final bool success = await appProvider.updatePassword(newPassword);
        if (!mounted) {
          return;
        }
        if (success) {
          _passwordController.clear();
          _showMessage('Password updated');
          return;
        }
        String message = 'Password update failed';
        if (appProvider.lastError != null) {
          message = appProvider.lastError!;
        }
        _showMessage(message);
      };
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profile Information'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    // obscureText IS in course files
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: updatePasswordPressed,
                      child: const Text('Update Password'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Appearance'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(child: Text('Theme')),
                      // DropdownButton IS in course files
                      DropdownButton<AppPalette>(
                        value: selectedPalette,
                        items: palettes.map((palette) {
                          return DropdownMenuItem(
                            value: palette,
                            child: Text(palette.name),
                          );
                        }).toList(),
                        onChanged: (palette) async {
                          if (palette == null) {
                            return;
                          }
                          themeProvider.setPalette(palette);
                          final bool success =
                              await appProvider.updateThemePreference(
                            palette.name,
                          );
                          if (!mounted) {
                            return;
                          }
                          if (!success) {
                            String message =
                                'Failed to save theme preference';
                            if (appProvider.lastError != null) {
                              message = appProvider.lastError!;
                            }
                            _showMessage(message);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Calendar Integration (Optional)'),
                  const SizedBox(height: 8),
                  const Text('Connect your calendar to sync events automatically'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    child: Row(
                      children: const [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text('Connect Google Calendar'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: Row(
                      children: const [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text('Connect Outlook Calendar'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await Provider.of<AppProvider>(context, listen: false)
                    .signOut();
                if (!mounted) {
                  return;
                }
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const AuthPage();
                    },
                  ),
                  (route) {
                    return false;
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Log Out'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
