import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradely2/shared/VARIABLES.dart';
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

//error success dialog

errorSuccessDialog(
    {@required BuildContext context,
    @required bool error,
    String title,
    @required String text}) {
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

//default gradely button

Widget gradelyButton({Function onPressed, String text}) {
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    isLoadingStream.listen((value) {
      setState(() {
        if (value == null) {
          value = false;
        }
        isLoading = value;
      });
    });
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: primaryColor, // background
          elevation: 0,
          padding: EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // <-- Radius
          ),
        ),
        child: isLoading ? CupertinoActivityIndicator() : Text(text),
        onPressed: onPressed);
  });
}

//default gradely icon button

Widget gradelyIconButton({Function onPressed, Icon icon}) {
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    isLoadingStream.listen((value) {
      setState(() {
        if (value == null) {
          value = false;
        }
        isLoading = value;
      });
    });
    return CircleAvatar(
        radius: 22,
        backgroundColor: primaryColor,
        child: IconButton(
            color: Colors.white,
            icon: isLoading ? CupertinoActivityIndicator() : icon,
            onPressed: onPressed));
  });
}

// default rounded corners for gradely

RoundedRectangleBorder defaultRoundedCorners() {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(25),
    ),
  );
}

// default box decoration for gradely containers

BoxDecoration boxDec() {
  return BoxDecoration(
    color: bwColor,
    borderRadius: BorderRadius.all(Radius.circular(15)),
  );
}

//default input decoration for gradely

InputDecoration inputDec({String label, var suffixIcon}) {
  return InputDecoration(
    suffixIcon: suffixIcon ??
        Icon(
          Icons.ac_unit,
          color: bwColor,
        ),
    disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        borderSide: BorderSide.none),
    filled: true,
    labelText: label,
    fillColor: bwColor,
    labelStyle: TextStyle(fontSize: 17.0, height: 0.8, color: primaryColor),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide.none,
    ),
  );
}

//checks if input contains emojis
FilteringTextInputFormatter emojiRegex() {
  return FilteringTextInputFormatter.deny(RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'));
}

//default gradely dialog

// ignore: missing_return
Widget gradelyDialog(
    {@required BuildContext context,
    @required String title,
    @required String text,
    var actions}) {
  androidDialog() {
    return AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: actions ??
            [
              TextButton(
                  child: Text(
                    "Ok",
                    style: TextStyle(color: primaryColor),
                  ),
                  onPressed: () => Navigator.of(context).pop())
            ]);
  }

  showDialog(
      context: context,
      builder: (BuildContext context) {
        if (Platform.isIOS || Platform.isMacOS) {
          return CupertinoAlertDialog(
              title: Text(title),
              content: Text(text),
              actions: actions ??
                  [
                    CupertinoButton(
                        child: Text(
                          "Ok",
                          style: TextStyle(color: primaryColor),
                        ),
                        onPressed: () => Navigator.of(context).pop())
                  ]);
        } else {
          return androidDialog();
        }
      });
}
