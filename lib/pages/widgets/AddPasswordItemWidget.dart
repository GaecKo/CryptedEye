import 'package:cryptedeye/controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddPasswordItem extends StatefulWidget {
  final Controller ctr;
  final VoidCallback rebuildParent;

  const AddPasswordItem(
      {super.key, required this.ctr, required this.rebuildParent});

  @override
  _AddPasswordItemState createState() => _AddPasswordItemState(ctr: ctr);
}

class _AddPasswordItemState extends State<AddPasswordItem> {
  final Controller ctr;

  TextEditingController websiteController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showError = false;
  bool obscurePassword = true;

  _AddPasswordItemState({required this.ctr});

  @override
  AlertDialog build(BuildContext context) {
    return AlertDialog(

      titlePadding: const EdgeInsets.all(20), // Keep only necessary title padding
      actionsPadding: const EdgeInsets.all(20), // Keep only necessary actions padding
      title: const Text('Add New Password'),
      content: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 0), // Control content padding manually
        child: Column(
          children: [
            TextField(
              controller: websiteController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Title - Website',
                errorText: showError && websiteController.text.isEmpty
                    ? 'Please enter title'
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              textInputAction: TextInputAction.next,
              controller: usernameController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                labelText: 'Username - email',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                fillColor:  Theme.of(context).colorScheme.surface.withOpacity(0.8),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                labelText: 'Password',
                errorText: showError && passwordController.text.isEmpty
                    ? 'Please enter password'
                    : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              showError = true;
            });
            if (websiteController.text.isNotEmpty &&
                passwordController.text.isNotEmpty) {
              // Controller function
              ctr.addPasswordData(websiteController.text,
                  usernameController.text, passwordController.text);
              widget.rebuildParent();
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}