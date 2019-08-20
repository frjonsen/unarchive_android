import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ssh/ssh.dart';
import 'package:unarchive_android/ssh_browser.dart';
import 'package:unarchive_android/ssh_connections.dart';

import 'key_manager.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Unpacker", home: MyApp());
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  final _keyManager = KeyManager();
  final _biggerFont = TextStyle(fontSize: 18.0);
  SSHClient _client;

  Future<String> _getKeyFile() async {
    var file =
        await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'key');
    var keyContents = await file.readAsString();
    return keyContents;
  }

  Future<void> _setNewKeyHandler() async {
    var key = await _getKeyFile();
    await _keyManager.addKey(key);
  }

  void _onConnect(String username, String address) async {
    var client = new SSHClient(
        host: address,
        port: 22,
        username: username,
        passwordOrKey: {"privateKey": await _keyManager.getKey()});
    await client.connect();
    setState(() {
      _client = client;
    });
    _navigateToBrowser();
  }

  void _navigateToBrowser() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SshBrowser(_client)));
  }

  Widget _buildDrawer() {
    final menuItems = [
      ListTile(
        title: Text('Set SSH key', style: _biggerFont),
        onTap: _setNewKeyHandler,
      )
    ];
    final menu = ListView(children: menuItems);
    return Drawer(child: menu);
  }

  Future<void> _disconnect() async {
    if (_client != null) {
      _client.disconnect();
    }
    setState(() {
      _client = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    if (_client != null) {
      actions.add(IconButton(
        icon: Icon(Icons.stop),
        onPressed: _disconnect,
      ));
      actions.add(
          IconButton(icon: Icon(Icons.folder), onPressed: _navigateToBrowser));
    }
    final scaffold = Scaffold(
        appBar: AppBar(
          title: Text("Connect to server"),
          actions: actions,
        ),
        drawer: _buildDrawer(),
        body: SshConnections(_onConnect));
    return scaffold;
  }
}
