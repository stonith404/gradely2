import 'package:flutter/material.dart';
import 'package:gradely/main.dart';


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
    filled: true,
    labelText: _label,
    labelStyle:
        TextStyle(fontSize: 20.0, height: 0.8, color: Color(0xFF6C63FF)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide.none,
    ),


  );
}
