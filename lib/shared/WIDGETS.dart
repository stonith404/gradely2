import 'package:flutter/material.dart';
import 'package:gradely/shared/VARIABLES.dart';

BoxDecoration listContainerDecoration({int index, List list}) {
    return (() {
      print(list.length);
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