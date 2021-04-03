import 'main.dart';
import 'package:flutter/material.dart';
import 'LessonsDetail.dart';

List<String> names = <String>[
  'Ben',
];

List<String> testNames = <String>['chemie', 'englisch', 'kebron', 'ewewewew'];

List<String> testGrades = <String>["10", "10", "34", "10"];

double plusPoints = 0;
getPluspoints() {
  if (averageOfTests >= 5.75) {
    plusPoints = 2;
  } else if (averageOfTests >= 5.25) {
    plusPoints = 1.5;
  } else if (averageOfTests >= 4.75) {
    plusPoints = 1;
  } else if (averageOfTests >= 4.25) {
    plusPoints = 0.5;
  } else if (averageOfTests >= 3.75) {
    plusPoints = 0;
  }
  print(plusPoints);
}

int currentIndex = 0;
String currentName = "";
LessonDetailIndex(int index, String names) {
  currentIndex = index;
  currentName = names;
}

TextEditingController addLessonController = new TextEditingController();
TextEditingController renameTestWeightController = new TextEditingController();
TextEditingController addGradeNameController = new TextEditingController();
TextEditingController addGradeGradeController = new TextEditingController();
TextEditingController addTestNameController = new TextEditingController();
TextEditingController addTestGradeController = new TextEditingController();
TextEditingController addTestWeightController = new TextEditingController();
