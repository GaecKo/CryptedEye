// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/signup.dart';

import 'controller.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Controller ctr = await Controller.create();
  bool isStartup = await ctr.isStartup();

  runApp(CryptedEye(ctr: ctr, isStartup: isStartup,));
}

class CryptedEye extends StatelessWidget {
  Controller ctr;
  bool isStartup;

  CryptedEye({super.key, required this.ctr, required this.isStartup});

  @override
  Widget build(BuildContext context) {

    Widget firstPage;
    if (isStartup) {
      // put singup as first page and create settings.json file
      firstPage = SignUpPage(ctr: ctr);
      ctr.createAppSettingFile();
    } else {
      firstPage = LoginPage(ctr: ctr);
    }

    return MaterialApp(
      title: 'CryptedEye',
      routes: {
      '/login': (context) => LoginPage(ctr: ctr),
      '/HomePage': (context) => HomePage(ctr:ctr),
      '/SignUp': (context) => SignUpPage(ctr: ctr)
      },
      home: firstPage,
      debugShowCheckedModeBanner: false,
    ); // Material App
  }

}

