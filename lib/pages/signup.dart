import 'package:flutter/material.dart';
import '../controller.dart';

// @everyone working on this file:
// -> We need a VaultName prompt
//        -> (will contain the name of the Vault, really important for sharing/...)
// -> We need a Password prompt
//        -> 2 prompt: one to set it, one to confirm the password, as its really important not to make a mistake in it
//        -> it shouldn't be possible to copy / paste in these prompts but its a detail
// -> We need a button (for later, not to be worked on rn) to let people add Vault from other sources (from example if they downloaded one)

// -> The code below is simply a basic start template.

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

  // Function to handle the SignUp action
  void _SignUp() {
    // @GaecKo: I will do the logic of that part, just call the _SignUp function from the main button
  }

  @override
  Widget build(BuildContext context) {

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
