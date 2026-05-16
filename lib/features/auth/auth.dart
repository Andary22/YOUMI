import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Text(
                    'YOUMI',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                    ),
                  ),
                  SizedBox(height: 40),

                  if (isLoginView) ...[
                    Text('Login', style: TextStyle(fontSize: 25)),
                    SizedBox(height: 30),
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
                    SizedBox(height: 20),
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
                            icon: Icon(
                              isPasswordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
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
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
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
                            ),
                          );
                        },
                        child: Text('Forgot password?'),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (formKey.currentState!.validate()) {
                            // Login Code Here
                          }
                        });
                      },
                      child: Text('LogIn'),
                    ),
                  ],

                  if (!isLoginView) ...[
                    Text('SignUp', style: TextStyle(fontSize: 25)),
                    SizedBox(height: 30),
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
                    SizedBox(height: 20),
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
                    SizedBox(height: 20),
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
                            icon: Icon(
                              isPasswordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
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
                                isConfirmPasswordObscured =
                                    !isConfirmPasswordObscured;
                              });
                            },
                            icon: Icon(
                              isConfirmPasswordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (formKey.currentState!.validate()) {
                            // Sign Up Code Here
                          }
                        });
                      },
                      child: Text('SignUp'),
                    ),
                  ],

                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLoginView = !isLoginView;
                      });
                    },
                    child: Text(
                      isLoginView ? "New here? SignUp" : "Have Account? LogIn",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateName(String? s) {
    if (s != null && s.isNotEmpty)
      return null;
    else
      return "Enter Name";
  }

  String? validateEmail(String? s) {
    if (s != null && s.contains("@"))
      return null;
    else
      return "Invalid Email";
  }

  String? validatePassword(String? s) {
    if (s != null && s.length > 5)
      return null;
    else
      return "Password Must be at least 5 letters";
  }

  String? validateConfirmPassword(String? s) {
    if (s != null && s == passwordController.text)
      return null;
    else
      return "Passwords do not match";
  }
}
