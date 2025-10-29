import 'package:cryptedeye/controller.dart';
import 'package:flutter/material.dart';

class AddPasswordItem extends StatefulWidget {
  final Controller ctr;
  final VoidCallback rebuildParent;

  const AddPasswordItem({
    super.key,
    required this.ctr,
    required this.rebuildParent,
  });

  @override
  _AddPasswordItemState createState() => _AddPasswordItemState();
}

class _AddPasswordItemState extends State<AddPasswordItem> {
  late TextEditingController websiteController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  bool showError = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    websiteController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
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
            controller: usernameController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Username - email'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
              errorText: showError && passwordController.text.isEmpty
                  ? 'Please enter password'
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showError = true;
                  });
                  if (websiteController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty) {
                    widget.ctr.addPasswordData(
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
