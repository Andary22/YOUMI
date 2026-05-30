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
  Future<void> _openEditNameDialog() async {
    final AppProvider appProvider =
        Provider.of<AppProvider>(context, listen: false);
    final currentUser = appProvider.currentUser;
    final String currentName;
    if (currentUser == null) {
      currentName = '';
    } else {
      currentName = currentUser.name;
    }
    final controller = TextEditingController(text: currentName);
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
                  _showMessage('Name updated');
                  return;
                }
                final String? lastError = appProvider.lastError;
                String failureMessage;
                if (lastError == null) {
                  failureMessage = 'Name update failed';
                } else {
                  failureMessage = lastError;
                }
                _showMessage(failureMessage);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openEditEmailDialog() async {
    final AppProvider appProvider =
        Provider.of<AppProvider>(context, listen: false);
    final currentUser = appProvider.currentUser;
    final String currentEmail;
    if (currentUser == null) {
      currentEmail = '';
    } else {
      currentEmail = currentUser.email;
    }
    final controller = TextEditingController(text: currentEmail);
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
                final String newEmail = controller.text.trim();
                if (newEmail.isEmpty) return;
                if (newEmail == currentEmail) {
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
                  _showMessage('Email updated');
                  return;
                }
                final String? lastError = appProvider.lastError;
                String failureMessage;
                if (lastError == null) {
                  failureMessage = 'Email update failed';
                } else {
                  failureMessage = lastError;
                }
                _showMessage(failureMessage);
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
            final IconData newPasswordIcon;
            if (obscureNew) {
              newPasswordIcon = Icons.visibility_off;
            } else {
              newPasswordIcon = Icons.visibility;
            }
            final IconData confirmPasswordIcon;
            if (obscureConfirm) {
              confirmPasswordIcon = Icons.visibility_off;
            } else {
              confirmPasswordIcon = Icons.visibility;
            }
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
                        icon: Icon(newPasswordIcon),
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
                        icon: Icon(confirmPasswordIcon),
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
                    final String? lastError = appProvider.lastError;
                    String failureMessage;
                    if (lastError == null) {
                      failureMessage = 'Password update failed';
                    } else {
                      failureMessage = lastError;
                    }
                    _showMessage(failureMessage);
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
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final AppProvider appProvider = context.watch<AppProvider>();
    final currentUser = appProvider.currentUser;
    final String displayName;
    if (currentUser == null) {
      displayName = '';
    } else {
      displayName = currentUser.name.trim();
    }
    final String displayEmail;
    if (currentUser == null) {
      displayEmail = '';
    } else {
      displayEmail = currentUser.email.trim();
    }
    final String nameSubtitle;
    if (displayName.isEmpty) {
      nameSubtitle = 'Not set';
    } else {
      nameSubtitle = displayName;
    }
    final String emailSubtitle;
    if (displayEmail.isEmpty) {
      emailSubtitle = 'Not set';
    } else {
      emailSubtitle = displayEmail;
    }
    final VoidCallback? nameTap;
    if (appProvider.isBusy) {
      nameTap = null;
    } else {
      nameTap = _openEditNameDialog;
    }
    final VoidCallback? emailTap;
    if (appProvider.isBusy) {
      emailTap = null;
    } else {
      emailTap = _openEditEmailDialog;
    }
    final VoidCallback? passwordTap;
    if (appProvider.isBusy) {
      passwordTap = null;
    } else {
      passwordTap = _openUpdatePasswordDialog;
    }

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
                  subtitle: Text(nameSubtitle),
                  trailing: const Icon(Icons.edit_outlined, size: 18),
                  onTap: nameTap,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(emailSubtitle),
                  trailing: const Icon(Icons.edit_outlined, size: 18),
                  onTap: emailTap,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Password'),
                  subtitle: const Text('Tap to change your password'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: passwordTap,
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
                            final String? lastError = appProvider.lastError;
                            String failureMessage;
                            if (lastError == null) {
                              failureMessage = 'Failed to save theme preference';
                            } else {
                              failureMessage = lastError;
                            }
                            _showMessage(failureMessage);
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