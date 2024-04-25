// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

import 'package:restart_app/restart_app.dart';

import 'controller.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/settings.dart';
import 'pages/signup.dart';
import 'pages/welcome.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Controller ctr = await Controller.create();
  bool isStartup = ctr.isStartup();

  // create app observer and add it to App, so when it get closed we can
  // close the app cleanly
  MyAppLifecycleObserver observer = MyAppLifecycleObserver(ctr: ctr);
  WidgetsBinding.instance.addObserver(observer);

  runApp(CryptedEye(
    ctr: ctr,
    isStartup: isStartup,
  ));
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
      firstPage = WelcomePage();

    } else {
      firstPage = LoginPage(ctr: ctr);
    }

    return MaterialApp(
      title: 'CryptedEye',
      routes: {
        '/login': (context) => LoginPage(ctr: ctr),
        '/HomePage': (context) => HomePage(ctr: ctr),
        '/SignUp': (context) => SignUpPage(ctr: ctr),
        '/Settings': (context) => SettingsPage(ctr: ctr),
        '/Welcome': (context) => WelcomePage()
      },
      home: firstPage,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionHandleColor: Colors.black, // Couleur de la poignée de sélection
          selectionColor: Colors.black.withOpacity(0.3), // Couleur de la sélection
        ),
      ),
      builder: (BuildContext context, Widget? widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return CustomError(errorDetails: errorDetails);
        };

        return widget as Widget;
      },
    );
  }
}

class MyAppLifecycleObserver with WidgetsBindingObserver {
  Controller ctr;

  MyAppLifecycleObserver({required this.ctr});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("changing to ${state.toString()}");
    if (state == AppLifecycleState.paused) {
      ctr.closeApp();
      // Perform cleanup when the app is paused (e.g., closed).
      // Call your cleanup functions here.
      Restart.restartApp();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      ctr.closeApp();
    }
  }
}

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomError({super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "We are sorry, CryptedEye ran through an unhandled error. Please try restarting the app."
              "\nIf this came from importing a vault image, then the vault must be corrupted, try exporting it properly again."
              "\nIf the error persists, you can also contact the dev team at ",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
