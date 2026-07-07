import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youmi_dev/features/auth/auth.dart';
import 'package:youmi_dev/providers/app_provider.dart';
import 'package:youmi_dev/providers/theme_provider.dart';
import 'package:youmi_dev/style/palettes.dart';
import 'package:youmi_dev/style/paper_widgets.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() {
    return _SettingsViewState();
  }
}

class _SettingsViewState extends State<SettingsView> {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

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
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Email'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && _emailPattern.hasMatch(value.trim())) {
                  return null;
                }
                return 'Enter a valid email address';
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
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
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                final String newEmail = controller.text.trim();
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
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Update Password'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      autofocus: true,
                      validator: (value) {
                        if (value != null && value.length >= 6) {
                          return null;
                        }
                        return 'At least 6 characters';
                      },
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
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      validator: (value) {
                        if (value == newPasswordController.text) {
                          return null;
                        }
                        return 'Passwords do not match';
                      },
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
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    final newPass = newPasswordController.text.trim();
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

  Future<void> _confirmLogout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text("You'll need to sign in again to continue."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await Provider.of<AppProvider>(context, listen: false).signOut();
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
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final AppProvider appProvider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final currentUser = appProvider.currentUser;

    String displayName = '';
    String displayEmail = '';
    if (currentUser != null) {
      displayName = currentUser.name.trim();
      displayEmail = currentUser.email.trim();
    }
    final String nameSubtitle = displayName.isEmpty ? 'Not set' : displayName;
    final String emailSubtitle = displayEmail.isEmpty ? 'Not set' : displayEmail;

    final VoidCallback? nameTap = appProvider.isBusy ? null : _openEditNameDialog;
    final VoidCallback? emailTap =
        appProvider.isBusy ? null : _openEditEmailDialog;
    final VoidCallback? passwordTap =
        appProvider.isBusy ? null : _openUpdatePasswordDialog;

    String initial = '?';
    if (displayName.isNotEmpty) {
      initial = displayName[0].toUpperCase();
    } else if (displayEmail.isNotEmpty) {
      initial = displayEmail[0].toUpperCase();
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
      ),
      body: RuledPage(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.primary,
                        child: Text(
                          initial,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nameSubtitle, style: theme.textTheme.titleMedium),
                            Text(
                              emailSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Name'),
                  subtitle: Text(nameSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: nameTap,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(emailSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: emailTap,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Password'),
                  subtitle: const Text('Tap to change your password'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: passwordTap,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Appearance', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Choose a color theme for the whole app',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: appPalettes.map((palette) {
                      final bool selected =
                          palette.name == themeProvider.palette.name;
                      return _PaletteSwatch(
                        palette: palette,
                        selected: selected,
                        onTap: () async {
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
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calendar Integration',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connect your calendar to sync events automatically',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ComingSoonRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Google Calendar',
                  ),
                  const SizedBox(height: 10),
                  _ComingSoonRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Outlook Calendar',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _confirmLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.4)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
          ),
          const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteSwatch({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  String get _displayName {
    final String raw = palette.name.replaceAll('_', ' ');
    return raw
        .split(' ')
        .map((word) {
          if (word.isEmpty) {
            return word;
          }
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: selected ? 2 : 1,
          ),
          color: palette.background,
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: palette.border),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: palette.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (selected)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.surface, width: 1.5),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 10,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _displayName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: palette.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ComingSoonRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Coming soon',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}