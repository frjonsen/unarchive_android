import 'package:flutter/material.dart';

class LogViewer extends StatelessWidget {
  final List<String> _log;
  @override
  Widget build(BuildContext context) {
    var lines = _log.map((l) {
      return ListTile(
        title: Text(l),
        contentPadding: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 10.0),
      );
    }).toList();
    return Scaffold(
        appBar: AppBar(title: Text("SSH Log")),
        body: ListView(
          children: lines,
        ));
  }

  LogViewer(this._log);
}
