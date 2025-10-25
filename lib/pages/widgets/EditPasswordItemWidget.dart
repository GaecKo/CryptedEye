import 'package:cryptedeye/controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditPasswordItem extends StatefulWidget {
  final Controller ctr;
  final String initialWebsite;
  final String initialUsername;
  final String initialPassword;
  final VoidCallback rebuildParent;

  const EditPasswordItem(
      {super.key,
      required this.ctr,
      required this.initialWebsite,
      required this.initialUsername,
      required this.initialPassword,
      required this.rebuildParent});

  @override
  _EditPasswordItemState createState() => _EditPasswordItemState();
}

class _EditPasswordItemState extends State<EditPasswordItem> {
  TextEditingController websiteController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showError = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    websiteController.text = widget.ctr.crypter.decrypt(widget.initialWebsite);
    usernameController.text =
        widget.ctr.crypter.decrypt(widget.initialUsername);
    passwordController.text =
        widget.ctr.crypter.decrypt(widget.initialPassword);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          "Edit '${widget.ctr.crypter.decrypt(widget.initialWebsite)}' Password"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: websiteController,
              decoration: InputDecoration(
                labelText: 'Title - Website',
                errorText: showError && websiteController.text.isEmpty
                    ? 'Please enter title'
                    : null,
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: usernameController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Username - email',
              ),
            ),
            const SizedBox(height: 8),
            Row(
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
                    onChanged: (_) {
                      setState(() {});
                    },
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
              widget.ctr.editPasswordData(
                  widget.initialWebsite,
                  websiteController.text,
                  usernameController.text,
                  passwordController.text);
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
