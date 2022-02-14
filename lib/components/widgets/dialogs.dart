//default gradely dialog

import "package:another_flushbar/flushbar.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:easy_localization/easy_localization.dart";

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

errorSuccessDialog(
    {required BuildContext context,
    required bool error,
    String? title,
    required String text}) {
  Flushbar(
    maxWidth: 350,
    leftBarIndicatorColor:
        error ? Colors.redAccent[400] : Colors.greenAccent[400],
    titleText: Padding(
      padding: EdgeInsets.only(left: 30),
      child: Text(
        title ?? (error ? "error".tr() : "success".tr()),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
    messageText: Padding(
      padding: EdgeInsets.only(left: 30),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
    ),

    icon: Padding(
      padding: EdgeInsets.only(left: 20),
      child: Icon(
        error ? CupertinoIcons.xmark_circle : CupertinoIcons.check_mark_circled,
        size: 40,
        color: error ? Colors.redAccent[400] : Colors.greenAccent[400],
      ),
    ),
    shouldIconPulse: false,
    margin: EdgeInsets.only(bottom: 13),
    borderRadius: BorderRadius.circular(15),
    duration: Duration(seconds: 5),
    boxShadows: const [
      BoxShadow(
        color: Colors.black26,
        offset: Offset(0, 0),
        blurRadius: 20,
      ),
    ],
    backgroundColor: Theme.of(context).backgroundColor,
    dismissDirection: FlushbarDismissDirection.VERTICAL,
    // The default curve is Curves.easeOut
    animationDuration: Duration(milliseconds: 500),
  ).show(context);
}
