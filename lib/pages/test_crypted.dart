import 'package:flutter/material.dart';
import '/API/crypter.dart';
import 'package:flutter/services.dart'; // Needed for clipboard

class HashPage extends StatefulWidget {
  const HashPage({super.key});

  @override
  _HashPageState createState() => _HashPageState();
}

class _HashPageState extends State<HashPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _encryptedTextController = TextEditingController();
  final TextEditingController _hashTextController = TextEditingController();
  String _cryptedString = '';
  String _decryptedString = '';
  String _hashedString = '';
  Crypter cr = Crypter.create();

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var password = args['AP'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypted text Generator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Enter a string',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!cr.isInit()) {
                    await cr.init(password, "temp.key");
                  }
                  setState(() {
                    _cryptedString = cr.encrypt(_textController.text);
                  });
                },
                child: const Text('Generate crypt'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Hashed String: $_cryptedString',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.content_copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _cryptedString));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _encryptedTextController,
                decoration: const InputDecoration(
                  labelText: 'Enter encrypted string',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _decryptedString = cr.decrypt(_encryptedTextController.text);
                  });
                },
                child: const Text('Decrypt'),
              ),
              const SizedBox(height: 20),
              Text(
                'Decrypted String: $_decryptedString',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _hashTextController,
                decoration: const InputDecoration(
                  labelText: 'Enter string to hash',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hashedString = cr.secureHash(_hashTextController.text);
                  });
                },
                child: const Text('Hash'),
              ),
              const SizedBox(height: 20),
              Text(
                'Hashed String: $_hashedString',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
