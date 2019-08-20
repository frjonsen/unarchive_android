import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const PREVIOUS_CONNECTIONS_KEY = "PREVIOUS_CONNECTIONS_KEY";
  final List<String> _previousConnections = [];
  String addressInput;

  Future<String> _getKeyFile() async {
    var file =
        await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'key');
    var keyContents = await file.readAsString();
    print(keyContents);
    return keyContents;
  }

  Future<void> _setNewKeyHandler() async {
    var key = await _getKeyFile();
    await _keyManager.addKey(key);
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

  Future<void> connect() async {
    if (addressInput == null || addressInput.length == 0) return;
    if (!_previousConnections.contains(addressInput)) {
      final prefs = await SharedPreferences.getInstance();
      _previousConnections.add(addressInput);
      prefs.setStringList(PREVIOUS_CONNECTIONS_KEY, _previousConnections);

      setState(() {});
    }
  }

  Widget _buildNewConnectionRow() {
    var addressField = TextField(
      autocorrect: false,
      decoration: InputDecoration(labelText: 'Address'),
      onChanged: (s) {
        addressInput = s;
      },
    );
    var connectButton = IconButton(icon: Icon(Icons.send), onPressed: connect);
    return ListTile(title: addressField, trailing: connectButton);
  }

  Future<List<String>> _getPreviousConnections() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(PREVIOUS_CONNECTIONS_KEY);
  }

  Widget _buildConnectionList() {
    var previousConnectionsTitle =
        ListTile(title: Text("Previous connections"));
    var connections = _previousConnections
        .map((c) => ListTile(title: Text(c, style: _biggerFont)));
    var tiles =
        ListTile.divideTiles(tiles: connections, context: context).toList();

    return ListView(
      children: <Widget>[
        _buildNewConnectionRow(),
        previousConnectionsTitle,
        ...tiles
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
        appBar: AppBar(title: Text("Connect to server")),
        drawer: _buildDrawer(),
        body: _buildConnectionList());
    return scaffold;
  }

  @override
  void initState() {
    super.initState();
    _getPreviousConnections().then((result) {
      if (result == null || result.length == 0) return;
      if (result.length != _previousConnections.length) {
        setState(() {
          _previousConnections.clear();
          _previousConnections.addAll(result);
        });
      }
    });
  }
}
