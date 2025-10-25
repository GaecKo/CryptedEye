import 'dart:math' as math;

import 'package:encrypt/encrypt.dart' as E;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:math';

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

  // Validation states
  bool _vaultNameValid = false;
  bool _vaultNameTouched = false;
  bool _passwordValid = false;
  bool _passwordTouched = false;
  bool _confirmPasswordValid = false;
  bool _confirmPasswordTouched = false;

  // Error messages
  String? _vaultError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Password strength
  double _passwordStrength = 0.0;
  String _passwordStrengthText = "Empty";
  Color _passwordStrengthColor = Colors.grey;

  bool _isLoading = false;

  _SignUpPageState(this.ctr);

  @override
  void initState() {
    super.initState();
    // Add listeners to update validation in real-time
    _VaultNameController.addListener(_validateVaultName);
    _passwordController.addListener(_validatePassword);
    _passwordController.addListener(_calculatePasswordStrength);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _VaultNameController.removeListener(_validateVaultName);
    _passwordController.removeListener(_validatePassword);
    _passwordController.removeListener(_calculatePasswordStrength);
    _confirmPasswordController.removeListener(_validateConfirmPassword);
    _VaultNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }



  void _calculatePasswordStrength() {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthText = "Empty";
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    // ---- Determine character pool size ----
    int poolSize = 0;
    if (password.contains(RegExp(r'[a-z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[A-Z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[0-9]'))) poolSize += 10;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=;\\[\]\\|`~]'))) poolSize += 33;

        // Fallback: if something odd, assume at least lowercase
        if (poolSize == 0) poolSize = 26;

    // ---- Calculate entropy ----
    final entropy = password.length * (log(poolSize) / log(2));

    // ---- Normalize entropy (0–1 scale) ----
    double strength;
    if (entropy < 28) {
      strength = entropy / 28 * 0.25;
    } else if (entropy < 36) {
      strength = 0.25 + ((entropy - 28) / (36 - 28)) * 0.20;
    } else if (entropy < 60) {
      strength = 0.45 + ((entropy - 36) / (60 - 36)) * 0.20;
    } else if (entropy < 90) {
      strength = 0.65 + ((entropy - 60) / (90 - 60)) * 0.20;
    } else {
      strength = 0.85 + ((entropy - 90) / 60).clamp(0.0, 0.15);
    }

    strength = strength.clamp(0.0, 1.0);

    // ---- Map to descriptive labels ----
    String strengthText;
    Color strengthColor;
    if (password.length < 4) {
      strengthText = "X";
      strengthColor = const Color(0xFFB71C1C); // Deep crimson red
    } else if (entropy < 28) {
      strengthText = "Very Weak";
      strengthColor = const Color(0xFFD32F2F); // Soft red
    } else if (entropy < 36) {
      strengthText = "Weak";
      strengthColor = const Color(0xFFE57373); // Muted coral pink
    } else if (entropy < 60) {
      strengthText = "Fair";
      strengthColor = const Color(0xFFFBC02D); // Warm amber
    } else if (entropy < 90) {
      strengthText = "Good";
      strengthColor = const Color(0xFF64B5F6); // Soft sky blue
    } else {
      strengthText = "Strong";
      strengthColor = const Color(0xFF2E7D32); // Deep emerald green
    }


    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }


  void _validateVaultName() {
    if (!_vaultNameTouched) return;

    final vaultName = _VaultNameController.text.trim();
    setState(() {
      if (vaultName.isEmpty) {
        _vaultError = "Vault name is required";
        _vaultNameValid = false;
      } else if (vaultName.length < 2) {
        _vaultError = "Vault name must be at least 2 characters long";
        _vaultNameValid = false;
      } else if (ctr.getListOfVault().contains(vaultName)) {
        _vaultError = "A vault with this name already exists";
        _vaultNameValid = false;
      } else {
        _vaultError = null;
        _vaultNameValid = true;
      }
    });
  }

  void _validatePassword() {
    if (!_passwordTouched) return;

    final password = _passwordController.text;
    setState(() {
      if (password.isEmpty) {
        _passwordError = "Password is required";
        _passwordValid = false;
      } else if (password.length < 4) {
        _passwordError = "Password must be at least 4 characters long";
        _passwordValid = false;
      } else {
        _passwordError = null;
        _passwordValid = true;
      }
    });

    // Also validate confirm password when password changes
    if (_confirmPasswordTouched) {
      _validateConfirmPassword();
    }
  }

  void _validateConfirmPassword() {
    if (!_confirmPasswordTouched) return;

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    setState(() {
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = "Please confirm your password";
        _confirmPasswordValid = false;
      } else if (password != confirmPassword) {
        _confirmPasswordError = "Passwords do not match";
        _confirmPasswordValid = false;
      } else {
        _confirmPasswordError = null;
        _confirmPasswordValid = true;
      }
    });
  }

  Color _getFieldColor(bool isValid, bool isTouched) {
    if (!isTouched) {
      return Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    }
    return isValid
        ? Colors.green
        : Colors.red;
  }

  String? _getVaultNameHelperText() {
    if (!_vaultNameTouched) return "Enter a unique vault name";
    if (_vaultNameValid) return "Vault name is available";
    return null;
  }

  String? _getPasswordHelperText() {
    if (!_passwordTouched) return "At least 4 characters";
    if (_passwordValid) return "Password is valid";
    return null;
  }

  String? _getConfirmPasswordHelperText() {
    if (!_confirmPasswordTouched) return "Re-enter your password";
    if (_confirmPasswordValid) return "Passwords match";
    return null;
  }

  void _callLogIn() {
    Navigator.pushReplacementNamed(context, '/Login');
  }

  void _signUp() async {
    // Mark all fields as touched to show validation
    setState(() {
      _vaultNameTouched = true;
      _passwordTouched = true;
      _confirmPasswordTouched = true;
    });

    // Run validation
    _validateVaultName();
    _validatePassword();
    _validateConfirmPassword();

    // Check if all fields are valid
    if (!_vaultNameValid || !_passwordValid || !_confirmPasswordValid) {
      return;
    }

    String VaultName = _VaultNameController.text.trim();
    String password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. init the vault, create files, salt, ...
      await ctr.initApp(password, VaultName);

      // 2. using the created salt, ..., compute the crypter (high computation time)
      E.Key key = await compute(callCrypterInit, [ctr, password, VaultName]);

      // 3. finaly, apply retrieved key to app, and load it.
      ctr.loadApp(password, VaultName, key);

      Navigator.pushReplacementNamed(context, '/HomePage');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error here if needed
      print("Error during signup: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool _isLightMode = Theme.of(context).colorScheme.brightness.name == "light";

    Widget login = InkWell(
        onTap: _callLogIn,
        child: _isLoading
            ? const SizedBox()
            : Text(
          "Connect to existing Vault!",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            decoration: TextDecoration.underline,
            decorationColor: Theme.of(context).colorScheme.primary,
            decorationThickness: 3,
            decorationStyle: TextDecorationStyle.dashed,
          ),
        ));

    int nbVaults = ctr.getListOfVault().length;
    final Widget canLog = nbVaults > 0 ? login : const SizedBox();
    final String title = nbVaults > 0 ? " > New Vault" : " > Sign-Up";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            heightFactor: 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "CryptedEye",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          title,
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Image.asset(
                  _isLightMode
                      ? "lib/assets/signup_light.png"
                      : "lib/assets/signup_dark.png",
                  width: 300,
                ),
                const SizedBox(height: 20),

                // Vault Name Field
                SizedBox(
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      maxLength: 20,
                      controller: _VaultNameController,
                      onChanged: (_) {
                        setState(() {
                          _vaultNameTouched = true;
                        });
                        _validateVaultName();
                      },
                      decoration: InputDecoration(
                        labelText: 'Vault Name',
                        helperText: _getVaultNameHelperText(),
                        errorText: _vaultError,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: _getFieldColor(_vaultNameValid, _vaultNameTouched),
                              width: 1.5
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _getFieldColor(_vaultNameValid, _vaultNameTouched),
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        suffixIcon: _vaultNameTouched
                            ? Icon(
                          _vaultNameValid ? Icons.check_circle : Icons.error,
                          color: _vaultNameValid ? Colors.green : Colors.red,
                        )
                            : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Password Field with Strength Indicator
                Column(
                  children: [
                    SizedBox(
                      width: 300,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: _passwordController,
                          obscureText: true,
                          onChanged: (_) {
                            setState(() {
                              _passwordTouched = true;
                            });
                            _validatePassword();
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            helperText: _getPasswordHelperText(),
                            errorText: _passwordError,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: _getFieldColor(_passwordValid, _passwordTouched),
                                  width: 1.5
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: _getFieldColor(_passwordValid, _passwordTouched),
                                width: 2.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.red, width: 2.0),
                            ),
                            suffixIcon: _passwordTouched
                                ? Icon(
                              _passwordValid ? Icons.check_circle : Icons.error,
                              color: _passwordValid ? Colors.green : Colors.red,
                            )
                                : null,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    
                    // Password Strength Indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Use Expanded + LayoutBuilder so we know the actual available width
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      // The full width of the background bar
                                      final fullWidth = constraints.maxWidth;
                                      // Compute the filled width relative to the available width.
                                      // Give a small minimum to make tiny strengths visible.
                                      final minVisible = 4.0;
                                      final filledWidth = (_passwordStrength > 0)
                                          ? math.max(minVisible, fullWidth * _passwordStrength)
                                          : 0.0;

                                      return Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3),
                                          color: Colors.grey[300],
                                        ),
                                        child: Stack(
                                          children: [
                                            // Animated filled portion
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 400),
                                              curve: Curves.easeOutCubic,
                                              width: filledWidth,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(3),
                                                color: _passwordStrengthColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Strength text
                                Text(
                                  _passwordStrengthText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _passwordStrengthColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Confirm Password Field
                SizedBox(
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      onChanged: (_) {
                        setState(() {
                          _confirmPasswordTouched = true;
                        });
                        _validateConfirmPassword();
                      },
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        helperText: _getConfirmPasswordHelperText(),
                        errorText: _confirmPasswordError,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: _getFieldColor(_confirmPasswordValid, _confirmPasswordTouched),
                              width: 1.5
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _getFieldColor(_confirmPasswordValid, _confirmPasswordTouched),
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        suffixIcon: _confirmPasswordTouched
                            ? Icon(
                          _confirmPasswordValid ? Icons.check_circle : Icons.error,
                          color: _confirmPasswordValid ? Colors.green : Colors.red,
                        )
                            : null,
                      ),
                      onFieldSubmitted: (_) {
                        _signUp();
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                )
                    : ElevatedButton(
                  onPressed: _signUp,
                  child: const Text('Create Vault'),
                ),
                const SizedBox(height: 10),
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            label: 'Import Vault',
            labelStyle: const TextStyle(fontSize: 16.0),
            onTap: () {
              _showImportConfirmationDialog(context);
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
                Navigator.of(context).pop();
                if (await widget.ctr.importData()) {
                  _showImportSuccessMessage(context);
                } else {
                  _showImportFailureMessage(context);
                }
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