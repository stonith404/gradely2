import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradely/main.dart';
import 'package:gradely/data.dart';


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
    return FilteringTextInputFormatter.deny(
                 gradelyPlus ? RegExp(
  r''
)
: RegExp(
  r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'
)
);
  }

ButtonStyle elev() {
  return ElevatedButton.styleFrom(
  
    primary: defaultColor, // background
  
  );
}

