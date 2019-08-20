import 'package:flutter/material.dart';
import 'package:ssh/ssh.dart';

class SshBrowserState extends State<SshBrowser> {
  final SSHClient _client;
  String _currentPath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(_currentPath ?? "")), body: Text("Hello"));
  }

  @override
  void initState() {
    super.initState();
    _client.execute("pwd").then((r) => setState(() {
          _currentPath = r.trim();
          print(r);
        }));
  }

  SshBrowserState(this._client);
}

class SshBrowser extends StatefulWidget {
  final SSHClient _client;
  @override
  State<StatefulWidget> createState() {
    return SshBrowserState(_client);
  }

  SshBrowser(this._client);
}
