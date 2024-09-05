import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _password, _username, _firstName, _lastName;
  Uri url = Uri.http("192.168.165.50:3000", "auth/signup");
  bool _uploading = false;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String? urlDownload;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signup"),
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
                Row(
                  children: [
                    
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Enter Some text";
                          } else if (value.length < 5) {
                            return "Please enter first name with 5 or more letters";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _firstName = newValue;
                        },
                        decoration: const InputDecoration(
                          label: Text("First Name"),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Enter Some text";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _lastName = newValue;
                        },
                        decoration: const InputDecoration(
                          label: Text("Last Name"),
                        ),
                      ),
                    ),
                  ],
                ),
                

                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles();
                        if (result == null) {
                          return;
                        }
                        setState(() {
                          pickedFile = result.files.first;
                        });
                      },
                      child: const Text("upload Profile photo"),
                    ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
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
                  decoration: const InputDecoration(
                    label: Text("Password"),
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
                            builder: (ctx) => LoginScreen(),
                          ),
                        );
                      },
                      child: const Text("already have an account"),
                    ),
                    ElevatedButton(
                      onPressed: _uploading
                          ? () {}
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                setState(() {
                                  _uploading = true;
                                });
                                final path = 'files/${pickedFile!.name}';
                                final file = File(pickedFile!.path!);
                                final reference =
                                    FirebaseStorage.instance.ref().child(path);

                                try {
                                  setState(() {
                                    uploadTask = reference.putFile(file);
                                  });

                                  final snapshot =
                                      await uploadTask!.whenComplete(() {});

                                  urlDownload =
                                      await snapshot.ref.getDownloadURL();
                                  final response = await http.post(
                                    url,
                                    headers: {
                                      'Content-Type': 'application/json',
                                    },
                                    body: json.encode(
                                      {
                                        'username': _username!.trim(),
                                        'firstName': _firstName!.trim(),
                                        'lastName': _lastName!.trim(),
                                        'dpLink': urlDownload,
                                        'password': _password!.trim(),
                                      },
                                    ),
                                  );
                                  print("body:");
                                  print(response.body);
                                  if (!json.decode(response.body)["success"] &&
                                      context.mounted) {
                                    if (json
                                        .decode(response.body)["userExist"]) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text(
                                            "User already exists,Try loggin in",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("okey"))
                                          ],
                                        ),
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text(
                                            "Signup Failed,Try Again",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("okey"))
                                          ],
                                        ),
                                      );
                                    }
                                  } else if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text(
                                          "Signup Success",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (ctx) =>
                                                          const MainPage()),
                                                );
                                              },
                                              child: const Text("Ok"))
                                        ],
                                      ),
                                    );
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                      'token',
                                      json.decode(response.body)["data"]
                                          ["token"],
                                    );
                                  }
                                } catch (error) {
                                  print("error occured while signing up");
                                  print(error);
                                }
                              }
                              setState(() {
                                _uploading = false;
                              });
                            },
                      child: _uploading
                          ? const CircularProgressIndicator()
                          : const Text("Signup"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
