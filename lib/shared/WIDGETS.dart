import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:universal_io/io.dart';

BoxDecoration listContainerDecoration(context, {int index, List list}) {
  return (() {
    if (list.length == 1) {
      return BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ));
    } else if (index == 0) {
      return BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15),
          ));
    } else if (index == list.length - 1) {
      return BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ));
    } else {
      return BoxDecoration(
        color: Theme.of(context).backgroundColor,
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
    margin: EdgeInsets.only(bottom: 13),
    borderRadius: BorderRadius.circular(15),
    duration: Duration(seconds: 5),
    boxShadows: [
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
  )..show(context);
}

//default gradely button

Widget gradelyButton(
    {@required Function onPressed,
    @required String text,
    Color color,
    Color textColor}) {
  return StreamBuilder(
      stream: isLoadingStream,
      builder: (context, snapshot) {
        dynamic isLoading = snapshot.data ?? false;
        return ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: color ?? Theme.of(context).primaryColorDark,
              elevation: 0,
              padding: EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? Platform.isIOS || Platform.isMacOS
                    ? Theme(
                        data: ThemeData(
                            cupertinoOverrideTheme: CupertinoThemeData(
                                brightness:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.dark
                                        ? Brightness.light
                                        : Brightness.dark)),
                        child: CupertinoActivityIndicator())
                    : Container(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).primaryColorLight,
                        ),
                      )
                : Text(text,
                    style: TextStyle(
                        color:
                            textColor ?? Theme.of(context).primaryColorLight)),
            onPressed: onPressed);
      });
}

//default gradely icon button

Widget gradelyIconButton({Function onPressed, Icon icon}) {
  return StreamBuilder(
      stream: isLoadingStream,
      builder: (context, snapshot) {
        dynamic isLoading = snapshot.data ?? false;
        return CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).primaryColorDark,
            child: IconButton(
                icon: isLoading
                    ? Theme(
                        data: ThemeData(
                            cupertinoOverrideTheme: CupertinoThemeData(
                                brightness:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.dark
                                        ? Brightness.light
                                        : Brightness.dark)),
                        child: CupertinoActivityIndicator())
                    : icon,
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

BoxDecoration boxDec(context) {
  return BoxDecoration(
    color: Theme.of(context).backgroundColor,
    borderRadius: BorderRadius.all(Radius.circular(15)),
  );
}

//default input decoration for gradely

InputDecoration inputDec(context, {String label, var suffixIcon}) {
  return InputDecoration(
    suffixIcon: suffixIcon ?? Container(height: 1, width: 1),
    disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        borderSide: BorderSide.none),
    filled: true,
    labelText: label,
    fillColor: Theme.of(context).backgroundColor,
    labelStyle: TextStyle(
        fontSize: 17.0, height: 0.8, color: Theme.of(context).primaryColorDark),
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
  showDialog(
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

gradelyModalSheet(
    {@required BuildContext context, @required List<Widget> children}) {
  return showCupertinoModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expand: true,
      context: context,
      builder: (context) => SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            controller: ModalScrollController.of(context),
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: children,
                ),
              ),
            ),
          ));
}

Widget gradelyModalSheetHeader(BuildContext context,
    {String title,
    Icon icon = const Icon(CupertinoIcons.xmark),
    Widget customHeader}) {
  return Column(
    children: [
      SizedBox(
        height: 15,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          gradelyIconButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              icon: icon),
        ],
      ),
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: (() {
            if (title == null) {
              return customHeader;
            } else {
              return Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              );
            }
          }())),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Divider(
          thickness: 2,
        ),
      ),
    ],
  );
}
