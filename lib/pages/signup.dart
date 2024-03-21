import 'package:flutter/material.dart';
import '../controller.dart';

class SignUpPage extends StatefulWidget {
  Controller ctr;

  SignUpPage({super.key, required this.ctr});

  @override
  _SignUpPageState createState() => _SignUpPageState(ctr);
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _passwordController = TextEditingController();
  Controller ctr;

  _SignUpPageState(this.ctr);

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _passwordController.dispose();
    super.dispose();
  }

  void _callSignUp() {
    Navigator.pushReplacementNamed(context, '/SignUp');
  }

  // Function to handle the SignUp action
  void _SignUp() {
    String password = _passwordController.text;
    print('Entered password from SignUpPage: $password');

    // TODO:
    //  SignUp logic

    if (password == 'test') {
      Navigator.pushReplacementNamed(context, '/HashPage', arguments: {'AP' : password});
    } else {
      print('Invalid password');
    }
  }

  @override
  Widget build(BuildContext context) {

    // TODO:
    //  When keyboard appears, widget are moved up and then cropped by the SafeArea
    //  (so they don't go to the very top of the screen)
    // -> This is looking ugly, should be fixed

    // TODO:
    // When keyboard apperas, SignUp button is hidden. It should however be easily clickable and thus visible
    // even with keyboard active
    // -> This should be fix and quite important!

    return const Scaffold(
      backgroundColor: Color.fromRGBO(64, 64, 64, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                SizedBox(height: 50),

                // Top title (lock - name - >SignUp)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 40,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),

                    Text(
                      "CryptedEye",
                      style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      " > Sign-Up",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
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
