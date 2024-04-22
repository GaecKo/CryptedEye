import 'package:encrypt/encrypt.dart' as E;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    Navigator.pushReplacementNamed(context, '/login');
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
      _vaultError =
      "Vault can't have the same name as other already created vaults";
      _vaultColor = Colors.red;
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
          style:
          TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
        ));

    List<String> vaults = ctr.getListOfVault();
    if (vaults.length > 0) {
      canLog = login;
      title = " > New Vault";
    } else {
      canLog = const SizedBox();
      title = " > Sign-Up";
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(64, 64, 64, 1),
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start, // Changer cette ligne
                  children: [
                    SizedBox(height: 50), // Espacement supplémentaire vers le haut
                    Padding(
                      padding: EdgeInsets.only(left: 30, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Logo en haut à gauche
                          Icon(
                            Icons.lock,
                            size: 100,
                            color: Colors.white,
                          ),
                          // Espacement entre le logo et le texte
                          SizedBox(width: 20),
                          // Utiliser Flexible ou Expanded pour le texte
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerLeft, // Aligner le texte à gauche
                              child: Text(
                                "Chaque vault est comme un coffre-fort numérique privé, où vous pouvez stocker en toute sécurité vos données sensibles",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Georgia', // Remplace "NomDeTaPolice" par le nom de ta police
                                  // Autres styles de texte que tu souhaites appliquer
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 60),
                    Padding(
                      padding: EdgeInsets.only(left: 30, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Notre système génère une clé unique, accompagnée d'un salt spécifique à votre vault. Cela signifie que même si deux utilisateurs ont le même mot de passe, les clés générées seront différentes.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Icon(
                            Icons.lock,
                            size: 100,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
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

                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: _VaultNameController,
                            decoration: InputDecoration(
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
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.white),
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
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
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
                          ),
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _signUp,
                          child: const Text('Create Vault'),
                        ),
                        canLog,
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

