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
  bool _profileLoaded = false;
  String _displayName = '';
  String _displayEmail = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<AppProvider>(context, listen: false).currentUser;
    if (user != null) {
      if (!_profileLoaded) {
        _profileLoaded = true;
      }
      _displayName = user.name;
      _displayEmail = user.email;
    }
  }

  Future<void> _openEditNameDialog() async {
    final controller = TextEditingController(text: _displayName);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;
                Navigator.pop(dialogContext);
                final appProvider =
                    Provider.of<AppProvider>(context, listen: false);
                final bool success = await appProvider.updateName(newName);
                if (!mounted) return;
                if (success) {
                  setState(() {
                    _displayName = newName;
                  });
                  _showMessage('Name updated');
                  return;
                }
                _showMessage(appProvider.lastError ?? 'Name update failed');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openEditEmailDialog() async {
    final controller = TextEditingController(text: _displayEmail);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Email'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newEmail = controller.text.trim();
                if (newEmail.isEmpty) return;
                if (newEmail == _displayEmail) {
                  Navigator.pop(dialogContext);
                  _showMessage('This is already your current email');
                  return;
                }
                Navigator.pop(dialogContext);
                final appProvider =
                    Provider.of<AppProvider>(context, listen: false);
                final bool success = await appProvider.updateEmail(newEmail);
                if (!mounted) return;
                if (success) {
                  setState(() {
                    _displayEmail = newEmail;
                  });
                  _showMessage('Email updated');
                  return;
                }
                _showMessage(appProvider.lastError ?? 'Email update failed');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openUpdatePasswordDialog() async {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Update Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            obscureNew = !obscureNew;
                          });
                        },
                        icon: Icon(
                          obscureNew
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newPass = newPasswordController.text.trim();
                    final confirmPass = confirmPasswordController.text.trim();
                    if (newPass.isEmpty) return;
                    if (newPass != confirmPass) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwords do not match'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(dialogContext);
                    final appProvider =
                        Provider.of<AppProvider>(context, listen: false);
                    final bool success =
                        await appProvider.updatePassword(newPass);
                    if (!mounted) return;
                    if (success) {
                      _showMessage('Password updated');
                      return;
                    }
                    _showMessage(
                      appProvider.lastError ?? 'Password update failed',
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 14,
                    bottom: 4,
                  ),
                  child: const Text('Profile'),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Name'),
                  subtitle: Text(
                    _displayName.isEmpty ? 'Not set' : _displayName,
                  ),
                  trailing: const Icon(Icons.edit_outlined, size: 18),
                  onTap: appProvider.isBusy ? null : _openEditNameDialog,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(_displayEmail),
                  trailing: const Icon(Icons.edit_outlined, size: 18),
                  onTap: appProvider.isBusy ? null : _openEditEmailDialog,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Password'),
                  subtitle: const Text('Tap to change your password'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: appProvider.isBusy
                      ? null
                      : _openUpdatePasswordDialog,
                ),
                const SizedBox(height: 4),
              ],
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
                      DropdownButton<AppPalette>(
                        value: selectedPalette,
                        items: palettes.map((palette) {
                          return DropdownMenuItem(
                            value: palette,
                            child: Text(palette.name),
                          );
                        }).toList(),
                        onChanged: (palette) async {
                          if (palette == null) return;
                          themeProvider.setPalette(palette);
                          final bool success =
                              await appProvider.updateThemePreference(
                            palette.name,
                          );
                          if (!mounted) return;
                          if (!success) {
                            _showMessage(
                              appProvider.lastError ??
                                  'Failed to save theme preference',
                            );
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
                  const Text(
                    'Connect your calendar to sync events automatically',
                  ),
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
                if (!mounted) return;
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