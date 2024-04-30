import 'dart:async';

import 'package:encrypt/encrypt.dart' as E;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../controller.dart';

Future<E.Key> callCrypterInit(List<dynamic> args) async {
  String AP = args[1];
  String VaultName = args[2];
  return await args[0].getCrypterKey(AP, VaultName);
}

class LoginPage extends StatefulWidget {
  final Controller ctr;

  LoginPage({Key? key, required this.ctr}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState(ctr: ctr);
}

class _LoginPageState extends State<LoginPage> {
  Controller ctr;
  final TextEditingController _passwordController = TextEditingController();
  Color _passwordContainerColor = Colors.white;
  String? _passwordError;
  late String _selectedVault;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  _LoginPageState({required this.ctr});

  @override
  void initState() {
    super.initState();
    _selectedVault = widget.ctr.getListOfVault().first;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleVaultChanged(String newValue) {
    setState(() {
      _selectedVault = newValue;
    });
  }

  void _callSignUp() {
    Navigator.pushReplacementNamed(context, '/SignUp');
  }

  void _login() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    String password = _passwordController.text;

    print("Selected vault name from LoginPage: $_selectedVault");

    if (ctr.verifyPassword(password, _selectedVault)) {
      print("Access to vault ${_selectedVault} agreed");

      E.Key key =
          await compute(callCrypterInit, [ctr, password, _selectedVault]);

      ctr.loadApp(password, _selectedVault, key);

      Navigator.pushReplacementNamed(context, '/HomePage');
    } else {
      // Incorrect password handling
      print('Invalid password');

      await Future.delayed(Duration(seconds: 1));

      setState(() {
        _passwordContainerColor = Colors.red;
        _passwordError = 'Invalid password';
        _isLoading = false;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(64, 64, 64, 1),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      " > Login",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Image.asset(
                  "lib/images/login_back3.png",
                  width: 300,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Login to Vault:",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButtonVault(
                  values: widget.ctr.getListOfVault(),
                  onChanged: _handleVaultChanged,
                ),
                Text(
                  _passwordError ?? '',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12.0,
                  ),
                ),
                Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 3.0,
                      color: _passwordContainerColor,
                    ),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: "> Access Password",
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                    obscureText:
                        !_isPasswordVisible, // Utilisation de l'état de visibilité pour masquer ou afficher le mot de passe
                    onChanged: (_) {
                      setState(() {
                        _passwordError = null;
                        _passwordContainerColor = Colors.white;
                      });
                    },
                    onSubmitted: (_) {
                      _login();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Container(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                const SizedBox(height: 10),
                InkWell(
                  onTap: _callSignUp,
                  child: _isLoading
                      ? const SizedBox()
                      : const Text(
                          "New Vault? Create One!",
                          style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_horiz,
        activeIcon: Icons.close,
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        animatedIconTheme: const IconThemeData(size: 22.0),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.import_export),
            backgroundColor: Colors.blue,
            label: 'Import Vault',
            labelStyle: const TextStyle(fontSize: 16.0),
            onTap: () {
              _showImportConfirmationDialog(context);
              setState(() {});
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.question_mark),
            backgroundColor: Colors.grey,
            label: 'How does it work?',
            labelStyle: const TextStyle(fontSize: 16.0),
            onTap: () {
              Navigator.of(context).pushReplacementNamed("/Welcome");
            },
          ),
        ],
      ),
    );
  }

  void _showImportConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Import new Vault'),
          content: const Text('Are you sure you want to import new Vault ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (await widget.ctr.importData()) {
                  Navigator.of(context).pop();
                  _showImportSuccessMessage(context);
                } else {
                  Navigator.of(context).pop();
                  _showImportFailureMessage(context);
                }
                setState(() {});
              },
              child: const Text('Import'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showImportSuccessMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Import Successful'),
          content: const Text('Your data has been imported successfully !'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showImportFailureMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Import Failed'),
          content: const Text(
              "Your data wasn't imported, please retry. Make sure you selected a valid Vault image. The file name should finish with '.CryptedEye.tar'. Make sure you don't already have a vault with the same name."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class DropdownButtonVault extends StatefulWidget {
  final List<String> values;
  final ValueChanged<String> onChanged;

  DropdownButtonVault({
    Key? key,
    required this.values,
    required this.onChanged,
  }) : super(key: key);

  @override
  _DropdownButtonVaultState createState() => _DropdownButtonVaultState();
}

class _DropdownButtonVaultState extends State<DropdownButtonVault> {
  late String _curVal;

  @override
  void initState() {
    super.initState();
    _curVal = widget.values.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: DropdownButton<String>(
        value: _curVal,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 16,
        dropdownColor: Colors.grey,
        borderRadius: BorderRadius.circular(10),
        isExpanded: true,
        style: const TextStyle(color: Colors.white),
        underline: Container(
          height: 2,
          color: Colors.blue,
        ),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              _curVal = value;
            });
            widget.onChanged(value);
          }
        },
        items: widget.values.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
            alignment: Alignment.center,
          );
        }).toList(),
      ),
    );
  }
}
