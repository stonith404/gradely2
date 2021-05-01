import 'main.dart';
import 'package:flutter/material.dart';
import 'LessonsDetail.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userAuth/login.dart';
import 'LessonsDetail.dart';
import 'chooseSemester.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

num plusPoints = 0;
bool gradelyPlus = false;
bool isMaintanceEnabled = false;
String gradesResult = "Pluspunkte";
num plusPointsallAverageList = 0;
Timer timer;

getPluspoints(num value) {
  if (value >= 5.75) {
    plusPoints = 2;
  } else if (value >= 5.25) {
    plusPoints = 1.5;
  } else if (value >= 4.75) {
    plusPoints = 1;
  } else if (value >= 4.25) {
    plusPoints = 0.5;
  } else if (value >= 3.75) {
    plusPoints = 0;
  } else if (value >= 3.25) {
    plusPoints = -1;
  } else if (value >= 2.75) {
    plusPoints = -2;
  } else if (value >= 2.25) {
    plusPoints = -3;
  } else if (value >= 1.75) {
    plusPoints = -4;
  } else if (value >= 1.25) {
    plusPoints = -5;
  } else if (value >= 1) {
    plusPoints = -6;
  } else if (value == "NaN") {
    plusPoints = 0;
  }
}

getPluspointsallAverageList(num value) {
  if (value >= 5.75) {
    plusPointsallAverageList = 2;
  } else if (value >= 5.25) {
    plusPointsallAverageList = 1.5;
  } else if (value >= 4.75) {
    plusPointsallAverageList = 1;
  } else if (value >= 4.25) {
    plusPointsallAverageList = 0.5;
  } else if (value >= 3.75) {
    plusPointsallAverageList = 0;
  } else if (value >= 3.25) {
    plusPointsallAverageList = -1;
  } else if (value >= 2.75) {
    plusPointsallAverageList = -2;
  } else if (value >= 2.25) {
    plusPointsallAverageList = -3;
  } else if (value >= 1.75) {
    plusPointsallAverageList = -4;
  } else if (value >= 1.25) {
    plusPointsallAverageList = -5;
  } else if (value >= 1) {
    plusPointsallAverageList = -6;
  } else if (value == "NaN") {
    plusPoints = 0;
  }
}

TextEditingController addLessonController = new TextEditingController();
TextEditingController addSemesterController = new TextEditingController();
TextEditingController renameTestWeightController = new TextEditingController();
TextEditingController renameSemesterController = new TextEditingController();
TextEditingController addGradeNameController = new TextEditingController();
TextEditingController addGradeGradeController = new TextEditingController();
TextEditingController addTestNameController = new TextEditingController();
TextEditingController addTestGradeController = new TextEditingController();
TextEditingController addTestWeightController = new TextEditingController();
TextEditingController addTestDateController = new TextEditingController();
TextEditingController editTestDateController = new TextEditingController();
TextEditingController contactMessage = new TextEditingController();
TextEditingController dreamGradeGrade = new TextEditingController();
TextEditingController dreamGradeWeight = new TextEditingController();

var testDetails;

getTestDetails() async {
  print(selectedTest);
  testDetails = (await FirebaseFirestore.instance
          .collection(
              "grades/${auth.currentUser.uid}/grades/$selectedLesson/grades/")
          .doc(selectedTest)
          .get())
      .data();
}

getChoosenSemester() async {
  DocumentSnapshot _db = await FirebaseFirestore.instance
      .collection('userData')
      .doc(auth.currentUser.uid)
      .get();

  if (_db.data()['choosenSemester'] == null) {
    print("made");
    FirebaseFirestore.instance
        .collection('userData')
        .doc(auth.currentUser.uid)
        .update({'choosenSemester': 'noSemesterChoosed'});
  } else {
    choosenSemester = _db.data()['choosenSemester'];

    getChoosenSemesterName();
  }
}

getChoosenSemesterName() async {
  DocumentSnapshot _db = await FirebaseFirestore.instance
      .collection('userData')
      .doc(auth.currentUser.uid)
      .get();

  choosenSemesterName = _db.data()['choosenSemesterName'];
}

getgradesResult() async {
  DocumentSnapshot _db = await FirebaseFirestore.instance
      .collection('userData')
      .doc(auth.currentUser.uid)
      .get();

  gradesResult = _db.data()['gradesResult'];
}

getDefaultColor() async {
  print("done");
  try {
    DocumentSnapshot _db = await FirebaseFirestore.instance
        .collection('userData')
        .doc(auth.currentUser.uid)
        .get();

    defaultColor = Color(
        int.parse(_db.data()['defaultColor'].substring(1, 7), radix: 16) +
            0xFF000000);
  } catch (e) {
    print(e);
    defaultColor = Color(0xFF6C63FF);
  }
}

void launchURL(_url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';

getPlusStatus() async {
  try {
    DocumentSnapshot _db = await FirebaseFirestore.instance
        .collection('userData')
        .doc(auth.currentUser.uid)
        .get();

    if (_db.data()['gradelyPlus'] == true) {
      gradelyPlus = true;
    } else {
      gradelyPlus = false;
    }
  } catch (e) {
    gradelyPlus = false;
  }
}
