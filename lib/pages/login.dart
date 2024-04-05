import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller.dart';

class LoginPage extends StatefulWidget {
  Controller ctr;

  LoginPage({super.key, required this.ctr});

  @override
  _LoginPageState createState() => _LoginPageState(ctr);
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordController = TextEditingController();
  Controller ctr;
  Color _passwordContainerColor =  Colors.red;
  String? _passwordError;

  _LoginPageState(this.ctr);

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _passwordController.dispose();
    super.dispose();
  }

  void _callSignUp() {
    Navigator.pushReplacementNamed(context, '/SignUp');
  }

  // Function to handle the login action
  void _login() async {
    String password = _passwordController.text;
    print('Entered password from LoginPage: $password');

    String tempVaultName = ctr.getTempOnlyVault();
    print("temp vault name: $tempVaultName");

    if (ctr.verifyPassword(password, tempVaultName)) {
      await ctr.loadApp(password, tempVaultName);
      Navigator.pushReplacementNamed(context, '/HomePage');
    } else {
      print('Invalid password');
      setState(() {
        _passwordContainerColor = Colors.red; // Set color to red
        _passwordError = 'Invalid password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Lorsque le clavier apparaît, les widgets sont déplacés vers le haut et ensuite coupés par le SafeArea
    // (pour qu'ils ne se rendent pas tout en haut de l'écran)
    // -> Cela ne semble pas esthétique, cela devrait être corrigé

    // TODO: Lorsque le clavier apparaît, le bouton de connexion est masqué. Il devrait cependant être facilement cliquable et donc visible
    // même avec le clavier actif
    // -> Ceci devrait être corrigé et assez important !

    return Scaffold(
      backgroundColor: const Color.fromRGBO(64, 64, 64, 1),
      resizeToAvoidBottomInset: true, // Ajustement automatique lorsque le clavier apparaît
      body: SafeArea(
        child: SingleChildScrollView( // Envelopper dans SingleChildScrollView pour faire défiler lorsque le clavier apparaît
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // Titre en haut (icône de verrouillage - nom - > connexion)
                const Row(
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
                      " > Login",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Icône de profil
                const Icon(
                  Icons.account_circle_rounded,
                  size: 200,
                  color: Colors.black,
                ),
                const SizedBox(height: 50),
                // Texte de connexion
                Text(
                  "Login to Vault '${ctr.getTempOnlyVault()}'",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                
                // Text field for error message
                Text(
                  _passwordError ?? '', 
                  style: TextStyle(
                    color: Colors.red, 
                    fontSize: 12.0, 
                  ),
                ),

                // Container for password field
                Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      top: BorderSide(width: 3.0, color: _passwordContainerColor),
                      bottom: BorderSide(width: 3.0, color: _passwordContainerColor),
                      left: BorderSide(width: 3.0, color: _passwordContainerColor),
                      right: BorderSide(width: 3.0, color: _passwordContainerColor),
                    ),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: "> Access Password",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.black),
                    obscureText: true,
                    onSubmitted: (_) {
                      _login(); // Call the _login function when the "OK" button is pressed
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Bouton de connexion
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _login();
                      },
                      borderRadius: BorderRadius.circular(10.0),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Access vault",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
