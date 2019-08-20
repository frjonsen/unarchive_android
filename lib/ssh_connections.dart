import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SshConnectionsState extends State<SshConnections> {
  static const PREVIOUS_CONNECTIONS_KEY = "PREVIOUS_CONNECTIONS_KEY";
  final List<String> _previousConnections = [];
  final _biggerFont = TextStyle(fontSize: 18.0);
  String addressInput;
  final void Function(String, String) _onConnect;

  Future<void> connect(String address) async {
    if (address == null || address.length == 0) return;

    var input = address.split("@");
    if (input.length != 2) {
      var message = SnackBar(content: Text("Invalid address"));
      Scaffold.of(context).showSnackBar(message);
      return;
    }
    if (!_previousConnections.contains(address)) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _previousConnections.add(address);
      });
      prefs.setStringList(PREVIOUS_CONNECTIONS_KEY, _previousConnections);
    }

    _onConnect(input[0], input[1]);
  }

  Widget _buildNewConnectionRow() {
    var addressField = TextField(
      autocorrect: false,
      decoration: InputDecoration(labelText: 'Address'),
      onChanged: (s) {
        addressInput = s;
      },
    );
    var connectButton = IconButton(
        icon: Icon(Icons.send), onPressed: () => connect(addressInput));
    return ListTile(title: addressField, trailing: connectButton);
  }

  Future<List<String>> _getPreviousConnections() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(PREVIOUS_CONNECTIONS_KEY);
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

  SshConnectionsState(this._onConnect);

  @override
  Widget build(BuildContext context) {
    var previousConnectionsTitle =
        ListTile(title: Text("Previous connections"));
    var connections = _previousConnections.map((c) => ListTile(
          title: Text(c, style: _biggerFont),
          onTap: () => connect(c),
        ));
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
}

class SshConnections extends StatefulWidget {
  final void Function(String, String) _onConnect;

  @override
  State<StatefulWidget> createState() {
    return SshConnectionsState(_onConnect);
  }

  SshConnections(this._onConnect);
}
