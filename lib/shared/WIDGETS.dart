import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:easy_localization/easy_localization.dart';

BoxDecoration listContainerDecoration({int index, List list}) {
  return (() {
    if (list.length == 1) {
      return BoxDecoration(
          color: bwColor,
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ));
    } else if (index == 0) {
      return BoxDecoration(
          color: bwColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15),
          ));
    } else if (index == list.length - 1) {
      return BoxDecoration(
          color: bwColor,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ));
    } else {
      return BoxDecoration(
        color: bwColor,
      );
    }
  }());
}

Padding listDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 35.0),
    child: Divider(
      thickness: 0.7,
      height: 1,
    ),
  );
}

//error_success dialog

errorSuccessDialog(
    {BuildContext context,
    @required bool error,
    String title,
    @required String text}) {
  Flushbar(
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
    margin: EdgeInsets.symmetric(horizontal: 15),
    borderRadius: BorderRadius.circular(15),
    duration: Duration(seconds: 5),
    boxShadows: [
      BoxShadow(
        color: Colors.black26,
        offset: Offset(0, 0),
        blurRadius: 20,
      ),
    ],
    backgroundColor: darkmode ? Colors.black : Colors.white,
    dismissDirection: FlushbarDismissDirection.VERTICAL,
    // The default curve is Curves.easeOut
    animationDuration: Duration(milliseconds: 500),
  )..show(context);
}
