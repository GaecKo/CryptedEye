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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Password'),
      content: SingleChildScrollView(
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
            const SizedBox(width: 8),
            TextField(
              textInputAction: TextInputAction.next,
              controller: usernameController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Username - email',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.autorenew),
                    color: Colors.blue,
                    onPressed: () {
                      setState(() {
                        passwordController.text =
                            widget.ctr.generateRandomPassword();
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 7,
                ),
                Expanded(
                  flex: 6,
                  child: TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: showError && passwordController.text.isEmpty
                          ? 'Please enter password'
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ],
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
      // Specify the barrierColor to dim the background
    );
  }
}
