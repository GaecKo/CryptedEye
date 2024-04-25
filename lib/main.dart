// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

import 'package:restart_app/restart_app.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

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

  AwesomeNotifications().initialize(null, [NotificationChannel(
    channelKey: "cryptedeye",
    channelName: "CryptedEye",
    channelDescription: "Channel Notification for auto log-out"
  )], debug: true);

  // create app observer and add it to App, so when it get closed we can
  // close the app cleanly
  MyAppLifecycleObserver observer = MyAppLifecycleObserver(ctr: ctr);
  WidgetsBinding.instance.addObserver(observer);

  runApp(CryptedEye(
    ctr: ctr,
    isStartup: isStartup,
  ));
}

class CryptedEye extends StatefulWidget {
  final Controller ctr;
  final bool isStartup;

  const CryptedEye({super.key, required this.ctr, required this.isStartup});

  @override
  State<CryptedEye> createState() => _CryptedEyeState();
}

class _CryptedEyeState extends State<CryptedEye> {

  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((allowed) {
      if (!allowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget firstPage;
    if (widget.isStartup) {
      // put singup as first page and create settings.json file
      firstPage = WelcomePage();

    } else {
      firstPage = LoginPage(ctr: widget.ctr);
    }

    return MaterialApp(
      title: 'CryptedEye',
      routes: {
        '/login': (context) => LoginPage(ctr: widget.ctr),
        '/HomePage': (context) => HomePage(ctr: widget.ctr),
        '/SignUp': (context) => SignUpPage(ctr: widget.ctr),
        '/Settings': (context) => SettingsPage(ctr: widget.ctr),
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
  bool notif = false;

  MyAppLifecycleObserver({required this.ctr});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {

    if (notif == true && ctr.initialized && state == AppLifecycleState.resumed) {
      AwesomeNotifications().cancel(10);
    }

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      ctr.closeApp();
      // Restart.restartApp();
      if (ctr.initialized && notif == false) {
        print("Creating notification");
        notif == true;
        await Future.delayed(Duration(seconds: 5)).then((_) {
          AwesomeNotifications().createNotification(
              content: NotificationContent(
                  id: 10,
                  channelKey: "cryptedeye",
                  title: "CryptedEye will log-out in 30 seconds",
                  body: "For your data security, CryptedEye will log-out in 30 seconds. Click to come back to app",
                  locked: false,
                chronometer: Duration(seconds: 30)
              )
          );
        });

      }



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
