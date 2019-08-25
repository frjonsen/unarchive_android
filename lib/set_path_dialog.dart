import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetPathDialogState extends State<SetPathDialog> {
  String _path;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set current path'),
      content: new Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: 'Path', hintText: '/home'),
            onChanged: (value) => _path = value,
          ))
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Ok"),
          onPressed: () => Navigator.of(context).pop(_path),
        ),
        FlatButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(null),
        )
      ],
    );
  }
}

class SetPathDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SetPathDialogState();
  }
}
