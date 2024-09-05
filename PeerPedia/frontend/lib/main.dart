import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/providers/user_provider.dart';

import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ProviderScope(
    child: MaterialApp(
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 51, 70, 211),
        ),
        
        cardTheme: const CardTheme()
            .copyWith(color: const Color.fromARGB(255, 255, 255, 255)),
        scaffoldBackgroundColor: const Color.fromARGB(255, 242, 246, 255),
    
        appBarTheme: const AppBarTheme()
            .copyWith(color: const Color.fromARGB(255, 242, 246, 255)),
            
        
        
      ),

      home: const MainPage(),
    ),
  ));
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  String? token;
  Widget? mainPage;
  Uri url = Uri.http("192.168.165.50:3000", "auth/checklogin");

  void getToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
    checkLogin();
  }

  void checkLogin() async {
    if (token != null) {
      if (token!.isNotEmpty) {
        try {
          final response = await http.get(url, headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          });
          if (json.decode(response.body)["success"]) {
            final UserModel user = UserModel(
                firstName: json.decode(response.body)["data"]["firstName"],
                lastName: json.decode(response.body)["data"]["lastName"],
                username: json.decode(response.body)["data"]["username"],
                dpLink: json.decode(response.body)["data"]["dpLink"],
                );

            ref.read(userProvider.notifier).setUser(user);
            setState(() {
              mainPage = MainScreen(user: user);
            });
          } else {
            setState(() {
              mainPage = const LoginScreen();
            });
          }
        } catch (error) {
          print("=====> Token Authentication error :");
          print(error);
        }
      } else {
        setState(() {
          mainPage = const LoginScreen();
        });
      }
    } else {
      setState(() {
        mainPage = const LoginScreen();
      });
    }
  }

  @override
  void initState() {
    getToken();
    setState(() {
      mainPage = const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return mainPage!;
  }
}
