import 'package:flutter/material.dart';
import '../controller.dart';

class SignUpPage extends StatefulWidget {
  final Controller ctr;

  SignUpPage({Key? key, required this.ctr}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState(ctr);
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _VaultNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  Controller ctr;
  String? _passwordError;
  String? _confirmPasswordError;
  Color _passwordContainerColor = Colors.white;
  Color _confirmPasswordContainerColor = Colors.white;

  _SignUpPageState(this.ctr);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    String VaultName = _VaultNameController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    setState(() {
      if (password.isEmpty || confirmPassword.isEmpty) {
        // Show error message for empty fields and change container color
        _passwordError = 'Password fields are required';
        _confirmPasswordError = 'Password fields are required';
        _passwordContainerColor = Colors.red;
        _confirmPasswordContainerColor = Colors.red;
        print("Password fields are required");
      } else if (password != confirmPassword) {
        // Show error message for mismatched passwords and change container color
        _passwordError = 'Passwords do not match';
        _confirmPasswordError = 'Passwords do not match';
        _passwordContainerColor = Colors.red;
        _confirmPasswordContainerColor = Colors.red;
        print("Passwords do not match");
      } else {
        // Reset error messages and container colors
        _passwordError = null;
        _confirmPasswordError = null;
        _passwordContainerColor = Colors.white;
        _confirmPasswordContainerColor = Colors.white;
        print("Passwords match");
        ctr.initApp(password, VaultName);
        Navigator.pushReplacementNamed(context, '/HomePage');

        // Passwords match, proceed with signup logic
        // You can call your signup function here
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(64, 64, 64, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
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
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _VaultNameController,
                    decoration: InputDecoration(
                      labelText: 'Vault Name',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
               
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _passwordContainerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _passwordContainerColor),
                      ),
                      errorText: _passwordError,
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _confirmPasswordContainerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _confirmPasswordContainerColor),
                      ),
                      errorText: _confirmPasswordError,
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
