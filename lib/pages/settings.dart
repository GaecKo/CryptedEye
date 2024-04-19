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
        title: Text('Settings'),
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
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('Delete All Notes'),
          leading: Icon(Icons.delete_forever),
          onTap: () {
            _showDeleteDataConfirmationDialog(context, 'notes');
          },
        ),
        ListTile(
          title: Text('Delete All Passwords'),
          leading: Icon(Icons.delete_forever),
          onTap: () {
            _showDeleteDataConfirmationDialog(context, 'passwords');
          },
        ),
        Divider(),
        ListTile(
          title: Text('Rename Vault (${widget.ctr.VaultName})'),
          leading: Icon(Icons.edit),
          onTap: () {
            _showRenameAccountDialog(context);
          },
        ),
        Divider(),
        ListTile(
          title: Text('Logout'),
          leading: Icon(Icons.exit_to_app),
          onTap: () {
            _showLogoutConfirmationDialog(context);
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
          title: Text('Delete Data'),
          content: Text('Are you sure you want to delete all $type data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Perform delete data operation

                if (type == "notes") {
                  widget.ctr.deleteAllNotes();
                } else if (type == "passwords") {
                  widget.ctr.resetPasswordJson();
                }

                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameAccountDialog(BuildContext context) {
    TextEditingController newNameController = TextEditingController();
    bool showError = false; // Flag to track whether to show error message

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // StatefulBuilder used to rebuild the dialog based on state changes
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Rename Account'),
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
                        // Check if error should be shown based on input length
                        showError = value.trim().length <
                            2; // Change to your desired condition
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Perform rename account operation if input is valid
                    if (newNameController.text.trim().length >= 2) {
                      widget.ctr.renameVault(newNameController.text);
                      Navigator.of(context).pop(); // Close dialog
                    } else {
                      // Invalid input, show error
                      setState(() {
                        showError = true;
                      });
                    }
                  },
                  child: Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: Text('Cancel'),
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
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                widget.ctr.closeApp();
                Restart.restartApp();
                Navigator.of(context).pop(); // Close dialog
                // Example: Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: Text('Logout'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
