import 'package:cryptedeye/controller.dart';
import 'package:flutter/material.dart';

class EditPasswordItem extends StatefulWidget {
  final Controller ctr;
  final String initialWebsite;
  final String initialUsername;
  final String initialPassword;
  final VoidCallback rebuildParent;

  const EditPasswordItem({
    super.key,
    required this.ctr,
    required this.initialWebsite,
    required this.initialUsername,
    required this.initialPassword,
    required this.rebuildParent,
  });

  @override
  _EditPasswordItemState createState() => _EditPasswordItemState();
}

class _EditPasswordItemState extends State<EditPasswordItem> {
  late TextEditingController websiteController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  bool showError = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    websiteController = TextEditingController(
      text: widget.ctr.crypter.decrypt(widget.initialWebsite),
    );
    usernameController = TextEditingController(
      text: widget.ctr.crypter.decrypt(widget.initialUsername),
    );
    passwordController = TextEditingController(
      text: widget.ctr.crypter.decrypt(widget.initialPassword),
    );
  }

  @override
  void dispose() {
    websiteController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: websiteController,
            decoration: InputDecoration(
              labelText: 'Title - Website',
              errorText: showError && websiteController.text.isEmpty
                  ? 'Please enter title'
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: usernameController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Username - email'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: showError && passwordController.text.isEmpty
                  ? 'Please enter password'
                  : null,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => obscurePassword = !obscurePassword),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 8,),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.redAccent),
                ),
                onPressed: () {
                  widget.ctr.deletePassword(widget.initialWebsite);
                  widget.rebuildParent();
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() => showError = true);
                  if (websiteController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty) {
                    widget.ctr.editPasswordData(
                      widget.initialWebsite,
                      websiteController.text,
                      usernameController.text,
                      passwordController.text,
                    );
                    widget.rebuildParent();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
