import 'package:flutter/material.dart';
import "../../controller.dart";
import  "../../main.dart";

class PasswordManagerPage extends StatelessWidget {

  const PasswordManagerPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Manager'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Password...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddPasswordItem();
                },
              );
            },
            child: Text('Add New Password'),
          ),
        ],
      ),
    );
  }
}

class PasswordItem extends StatelessWidget {
  final String website;
  final VoidCallback onEyePressed;
  final VoidCallback onPenPressed;

  const PasswordItem({
    Key? key,
    required this.website,
    required this.onEyePressed,
    required this.onPenPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(website),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: onEyePressed,
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onPenPressed,
          ),
        ],
      ),
    );
  }
}

class AddPasswordItem extends StatefulWidget {
  @override
  _AddPasswordItemState createState() => _AddPasswordItemState();
}


class _AddPasswordItemState extends State<AddPasswordItem> {
  TextEditingController websiteController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showError = false;
  bool obscurePassword = true;
  String psw = "TEST";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Password'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: websiteController,
                    decoration: InputDecoration(
                      labelText: 'Website',
                      errorText: showError && websiteController.text.isEmpty
                          ? 'Please enter website'
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      errorText: showError &&
                              usernameController.text.isEmpty
                          ? 'Please enter username'
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.autorenew),
                  onPressed: () {
                    setState(() {
                      passwordController.text = psw;
                    });
                  },
                ),
                Expanded(
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
                IconButton(
                  icon: Icon(Icons.visibility),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
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
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              showError = true;
            });
            if (websiteController.text.isNotEmpty &&
                usernameController.text.isNotEmpty &&
                passwordController.text.isNotEmpty) {
              
              // fonction controller
              Navigator.of(context).pop(); 
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}