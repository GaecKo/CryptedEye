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

class SignUpPage extends StatefulWidget {
  final Controller ctr;

  const SignUpPage({super.key, required this.ctr});

  @override
  _SignUpPageState createState() => _SignUpPageState(ctr);
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _VaultNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  Controller ctr;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _vaultError;
  Color _vaultColor = Colors.white;
  Color _passwordContainerColor = Colors.white;
  Color _confirmPasswordContainerColor = Colors.white;

  bool _isLoading = false;

  _SignUpPageState(this.ctr);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _callLogIn() {
    Navigator.pushReplacementNamed(context, '/Login');
  }

  void _signUp() async {
    String VaultName = _VaultNameController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (VaultName.isEmpty || VaultName.length < 2) {
      setState(() {
        _vaultError = "Vault name must be at least 2 characters long";
        _vaultColor = Colors.red;
      });
    } else if (ctr.getListOfVault().contains(VaultName)) {
      setState(() {
        _vaultError =
            "Vault can't have the same name as other already created vaults";
        _vaultColor = Colors.red;
      });
    } else if (password.isEmpty || confirmPassword.isEmpty) {
      // Show error message for empty fields and change container color
      setState(() {
        _passwordError = 'Password fields are required';
        _confirmPasswordError = 'Password fields are required';
        _passwordContainerColor = Colors.red;
        _confirmPasswordContainerColor = Colors.red;
      });
      print("Password fields are required");
    } else if (password != confirmPassword) {
      // Show error message for mismatched passwords and change container color
      setState(() {
        _passwordError = 'Passwords do not match';
        _confirmPasswordError = 'Passwords do not match';
        _passwordContainerColor = Colors.red;
        _confirmPasswordContainerColor = Colors.red;
      });
      print("Passwords do not match");
    } else {
      // Reset error messages and container colors
      setState(() {
        _passwordError = null;
        _confirmPasswordError = null;
        _vaultError = null;
        _vaultColor = Colors.white;
        _passwordContainerColor = Colors.white;
        _confirmPasswordContainerColor = Colors.white;
        _isLoading = true;
      });
      print("Passwords match");

      // 1. init the vault, create files, salt, ...
      await ctr.initApp(password, VaultName);

      // 2. using the created salt, ..., compute the crypter (high computation time)
      E.Key key = await compute(callCrypterInit, [ctr, password, VaultName]);

      // 3. finaly, apply retrieved key to app, and load it.
      ctr.loadApp(password, VaultName, key);

      Navigator.pushReplacementNamed(context, '/HomePage');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget canLog;
    String title;

    Widget login = InkWell(
        onTap: _callLogIn,
        child: _isLoading
            ? const SizedBox()
            : const Text(
                "Connect to existing Vault",
                style: TextStyle(
                  shadows: [Shadow(color: Colors.white, offset: Offset(0, -5))],
                  fontStyle: FontStyle.italic,
                  color: Colors.transparent,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue,
                  decorationThickness: 3,
                  decorationStyle: TextDecorationStyle.dashed,
                ),
              ));

    int nbVaults = ctr.getListOfVault().length;
    if (nbVaults > 0) {
      canLog = login;
      title = " > New Vault";
    } else {
      canLog = const SizedBox();
      title = " > Sign-Up";
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(64, 64, 64, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alignement à gauche
                  children: [
                    const SizedBox(
                        height:
                            20), // Espace entre l'IconButton et le reste des éléments
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "CryptedEye",
                          style: TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Image.asset(
                  "lib/images/signup.png",
                  width: 300,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      maxLength: 20,
                      controller: _VaultNameController,
                      decoration: InputDecoration(
                        counterStyle: const TextStyle(color: Colors.white),
                        labelText: 'Vault Name',
                        errorText: _vaultError,
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: _vaultColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: _vaultColor),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: _passwordContainerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: _passwordContainerColor),
                        ),
                        errorText: _passwordError,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: _confirmPasswordContainerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: _confirmPasswordContainerColor),
                        ),
                        errorText: _confirmPasswordError,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onFieldSubmitted: (_) {
                        _signUp();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      )
                    : ElevatedButton(
                        onPressed: _signUp,
                        child: const Text('Create Vault'),
                      ),
                const SizedBox(
                  height: 10,
                ),
                canLog,
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
