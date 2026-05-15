import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youmi_dev/providers/app_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(); 
  final emailController = TextEditingController(); 
  final passwordController = TextEditingController(); 
  final confirmPasswordController = TextEditingController(); 
  final resetEmailController = TextEditingController(); 

  bool isLoginView = true; 
  bool isPasswordObscured = true; 
  bool isConfirmPasswordObscured = true; 

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    resetEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: unused_local_variable
    final appProvider = context.read<AppProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Text(
                    'YOUMI',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (isLoginView) ...[
                    Text('Login', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85, 
                      child: TextFormField(
                        controller: emailController,
                        validator: validateEmail,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                          label: Text("Email"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        controller: passwordController,
                        validator: validatePassword,
                        obscureText: isPasswordObscured,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          label: const Text("Password"),
                          suffixIcon: IconButton(
                            onPressed: () { 
                              setState(() { isPasswordObscured = !isPasswordObscured; }); 
                            },
                            icon: Icon(isPasswordObscured ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Reset Password", style: theme.textTheme.titleLarge),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: resetEmailController, 
                                    decoration: const InputDecoration(border: OutlineInputBorder(), label: Text("Email"))
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context), 
                                    child: const Text("Send")
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          );
                        },
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                        }
                      },
                      child: const Text('LogIn'),
                    ),
                  ],

                  if (!isLoginView) ...[
                    Text('SignUp', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        controller: nameController,
                        validator: validateName,
                        decoration: const InputDecoration(border: OutlineInputBorder(), label: Text("Name")),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        controller: emailController,
                        validator: validateEmail,
                        decoration: const InputDecoration(border: OutlineInputBorder(), label: Text("Email")),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        controller: passwordController,
                        validator: validatePassword,
                        obscureText: isPasswordObscured,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          label: const Text("Password"),
                          suffixIcon: IconButton(
                            onPressed: () { 
                              setState(() { isPasswordObscured = !isPasswordObscured; }); 
                            }, 
                            icon: Icon(isPasswordObscured ? Icons.visibility_off : Icons.visibility)
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        controller: confirmPasswordController,
                        validator: validateConfirmPassword,
                        obscureText: isConfirmPasswordObscured,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          label: const Text("Confirm Password"),
                          suffixIcon: IconButton(
                            onPressed: () { 
                              setState(() { isConfirmPasswordObscured = !isConfirmPasswordObscured; }); 
                            }, 
                            icon: Icon(isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility)
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                        }
                      },
                      child: const Text('SignUp'),
                    ),
                  ],

                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () { 
                      setState(() { isLoginView = !isLoginView; }); 
                    },
                    child: Text(isLoginView ? "New here? SignUp" : "Have Account? LogIn"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateName(String? value) {
    return (value != null && value.isNotEmpty) ? null : "Enter Name";
  }

  String? validateEmail(String? value) {
    return (value != null && value.contains("@")) ? null : "Not a valid Mail";
  }

  String? validatePassword(String? value) {
    return (value != null && value.length > 5) ? null : "Short Password";
  }

  String? validateConfirmPassword(String? value) {
    return (value != null && value == passwordController.text) ? null : "Passwords do not match";
  }
}