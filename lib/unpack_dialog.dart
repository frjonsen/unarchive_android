import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unarchive_android/unpack_type.dart';

class UnpackDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Select media type"),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop(UnpackType.tv),
          child: const Text(
            'TV',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
        SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(UnpackType.movie),
            child: const Text('Movie', style: TextStyle(fontSize: 18.0))),
      ],
    );
  }
}
