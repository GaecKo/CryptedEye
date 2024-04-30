import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:share_plus/share_plus.dart';

import '../controller.dart';

class SettingsPage extends StatefulWidget {
  Controller ctr;

  SettingsPage({super.key, required this.ctr});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void rebuildSettingsPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SettingsList(
        ctr: widget.ctr,
        rebuiltSettingsPage: rebuildSettingsPage,
      ),
    );
  }
}

class SettingsList extends StatefulWidget {
  Controller ctr;
  VoidCallback rebuiltSettingsPage;

  SettingsList({super.key, required this.ctr, required this.rebuiltSettingsPage});

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
            widget.rebuiltSettingsPage();
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('Export Vault'),
          leading: const Icon(Icons.share),
          onTap: () {
            _showExportConfirmationDialog(context);
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
    bool showErrorName = false;

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
                          : (showErrorName ? "Vault name already used" : null),
                    ),
                    controller: newNameController,
                    onChanged: (value) {
                      setState(() {
                        showError = value.trim().length < 2;
                        showErrorName =
                            widget.ctr.getListOfVault().contains(value.trim());
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (newNameController.text.trim().length >= 2 &&
                        !widget.ctr
                            .getListOfVault()
                            .contains(newNameController.text.trim())) {
                      widget.ctr.renameVault(newNameController.text);
                      widget.rebuiltSettingsPage();
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        if (newNameController.text.trim().length < 2) {
                          showError = true;
                        } else {
                          showErrorName = true;
                        }
                      });
                    }
                    widget.rebuiltSettingsPage();
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

  void _showExportConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Vault'),
          content: const Text('Are you sure you want to export your Vault ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String tarPath = await widget.ctr.exportData();
                Navigator.pop(context);

                _showExportSuccessMessage(context);

                widget.ctr.onSharing = true;
                await Share.shareXFiles(
                  [XFile(tarPath)],
                  text:
                      'This is the image of the Vault ${widget.ctr.VaultName}.',
                );
                widget.ctr.onSharing = false;
              },
              child: const Text('Export'),
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

  void _showExportSuccessMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Successful'),
          content: const Text(
              "Your data has been exported successfully! It's available in your Downloads folder."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showImportConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Import Data'),
          content: const Text('Are you sure you want to import data ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (await widget.ctr.importData()) {
                  Navigator.of(context).pop();
                  _showImportSuccessMessage(context);
                } else {
                  Navigator.of(context).pop();
                  _showImportFailureMessage(context);
                }
              },
              child: const Text('Import'),
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

  void _showImportSuccessMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Import Successful'),
          content: const Text('Your data has been imported successfully !'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showImportFailureMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Import Failed'),
          content: const Text(
              "Your data wasn't imported, please retry. Make sure you selected a valid Vault image. The file name should finish with '.CryptedEye.tar'. Make sure you don't already have a vault with the same name."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
