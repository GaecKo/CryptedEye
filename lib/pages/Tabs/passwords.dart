import 'package:flutter/material.dart';
import '../../controller.dart';

class PasswordManagerPage extends StatefulWidget {
  final Controller ctr;

  const PasswordManagerPage({Key? key, required this.ctr}) : super(key: key);

  @override
  _PasswordManagerPageState createState() => _PasswordManagerPageState();
}

class _PasswordManagerPageState extends State<PasswordManagerPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager'),
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
                  return AddPasswordItem(ctr: widget.ctr); // Pass the controller to AddPasswordItem
                },
              );
            },
            child: const Text('Add New Password'),
          ),
          Expanded(
            child: widget.ctr.displaypassword
                ? ListView.builder(
                    itemCount: widget.ctr.password_data.length,
                    itemBuilder: (BuildContext context, int index) {
                      String website = widget.ctr.password_data.keys.elementAt(index);
                      List<dynamic> userData = widget.ctr.password_data.values.elementAt(index);
                      String username = userData[0];
                      String password = userData[1];

                      return PasswordItem(
                        website: widget.ctr.crypter.decrypt(website),
                        username: widget.ctr.crypter.decrypt(username),
                        password: password,
                        ctr: widget.ctr,
                        onEyePressed: () {
                          // Action when eye icon is pressed
                        },
                        onPenPressed: () {
                          // Action when pen icon is pressed
                          _editPassword(website, username, password);
                        },
                      );
                    },
                  )
                : const SizedBox(), // Placeholder for password list
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            widget.ctr.updateDisplayPassword();
          });
        },
        child: const Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  // Function to edit an existing password
  void _editPassword(String website, String username, String password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditPasswordItem(
          ctr: widget.ctr,
          initialWebsite: website,
          initialUsername: username,
          initialPassword: password,
        );
      },
    );
  }
}

class PasswordItem extends StatefulWidget {
  final String website;
  final String username;
  final String password;
  final VoidCallback onEyePressed;
  final VoidCallback onPenPressed;
  final Controller ctr;

  const PasswordItem({
    Key? key,
    required this.website,
    required this.username,
    required this.password,
    required this.onEyePressed,
    required this.onPenPressed,
    required this.ctr,
  }) : super(key: key);

  @override
  _PasswordItemState createState() => _PasswordItemState();
}

class _PasswordItemState extends State<PasswordItem> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          widget.website,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Username: ${widget.username}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Password: ${_isPasswordVisible ? widget.ctr.crypter.decrypt(widget.password) : '********'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
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
          ],
        ),
      ),
    );
  }
}

class AddPasswordItem extends StatefulWidget {
  final Controller ctr;

  const AddPasswordItem({Key? key, required this.ctr}) : super(key: key);

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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: websiteController,
                    decoration: InputDecoration(
                      labelText: 'Website',
                      errorText: showError && websiteController.text.isEmpty ? 'Please enter website' : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      errorText: showError && usernameController.text.isEmpty ? 'Please enter username' : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.autorenew),
                  onPressed: () {
                    setState(() {
                      passwordController.text = widget.ctr.generateRandomPassword();
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: showError && passwordController.text.isEmpty ? 'Please enter password' : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.visibility),
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              showError = true;
            });
            if (websiteController.text.isNotEmpty &&
                usernameController.text.isNotEmpty &&
                passwordController.text.isNotEmpty) {
              // Controller fonction
              ctr.addPasswordData(websiteController.text, usernameController.text, passwordController.text);
              Navigator.of(context).pop();
              Navigator.of(context).setState(() {
                ctr.updateDisplayPassword();
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class EditPasswordItem extends StatefulWidget {
  final Controller ctr;
  final String initialWebsite;
  final String initialUsername;
  final String initialPassword;

  const EditPasswordItem({
    Key? key,
    required this.ctr,
    required this.initialWebsite,
    required this.initialUsername,
    required this.initialPassword,
  }) : super(key: key);

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
    usernameController.text = widget.ctr.crypter.decrypt(widget.initialUsername);
    passwordController.text = widget.ctr.crypter.decrypt(widget.initialPassword);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.ctr.crypter.decrypt(widget.initialWebsite)} Password'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: showError && usernameController.text.isEmpty ? 'Please enter username' : null,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.autorenew),
                  onPressed: () {
                    setState(() {
                      passwordController.text = widget.ctr.generateRandomPassword();
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: showError && passwordController.text.isEmpty ? 'Please enter password' : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.visibility),
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              showError = true;
            });
            if (
                usernameController.text.isNotEmpty &&
                passwordController.text.isNotEmpty
            ) {
              // Controller function
              widget.ctr.editPasswordData(
                  widget.initialWebsite, 
                  websiteController.text, 
                  usernameController.text, 
                  passwordController.text
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
