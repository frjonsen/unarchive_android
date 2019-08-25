import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssh/ssh.dart';
import 'package:unarchive_android/set_path_dialog.dart';

import 'log_viewer.dart';

class SshBrowserState extends State<SshBrowser> {
  static const FAVORITE_PATH_KEY = "FAVORITE_PATH_KEY";
  final SSHClient _client;
  final List<String> _sshLog = [];
  List<String> _currentPathContents = [];
  String _favoritePath;
  String _currentPath;
  @override
  Widget build(BuildContext context) {
    var actions = <Widget>[
      IconButton(
        icon: Icon(Icons.edit),
        onPressed: _handleEditPath,
      ),
      IconButton(icon: Icon(Icons.favorite), onPressed: _handleSetFavoritePath),
    ];
    if (_favoritePath != null && _favoritePath != "") {
      actions.add(IconButton(
        icon: Icon(Icons.folder),
        onPressed: () => _updatePwd(_favoritePath),
      ));
    }
    actions.add(IconButton(
      icon: Icon(Icons.announcement),
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LogViewer(_sshLog)));
      },
    ));
    return Scaffold(
        appBar: AppBar(title: Text(_getCurrentDir()), actions: actions),
        body: _buildDirList());
  }

  String _getCurrentDir() {
    return _currentPath.split("/").last;
  }

  Future<void> _handleSetFavoritePath() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(FAVORITE_PATH_KEY, _currentPath);
    setState(() {
      _favoritePath = _currentPath;
    });
  }

  Future<String> _getFavoritePath() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(FAVORITE_PATH_KEY);
  }

  Future<void> _handleEditPath() async {
    String path = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => SetPathDialog());
    if (path != null) {
      _updatePwd(path);
    }
  }

  Future<void> _updateContents() async {
    var contents = await _ls();
    setState(() {
      _currentPathContents = contents;
    });
  }

  Future<void> _updatePwd(String toPath) async {
    var newPath = toPath.startsWith("/") ? toPath : "$_currentPath/$toPath";
    var path = _currentPath == "/" ? toPath : newPath;
    var pwd = await _executeWithLog("cd $path && pwd");
    // If pwd is empty it's most likely because cd failed
    if (pwd.trim() == "") return;
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
    return contents.trim().split(new RegExp(r"\r?\n"));
  }

  @override
  void initState() {
    super.initState();
    _executeWithLog("pwd").then((r) => setState(() {
          _currentPath = r.trim();
          _updateContents();
        }));
    _getFavoritePath().then((r) {
      if (r != null) {
        setState(() {
          _favoritePath = r;
        });
      }
    });
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
