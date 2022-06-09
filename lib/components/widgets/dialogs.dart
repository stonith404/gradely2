//default gradely dialog

import "package:flutter/material.dart";

Future<Widget?> gradelyDialog(
    {required BuildContext context,
    required String title,
    required String text,
    var actions}) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: Text(text),
            actions: actions ??
                [
                  TextButton(
                      child: Text(
                        "Ok",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark),
                      ),
                      onPressed: () => Navigator.of(context).pop())
                ]);
      });
}
