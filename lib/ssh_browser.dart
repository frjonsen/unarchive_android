import 'package:flutter/material.dart';
import 'package:ssh/ssh.dart';

import 'log_viewer.dart';

class SshBrowserState extends State<SshBrowser> {
  final SSHClient _client;
  final List<String> _sshLog = [];
  List<String> _currentPathContents = [];
  String _currentPath;
  @override
  Widget build(BuildContext context) {
    final logButton = IconButton(
      icon: Icon(Icons.announcement),
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LogViewer(_sshLog)));
      },
    );
    return Scaffold(
        appBar: AppBar(
          title: Text(_currentPath ?? ""),
          actions: <Widget>[logButton],
        ),
        body: _buildDirList());
  }

  Future<void> _updateContents() async {
    var contents = await _ls();
    setState(() {
      _currentPathContents = contents;
    });
  }

  Future<void> _updatePwd(String relativePath) async {
    var pwd = await _executeWithLog("cd $_currentPath/$relativePath && pwd");
    print("Pwd: $pwd");
    setState(() {
      _currentPath = pwd.trim();
      _updateContents();
    });
  }

  Widget _buildDirList() {
    var up = Card(
        child: ListTile(
      title: Text(".."),
      onTap: () => _updatePwd(".."),
    ));
    var paths = _currentPathContents.map((c) => Card(
          child: ListTile(
            title: Text(c),
            onTap: () => _updatePwd(c),
          ),
        ));
    return ListView(
      children: [up, ...paths],
    );
  }

  Future<String> _executeWithLog(String cmd) async {
    _sshLog.add("> $cmd");
    var result = await _client.execute(cmd);
    _sshLog.add("< $result");
    return result;
  }

  Future<List<String>> _ls() async {
    var contents = await _client.execute("ls -1F $_currentPath | grep -G /\$");
    return contents.trim().split('\n');
  }

  @override
  void initState() {
    super.initState();
    _executeWithLog("pwd").then((r) => setState(() {
          _currentPath = r.trim();
          _updateContents();
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
