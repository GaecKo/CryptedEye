import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle the login action
  void _login() {
    String password = _passwordController.text;
    print('Entered password from LoginPage: $password');

    // TODO:
    //  login logic

    if (password == 'test') {
      Navigator.pushReplacementNamed(context, '/HomePage', arguments: {'AP' : password});
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
    // When keyboard apperas, login button is hidden. It should however be easily clickable and thus visible
    // even with keyboard active
    // -> This should be fix and quite important!

    return Scaffold(
      backgroundColor: const Color.fromRGBO(64, 64, 64, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const SizedBox(height: 50),

                // Top title (lock - name - >login)
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

                // Profile Icon
                const Icon(
                  Icons.account_circle_rounded,
                  size: 200,
                  color: Colors.black,
                ),


                const SizedBox(height: 50),

                // Login text
                const Text(
                  "Login to Vault",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                const SizedBox(height: 50),

                // password prompt
                Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: "> Access Password",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.black),
                    obscureText: true,
                  ),
                ),


                const SizedBox(height: 10),

                // Login Button
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
