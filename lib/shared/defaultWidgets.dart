import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradely/chooseSemester.dart';
import 'package:gradely/main.dart';
import 'package:gradely/data.dart';
import 'package:gradely/semesterDetail.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/shared/VARIABLES..dart';
import 'package:gradely/userAuth/login.dart';

RoundedRectangleBorder defaultRoundedCorners() {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(25),
    ),
  );
}

BoxDecoration boxDec() {
  return BoxDecoration(
    color: bwColor,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );
}

BoxDecoration whiteBoxDec() {
  return BoxDecoration(
      color: bwColor,
      borderRadius: BorderRadius.all(
        Radius.circular(15),
      ));
}

InputDecoration inputDec(String _label) {
  return InputDecoration(
    disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        borderSide: BorderSide.none),
    filled: true,
    labelText: _label,
    fillColor: bwColor,
    labelStyle: TextStyle(fontSize: 17.0, height: 0.8, color: defaultColor),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide.none,
    ),
  );
}

FilteringTextInputFormatter EmojiRegex() {
  return FilteringTextInputFormatter.deny(RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'));
}

ButtonStyle elev() {
  return ElevatedButton.styleFrom(
    primary: defaultColor, // background
  );
}

//dialog

Widget gradelyDialog({context, title, text, actions}) {
  androidDialog() {
    return AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: actions ??
            [
              TextButton(
                  child: Text(
                    "Ok",
                    style: TextStyle(color: defaultColor),
                  ),
                  onPressed: () => Navigator.of(context).pop())
            ]);
  }

  showDialog(
      context: context,
      builder: (BuildContext context) {
        if (kIsWeb) {
          return androidDialog();
        } else if (Platform.isIOS || Platform.isMacOS) {
          return CupertinoAlertDialog(
              title: Text(title),
              content: Text(text),
              actions: actions ??
                  [
                    CupertinoButton(
                        child: Text(
                          "Ok",
                          style: TextStyle(color: defaultColor),
                        ),
                        onPressed: () => Navigator.of(context).pop())
                  ]);
        } else {
          return androidDialog();
        }
      });
}
