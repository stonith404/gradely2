import 'main.dart';
import 'package:flutter/material.dart';

List<String> names = <String>[
  'Ben',
];

List<String> testNames = <String>['chemie', 'englisch', 'kebron', 'ewewewew'];

List<String> testGrades = <String>["10", "10", "34", "10"];

var orderLines = <Map>[
  {'chemie': '10', 'englisch': '34', 'Qty': ''}
];

int currentIndex = 0;
String currentName = "";
LessonDetailIndex(int index, String names) {
  currentIndex = index;
  currentName = names;
}

TextEditingController addLessonController = new TextEditingController();
TextEditingController addGradeNameController = new TextEditingController();
TextEditingController addGradeGradeController = new TextEditingController();
