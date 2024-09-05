import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/signup_screen.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _password, _username;
  Uri url = Uri.http("192.168.165.50:3000", "auth/login");
  bool _uploading = false;
  bool _passwordHide = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter Some text";
                    } else if (value.length < 3) {
                      return "Please enter username with 3 or more letters";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _username = newValue;
                  },
                  decoration: const InputDecoration(
                    label: Text("Username"),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: _passwordHide,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter Some text";
                    } else if (value.length < 6) {
                      return "Please enter password with 6 or more letters";
                    }
                    return null;
                  },
    
                  onSaved: (newValue) {
                    _password = newValue;
                  },
                  decoration: InputDecoration(
                    label: const Text("Password"),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordHide = !_passwordHide;
                        });
                      },
                      icon: Icon(_passwordHide
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (ctx) => const SignupScreen()),
                        );
                      },
                      child: const Text("create account"),
                    ),
                    ElevatedButton(
                      onPressed: _uploading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                setState(() {
                                  _uploading = true;
                                });
                                try {
                                  final response = await http.post(
                                    url,
                                    headers: {
                                      'Content-Type': 'application/json',
                                    },
                                    body: json.encode(
                                      {
                                        'username': _username!.trim(),
                                        'password': _password!.trim(),
                                      },
                                    ),
                                  );
                                  if (!json.decode(response.body)["success"] &&
                                      context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text(
                                          "Wrong username or password",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("ok"))
                                        ],
                                      ),
                                    );
                                  } else {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                      'token',
                                      json.decode(response.body)["data"]
                                          ["token"],
                                    );
                                    if (context.mounted) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (ctx) => const MainPage()
                                        ),
                                      );
                                    }
                                  }
                                } catch (error) {
                                  print("error occured while logging in");
                                  print(error);
                                }
                              }
                              setState(() {
                                _uploading = false;
                              });
                            },
                      child: _uploading
                          ? const CircularProgressIndicator()
                          : const Text("Login"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
