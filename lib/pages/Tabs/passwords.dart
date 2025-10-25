import 'package:cryptedeye/pages/widgets/AddPasswordItemWidget.dart';
import 'package:cryptedeye/pages/widgets/EditPasswordItemWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../controller.dart';

class PasswordManagerPage extends StatefulWidget {
  final Controller ctr;
  bool shown = false;

  PasswordManagerPage({super.key, required this.ctr});

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

  Widget popup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Adding Passwords",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "lib/images/passwords.png",
                width: 350,
              ),
              const SizedBox(height: 20),
              const Text(
                "Use the '+' button to create Passwords. Swipe left to delete.",
                textAlign: TextAlign.center,
                style: TextStyle(),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Okay"),
            ),
          ],
        );
      },
    );
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  borderSide: const BorderSide(
                      color: Colors.blue), // Couleur de la bordure
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Coins arrondis
                  borderSide: const BorderSide(
                    color: Colors
                        .blue, // Couleur de la bordure lorsqu'elle est activée
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
              padding: const EdgeInsets.only(bottom: 60),
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

                String decryptedWebsiteLowercase =
                    decryptedWebsite.toLowerCase();
                String decryptedUsernameLowercase =
                    decryptedUsername.toLowerCase();
                String decryptedPasswordLowercase =
                    decryptedPassword.toLowerCase();
                String searchQueryLowercase = _searchQuery.toLowerCase();

                // Apply search filter
                if (_searchQuery.isNotEmpty &&
                    !decryptedWebsiteLowercase.contains(searchQueryLowercase) &&
                    !decryptedUsernameLowercase
                        .contains(searchQueryLowercase) &&
                    !decryptedPasswordLowercase
                        .contains(searchQueryLowercase)) {
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
      floatingActionButton: Stack(
        children: [
          Positioned(
            left: 50.0,
            bottom: 10.0,
            child: FloatingActionButton(
              onPressed: () {
                popup();
              },
              mini: true,
              backgroundColor: Colors.grey,
              shape: const CircleBorder(),
              tooltip: 'Show Popup',
              child: const Icon(Icons.question_mark),
            ),
          ),
          Positioned(
            right: 16.0,
            bottom: 10.0,
            child: SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              animatedIconTheme: const IconThemeData(size: 22.0),
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.password),
                  backgroundColor: Colors.blue,
                  label: 'Add Password',
                  labelStyle: const TextStyle(fontSize: 16.0),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddPasswordItem(
                        ctr: widget.ctr,
                        rebuildParent: _rebuildParent,
                      ),
                    );
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.autorenew),
                  backgroundColor: Colors.deepPurpleAccent,
                  label: "Generate Password",
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String website) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: Text(
              'Are you sure you want to delete ${widget.ctr.crypter.decrypt(website)} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                widget.ctr.deletePassword(website);
                _rebuildParent();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Erreur lors de la copie du mot de passe'),
                    ));
                  });
                }),
          ],
        ),
      ),
    );
  }
}


