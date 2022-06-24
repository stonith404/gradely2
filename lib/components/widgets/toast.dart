import "package:another_flushbar/flushbar.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

class Toast {

  Future error(BuildContext context, {String? title, required String text}) {
    return _toastWidget(context,
        color: Colors.redAccent,
        title: title ?? "error".tr(),
        icon: CupertinoIcons.xmark_circle,
        text: text);
  }

  Future success(BuildContext context, {String? title, required String text}) {
    return _toastWidget(context,
        color: Colors.greenAccent,
        title: title ?? "success".tr(),
        icon: CupertinoIcons.check_mark_circled,
        text: text);
  }

  Future info(BuildContext context, {String? title, required String text}) {
    return _toastWidget(context,
        color: Colors.orangeAccent,
        title: title ?? "info".tr(),
        icon: CupertinoIcons.info_circle,
        text: text);
  }
}

Future _toastWidget(BuildContext context,
    {required Color color,
    required String title,
    required IconData icon,
    required String text}) {
  return Flushbar(
    maxWidth: 350,
    leftBarIndicatorColor: color,
    titleText: Padding(
      padding: EdgeInsets.only(left: 30),
      child: Text(
        title,
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
      child: Icon(icon, size: 40, color: color),
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

Toast toast = Toast();
