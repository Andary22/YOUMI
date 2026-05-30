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
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController resetEmailController = TextEditingController();

  bool isLoginView = true;
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    IconData passwordIcon;
    if (isPasswordObscured) {
      passwordIcon = Icons.visibility_off;
    } else {
      passwordIcon = Icons.visibility;
    }
    IconData confirmPasswordIcon;
    if (isConfirmPasswordObscured) {
      confirmPasswordIcon = Icons.visibility_off;
    } else {
      confirmPasswordIcon = Icons.visibility;
    }
    String toggleText;
    if (isLoginView) {
      toggleText = 'New here? SignUp';
    } else {
      toggleText = 'Have Account? LogIn';
    }
    final List<Widget> formChildren = [];
    formChildren.add(
      Text(
        'YOUMI',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          letterSpacing: 4.0,
        ),
      ),
    );
    formChildren.add(SizedBox(height: 40));
    if (isLoginView) {
      formChildren.add(Text('Login', style: TextStyle(fontSize: 25)));
      formChildren.add(SizedBox(height: 30));
      formChildren.add(
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: TextFormField(
            controller: emailController,
            validator: validateEmail,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
              label: Text("Email"),
            ),
          ),
        ),
      );
      formChildren.add(SizedBox(height: 20));
      formChildren.add(
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: TextFormField(
            controller: passwordController,
            validator: validatePassword,
            obscureText: isPasswordObscured,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
              label: Text("Password"),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isPasswordObscured = !isPasswordObscured;
                  });
                },
                icon: Icon(passwordIcon),
              ),
            ),
          ),
        ),
      );
      formChildren.add(
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 20,
                      right: 20,
                      top: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Reset Password",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: resetEmailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text("Email"),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Text("Send"),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              );
            },
            child: Text('Forgot password?'),
          ),
        ),
      );
      formChildren.add(SizedBox(height: 20));
      formChildren.add(
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              _handleLogin();
            }
          },
          child: Text('LogIn'),
        ),
      );
    } else {
      formChildren.add(Text('SignUp', style: TextStyle(fontSize: 25)));
      formChildren.add(SizedBox(height: 30));
      formChildren.add(
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: TextFormField(
            controller: nameController,
            validator: validateName,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Name"),
            ),
          ),
        ),
      );
      formChildren.add(SizedBox(height: 20));
      formChildren.add(
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: TextFormField(
            controller: emailController,
            validator: validateEmail,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Email"),
            ),
          ),
        ),
      );
      formChildren.add(SizedBox(height: 20));
      formChildren.add(
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: TextFormField(
            controller: passwordController,
            validator: validatePassword,
            obscureText: isPasswordObscured,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Password"),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isPasswordObscured = !isPasswordObscured;
                  });
                },
                icon: Icon(passwordIcon),
              ),
            ),
          ),
        ),
      );
      formChildren.add(SizedBox(height: 20));
      formChildren.add(
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: TextFormField(
            controller: confirmPasswordController,
            validator: validateConfirmPassword,
            obscureText: isConfirmPasswordObscured,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Confirm Password"),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isConfirmPasswordObscured = !isConfirmPasswordObscured;
                  });
                },
                icon: Icon(confirmPasswordIcon),
              ),
            ),
          ),
        ),
      );
      formChildren.add(SizedBox(height: 20));
      formChildren.add(
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              _handleSignUp();
            }
          },
          child: Text('SignUp'),
        ),
      );
    }
    formChildren.add(SizedBox(height: 10));
    formChildren.add(
      TextButton(
        onPressed: () {
          setState(() {
            isLoginView = !isLoginView;
          });
        },
        child: Text(toggleText),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                children: formChildren,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateName(String? s) {
    if (s != null && s.isNotEmpty) {
      return null;
    } else {
      return "Enter Name";
    }
  }

  String? validateEmail(String? s) {
    if (s != null && s.contains("@")) {
      return null;
    } else {
      return "Invalid Email";
    }
  }

  String? validatePassword(String? s) {
    if (s != null && s.length > 5) {
      return null;
    } else {
      return "Password Must be at least 5 letters";
    }
  }

  String? validateConfirmPassword(String? s) {
    if (s != null && s == passwordController.text) {
      return null;
    } else {
      return "Passwords do not match";
    }
  }

  void openAppShell() {
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
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    if (success && app.currentUser != null) {
      await _loadUserData(app.currentUser!.id);
      Provider.of<ThemeProvider>(context, listen: false)
          .setPaletteByName(app.currentUser!.themePref);
      openAppShell();
      return;
    }
    String message = 'Login failed';
    if (app.lastError != null) {
      message = app.lastError!;
    }
    _showError(message);
  }

  Future<void> _handleSignUp() async {
    final app = Provider.of<AppProvider>(context, listen: false);
    final String name = nameController.text.trim();
    final success = await app.signUp(
      emailController.text.trim(),
      passwordController.text.trim(),
      name,
    );
    if (!mounted) {
      return;
    }
    if (success && app.currentUser != null) {
      await _loadUserData(app.currentUser!.id);
      Provider.of<ThemeProvider>(context, listen: false)
          .setPaletteByName(app.currentUser!.themePref);
      openAppShell();
      return;
    }
    String message = 'Signup failed';
    if (app.lastError != null) {
      message = app.lastError!;
    }
    _showError(message);
  }

  Future<void> _loadUserData(String userId) async {
    await Provider.of<BlueprintProvider>(context, listen: false)
        .loadForUser(userId);
    await Provider.of<ExecutionProvider>(context, listen: false)
        .fetchMonthData(DateTime.now());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
