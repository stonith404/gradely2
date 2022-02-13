//default gradely button

import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/variables.dart";

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
                    : SizedBox(
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
                    ? Platform.isIOS || Platform.isMacOS
                        ? Theme(
                            data: ThemeData(
                                cupertinoOverrideTheme: CupertinoThemeData(
                                    brightness: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? Brightness.light
                                        : Brightness.dark)),
                            child: CupertinoActivityIndicator())
                        : SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).primaryColorLight,
                            ),
                          )
                    : icon,
                onPressed: onPressed));
      });
}
