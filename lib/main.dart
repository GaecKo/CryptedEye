// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/signup.dart';

import 'controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  Controller ctr = Controller.create();

  @override
  Widget build(BuildContext context) {



    return MaterialApp(
      title: 'CryptedEye Demo',
      routes: {
      '/login': (context) => LoginPage(ctr: ctr),
      '/HomePage': (context) => HomePage(ctr:ctr),
      '/SignUp': (context) => SignUpPage(ctr: ctr)
      },
      home: LoginPage(ctr: ctr),
      debugShowCheckedModeBanner: false,
    ); // Material App
  }
}

