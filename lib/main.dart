// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/signup.dart';

import 'controller.dart';

void main() async {

  Controller ctr = await Controller.create();

  runApp(CryptedEye(ctr: ctr));
}

class CryptedEye extends StatelessWidget {
  Controller ctr;

  CryptedEye({super.key, required this.ctr});

  @override
  Future<Widget> build(BuildContext context) async {

    return MaterialApp(
      title: 'CryptedEye',
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

