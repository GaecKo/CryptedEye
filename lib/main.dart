// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/test_crypted.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CryptedEye Demo',
      routes: {
      '/login': (context) => LoginPage(),
      '/HomePage': (context) => HomePage(),
      '/HashPage': (context) => HashPage(),
      },
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    ); // Material App
  }
}

