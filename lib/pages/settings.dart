import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

import '../controller.dart';

class SettingsPage extends StatefulWidget {
  Controller ctr;

  SettingsPage({required this.ctr});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SettingsList(ctr: widget.ctr),
    );
  }
}

class SettingsList extends StatefulWidget {
  Controller ctr;

  SettingsList({required this.ctr});

  @override
  _SettingsList createState() => _SettingsList();
}

class _SettingsList extends State<SettingsList> {
  TextEditingController passwordController = TextEditingController();
  bool showError = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: const Text('Delete All Notes'),
          leading: const Icon(Icons.delete_forever),
          onTap: () {
            _showDeleteDataConfirmationDialog(context, 'notes');
          },
        ),
        ListTile(
          title: const Text('Delete All Passwords'),
          leading: const Icon(Icons.delete_forever),
          onTap: () {
            _showDeleteDataConfirmationDialog(context, 'passwords');
          },
        ),
        const Divider(),
        ListTile(
          title: Text('Rename Vault (${widget.ctr.VaultName})'),
          leading: const Icon(Icons.edit),
          onTap: () {
            _showRenameAccountDialog(context);
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('Logout'),
          leading: const Icon(Icons.exit_to_app),
          onTap: () {
            _showLogoutConfirmationDialog(context);
          },
        ),

        // TODO: add here the export part, that creates img tar file and put it in downloads
        // TODO: should also ask to share the file

        const Divider(),
        ListTile(
          title: const Text(
            'Delete Vault',
            style: TextStyle(color: Colors.red),
          ),
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          onTap: () {
            _showDeleteVaultConfirmationDialog(context);
          },
        ),
      ],
    );
  }

  void _showDeleteDataConfirmationDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Data'),
          content: Text('Are you sure you want to delete all $type data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (type == "notes") {
                  widget.ctr.deleteAllNotes();
                } else if (type == "passwords") {
                  widget.ctr.resetPasswordJson();
                }
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameAccountDialog(BuildContext context) {
    TextEditingController newNameController = TextEditingController();
    bool showError = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Rename Account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter new name',
                      errorText: showError
                          ? 'Name must be longer than 1 character'
                          : null,
                    ),
                    controller: newNameController,
                    onChanged: (value) {
                      setState(() {
                        showError = value.trim().length < 2;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (newNameController.text.trim().length >= 2) {
                      widget.ctr.renameVault(newNameController.text);
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        showError = true;
                      });
                    }
                  },
                  child: const Text('Save'),
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
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                widget.ctr.closeApp();
                Restart.restartApp();
                Navigator.of(context).pop();
              },
              child: const Text('Logout'),
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

  void _showDeleteVaultConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Delete Vault'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      errorText: showError ? 'Incorrect password' : null,
                    ),
                    controller: passwordController,
                    obscureText: true,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (widget.ctr.verifyPassword(
                        passwordController.text, widget.ctr.VaultName)) {
                      widget.ctr.deleteVault();
                      Restart.restartApp();
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        showError = true;
                      });
                    }
                  },
                  child: const Text('Delete Vault'),
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
      },
    );
  }
}
