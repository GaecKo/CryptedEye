import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../controller.dart';

class PasswordManagerPage extends StatefulWidget {
  final Controller ctr;

  const PasswordManagerPage({Key? key, required this.ctr}) : super(key: key);

  @override
  _PasswordManagerPageState createState() => _PasswordManagerPageState();
}

class _PasswordManagerPageState extends State<PasswordManagerPage> {
  String _searchQuery = '';

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  void _editPassword(String website, String username, String password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditPasswordItem(
          ctr: widget.ctr,
          initialWebsite: website,
          initialUsername: username,
          initialPassword: password,
          rebuildParent: _rebuildParent,
        );
      },
    );
  }

  void _rebuildParent() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(100, 100, 100, 1),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        animatedIconTheme: IconThemeData(size: 22.0),
        children: [
          SpeedDialChild(
              child: Icon(Icons.password),
              backgroundColor: Colors.blue,
              label: 'Add Password',
              labelStyle: TextStyle(fontSize: 16.0),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) => AddPasswordItem(
                          ctr: widget.ctr,
                          rebuildParent: _rebuildParent,
                        ));
              }),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            child: TextField(
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search Password...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Coins arrondis
                  borderSide: BorderSide(color: Colors.blue), // Couleur de la bordure
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Coins arrondis
                  borderSide: const BorderSide(
                    color: Colors.blue, // Couleur de la bordure lorsqu'elle est activée
                    width: 2.0, // Largeur de la bordure lorsqu'elle est activée
                  ),
                ),
              ),
              style: const TextStyle(
                // Définir la couleur de la bordure lorsqu'elle n'est pas activée
                decorationColor: Colors.blue,
                // Définir l'épaisseur de la bordure lorsqu'elle n'est pas activée
                decorationThickness: 2.0,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.ctr.password_data.length,
              itemBuilder: (BuildContext context, int index) {
                String website = widget.ctr.password_data.keys.elementAt(index);
                List<dynamic> userData =
                    widget.ctr.password_data.values.elementAt(index);
                String username = userData[0];
                String password = userData[1];

                String decryptedWebsite = widget.ctr.crypter.decrypt(website);
                String decryptedUsername = widget.ctr.crypter.decrypt(username);
                String decryptedPassword = widget.ctr.crypter.decrypt(password);

                // Apply search filter
                if (_searchQuery.isNotEmpty &&
                    !decryptedWebsite.contains(_searchQuery) &&
                    !decryptedUsername.contains(_searchQuery) &&
                    !decryptedPassword.contains(_searchQuery)) {
                  return const SizedBox
                      .shrink(); // Hide item if it doesn't match search query
                }

                return Slidable(
                  key: UniqueKey(),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dismissible: DismissiblePane(onDismissed: () {
                      widget.ctr.deletePassword(website);
                      _rebuildParent();
                    }),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          widget.ctr.deletePassword(website);
                          _rebuildParent();
                        },
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: PasswordItem(
                    website: decryptedWebsite,
                    username: decryptedUsername,
                    password: decryptedPassword,
                    ctr: widget.ctr,
                    onPenPressed: () {
                      _editPassword(website, username, password);
                    },
                    onEyePressed: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
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
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
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
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      errorText: showError && usernameController.text.isEmpty
                          ? 'Please enter username'
                          : null,
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
                      passwordController.text =
                          widget.ctr.generateRandomPassword();
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
          'Edit ${widget.ctr.crypter.decrypt(widget.initialWebsite)} Password'),
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
                errorText: showError && usernameController.text.isEmpty
                    ? 'Please enter username'
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.autorenew),
                  onPressed: () {
                    setState(() {
                      passwordController.text =
                          widget.ctr.generateRandomPassword();
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
            if (usernameController.text.isNotEmpty &&
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
