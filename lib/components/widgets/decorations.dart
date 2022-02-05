import 'package:flutter/material.dart';

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
    suffixIcon: suffixIcon ?? SizedBox(height: 1, width: 1),
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
