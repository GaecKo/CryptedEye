import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controller.dart';

class PasswordItem extends StatefulWidget {
  final String website;
  final String cryptedWebsite;
  final String username;
  final String password;
  final VoidCallback onCardPressed;
  final VoidCallback rebuiltParent;
  final Controller ctr;

  const PasswordItem({
    super.key,
    required this.website,
    required this.cryptedWebsite,
    required this.username,
    required this.password,
    required this.onCardPressed,
    required this.ctr,
    required this.rebuiltParent,
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
    _hasUsername = widget.username.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: ListTile(
        title: Row(
          children: [
            Icon(
              _isPasswordVisible ? Icons.lock_open : Icons.lock_outline,
              color: Theme.of(context).colorScheme.primary,
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
            ) : const SizedBox(),
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
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.password));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password copied to clipboard')),
                );
              },
            ),
          ],
        ),
        onTap: () => widget.onCardPressed(),
      )
    );
  }
}
