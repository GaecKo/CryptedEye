import 'package:flutter/material.dart';

import '../controller.dart';

class LoginPage extends StatefulWidget {
  final Controller ctr;

  LoginPage({Key? key, required this.ctr}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState(ctr: ctr);
}

class _LoginPageState extends State<LoginPage> {
  // Logic of Front - Controller
  Controller ctr;

  // Front-End controllers / ...
  final TextEditingController _passwordController = TextEditingController();
  Color _passwordContainerColor = Colors.red;
  String? _passwordError;
  late String _selectedVault;

  void _handleVaultChanged(String newValue) {
    setState(() {
      _selectedVault = newValue;
    });
  }

  _LoginPageState({required this.ctr});

  @override
  void initState() {
    super.initState();
    _selectedVault =
        widget.ctr.getListOfVault().first; // Initialize with the first value
  }

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
    print("Selected vault name from LoginPage: $_selectedVault");
    print('Entered password from LoginPage: $password');
    if (ctr.verifyPassword(password, _selectedVault)) {
      print("Access to vault ${_selectedVault} agreed");
      await ctr.loadApp(password, _selectedVault);
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
      resizeToAvoidBottomInset:
          true, // Ajustement automatique lorsque le clavier apparaît
      body: SafeArea(
        child: SingleChildScrollView(
          // Envelopper dans SingleChildScrollView pour faire défiler lorsque le clavier apparaît
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
                const SizedBox(height: 30),
                // Texte de connexion
                const Text(
                  "Login to Vault:",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // DropDown selector:
                DropdownButtonVault(
                  values: widget.ctr.getListOfVault(),
                  onChanged: _handleVaultChanged,
                ),
                // Text field for error message
                Text(
                  _passwordError ?? '',
                  style: const TextStyle(
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
                      top: BorderSide(
                          width: 3.0, color: _passwordContainerColor),
                      bottom: BorderSide(
                          width: 3.0, color: _passwordContainerColor),
                      left: BorderSide(
                          width: 3.0, color: _passwordContainerColor),
                      right: BorderSide(
                          width: 3.0, color: _passwordContainerColor),
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
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DropdownButtonVault extends StatefulWidget {
  final List<String> values;
  final ValueChanged<String> onChanged;

  DropdownButtonVault({Key? key, required this.values, required this.onChanged})
      : super(key: key);

  @override
  State<DropdownButtonVault> createState() => _DropdownButtonVaultState();
}

class _DropdownButtonVaultState extends State<DropdownButtonVault> {
  late String _curVal;

  @override
  void initState() {
    super.initState();
    _curVal = widget.values.first; // Initialize with the first value
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
            widget.onChanged(value); // Notify parent widget about the change
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
