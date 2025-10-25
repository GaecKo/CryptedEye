import 'package:cryptedeye/controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class PasswordItem extends StatefulWidget {
  final String website;
  final String username;
  final String password;
  final VoidCallback onEyePressed;
  final VoidCallback onPenPressed;
  final Controller ctr;

  const PasswordItem({
    super.key,
    required this.website,
    required this.username,
    required this.password,
    required this.onEyePressed,
    required this.onPenPressed,
    required this.ctr,
  });

  @override
  _PasswordItemState createState() => _PasswordItemState();
}

class _PasswordItemState extends State<PasswordItem> {
  bool _isPasswordVisible = false;
  bool _hasUsername = true;

  @override
  void initState() {
    super.initState();
    // Check if username is empty
    if (widget.username.isEmpty) {
      setState(() {
        _hasUsername = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: ListTile(
        title: Row(
          children: [
            const Icon(
              Icons.lock_open,
              color: Colors.blue,
              size: 18,
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.website,
                overflow: TextOverflow.fade,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hasUsername ? const SizedBox(height: 8) : const SizedBox(),
            _hasUsername
                ? Text(
              'Username: ${widget.username}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
                : const SizedBox(),
            const SizedBox(height: 8),
            Text(
              'Password: ${_isPasswordVisible ? widget.password : '********'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
                widget.onEyePressed(); // Trigger callback
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: widget.onPenPressed,
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.password))
                  .catchError((error) {
                    // Erreur lors de la copie du mot de passe dans le presse-papiers
                    print(
                        'Erreur lors de la copie du mot de passe dans le presse-papiers : $error');
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Erreur lors de la copie du mot de passe'),
                    ));
                  }
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}