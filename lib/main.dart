// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/signup.dart';

import 'controller.dart';

import 'package:restart_app/restart_app.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Controller ctr = await Controller.create();
  bool isStartup = ctr.isStartup();

  // create app observer and add it to App, so when it get closed we can
  // close the app cleanly
  MyAppLifecycleObserver observer = MyAppLifecycleObserver(ctr: ctr);
  WidgetsBinding.instance.addObserver(observer);

  runApp(CryptedEye(ctr: ctr, isStartup: isStartup,));
}

class CryptedEye extends StatelessWidget {
  final Controller ctr;
  final bool isStartup;

  const CryptedEye({super.key, required this.ctr, required this.isStartup});

  @override
  Widget build(BuildContext context) {

    Widget firstPage;
    if (isStartup) {
      // put singup as first page and create settings.json file
      firstPage = SignUpPage(ctr: ctr);
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

    );
  }

}

class MyAppLifecycleObserver with WidgetsBindingObserver {
  Controller ctr;

  MyAppLifecycleObserver({required this.ctr});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ctr.closeApp();
      // Perform cleanup when the app is paused (e.g., closed).
      // Call your cleanup functions here.
    }
    Restart.restartApp();

  }
}
