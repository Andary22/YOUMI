import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youmi_dev/features/app_shell.dart';
import 'package:youmi_dev/providers/app_provider.dart';
import 'package:youmi_dev/providers/blueprint_provider.dart';
import 'package:youmi_dev/providers/execution_provider.dart';
import 'package:youmi_dev/providers/theme_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoginView = true;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.watch<AppProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBrand(theme),
                  const SizedBox(height: 36),
                  _buildModeSwitch(theme),
                  const SizedBox(height: 28),
                  Form(
                    key: _formKey,
                    child: _isLoginView
                        ? _buildLoginFields(app.isBusy)
                        : _buildSignUpFields(app.isBusy),
                  ),
                  const SizedBox(height: 24),
                  _buildSubmitButton(app.isBusy),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.check_circle_rounded,
            color: theme.colorScheme.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'YOUMI',
          style: theme.textTheme.headlineLarge?.copyWith(
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Plan your day. Build the habit.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildModeSwitch(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _buildModeTab(theme, 'Log In', true)),
          Expanded(child: _buildModeTab(theme, 'Sign Up', false)),
        ],
      ),
    );
  }

  Widget _buildModeTab(ThemeData theme, String label, bool value) {
    final bool selected = _isLoginView == value;
    return GestureDetector(
      onTap: () {
        if (_isLoginView == value) {
          return;
        }
        setState(() {
          _isLoginView = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginFields(bool isBusy) {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _emailController,
          enabled: !isBusy,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.mail_outline),
            labelText: 'Email',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          enabled: !isBusy,
          validator: _validatePassword,
          obscureText: _isPasswordObscured,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            labelText: 'Password',
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordObscured = !_isPasswordObscured;
                });
              },
              icon: Icon(
                _isPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: isBusy ? null : _openForgotPasswordSheet,
            child: const Text('Forgot password?'),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpFields(bool isBusy) {
    return Column(
      key: const ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _nameController,
          enabled: !isBusy,
          validator: _validateName,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline),
            labelText: 'Name',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          enabled: !isBusy,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.mail_outline),
            labelText: 'Email',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          enabled: !isBusy,
          validator: _validatePassword,
          obscureText: _isPasswordObscured,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            labelText: 'Password',
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordObscured = !_isPasswordObscured;
                });
              },
              icon: Icon(
                _isPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          enabled: !isBusy,
          validator: _validateConfirmPassword,
          obscureText: _isConfirmPasswordObscured,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            labelText: 'Confirm Password',
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                });
              },
              icon: Icon(
                _isConfirmPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isBusy) {
    return ElevatedButton(
      onPressed: isBusy ? null : _handleSubmit,
      child: isBusy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          : Text(_isLoginView ? 'Log In' : 'Sign Up'),
    );
  }

  String? _validateName(String? s) {
    if (s != null && s.trim().isNotEmpty) {
      return null;
    }
    return 'Enter your name';
  }

  String? _validateEmail(String? s) {
    if (s != null && _emailPattern.hasMatch(s.trim())) {
      return null;
    }
    return 'Enter a valid email address';
  }

  String? _validatePassword(String? s) {
    if (s != null && s.length >= 6) {
      return null;
    }
    return 'Password must be at least 6 characters';
  }

  String? _validateConfirmPassword(String? s) {
    if (s != null && s == _passwordController.text) {
      return null;
    }
    return 'Passwords do not match';
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_isLoginView) {
      await _handleLogin();
    } else {
      await _handleSignUp();
    }
  }

  Future<void> _openForgotPasswordSheet() async {
    final TextEditingController resetEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    final GlobalKey<FormState> resetFormKey = GlobalKey<FormState>();
    bool isSending = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              return Form(
                key: resetFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Reset Password',
                      style: Theme.of(sheetContext).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We'll email you a link to reset your password.",
                      style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: resetEmailController,
                      enabled: !isSending,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline),
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              if (!(resetFormKey.currentState?.validate() ??
                                  false)) {
                                return;
                              }
                              setSheetState(() {
                                isSending = true;
                              });
                              final app = Provider.of<AppProvider>(
                                context,
                                listen: false,
                              );
                              final bool success = await app.resetPassword(
                                resetEmailController.text.trim(),
                              );
                              if (!sheetContext.mounted) {
                                return;
                              }
                              Navigator.pop(sheetContext);
                              _showMessage(
                                success
                                    ? 'Check your email for a reset link.'
                                    : (app.lastError ??
                                        'Could not send reset email.'),
                              );
                            },
                      child: isSending
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4),
                            )
                          : const Text('Send'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    resetEmailController.dispose();
  }

  void _openAppShell() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const AppShell();
        },
      ),
    );
  }

  Future<void> _handleLogin() async {
    final app = Provider.of<AppProvider>(context, listen: false);
    final success = await app.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    final currentUser = app.currentUser;
    if (success && currentUser != null) {
      await _loadUserData(currentUser.id);
      if (!mounted) {
        return;
      }
      Provider.of<ThemeProvider>(context, listen: false)
          .setPaletteByName(currentUser.themePref);
      _openAppShell();
      return;
    }
    _showMessage(app.lastError ?? 'Login failed');
  }

  Future<void> _handleSignUp() async {
    final app = Provider.of<AppProvider>(context, listen: false);
    final String name = _nameController.text.trim();
    final success = await app.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      name,
    );
    if (!mounted) {
      return;
    }
    final currentUser = app.currentUser;
    if (success && currentUser != null) {
      await _loadUserData(currentUser.id);
      if (!mounted) {
        return;
      }
      Provider.of<ThemeProvider>(context, listen: false)
          .setPaletteByName(currentUser.themePref);
      _openAppShell();
      return;
    }
    _showMessage(app.lastError ?? 'Signup failed');
  }

  Future<void> _loadUserData(String userId) async {
    await Provider.of<BlueprintProvider>(context, listen: false)
        .loadForUser(userId);
    await Provider.of<ExecutionProvider>(context, listen: false)
        .fetchMonthData(DateTime.now());
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}