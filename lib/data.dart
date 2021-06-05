import 'dart:io';

import 'main.dart';
import 'package:flutter/material.dart';
import 'LessonsDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userAuth/login.dart';
import 'LessonsDetail.dart';
import 'chooseSemester.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'userAuth/login.dart';

final String cacheField = 'updatedAt';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
num plusPoints = 0;
bool gradelyPlus = false;
bool isMaintanceEnabled = false;
String gradesResult = "Pluspunkte";
num plusPointsallAverageList = 0;
Timer timer;
DocumentSnapshot uidDB;
String releaseNotes = "";

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
TextEditingController changeEmailController = new TextEditingController();
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
TextEditingController passwordController = new TextEditingController();
TextEditingController passwordPlaceholder = new TextEditingController();
TextEditingController editTestInfoName = new TextEditingController();
TextEditingController editTestInfoGrade = new TextEditingController();
TextEditingController editTestInfoWeight = new TextEditingController();
var testDetails;

formatDate(picked) {
  var _formatted = DateTime.parse(picked.toString());
  return "${_formatted.year}.${_formatted.month}.${_formatted.day}";
}

getUIDDocuments() async {
  uidDB = await FirebaseFirestore.instance
      .collection('userData')
      .doc(auth.currentUser.uid)
      .get();

  gradesResult = uidDB.get('gradesResult');
  choosenSemesterName = uidDB.get('choosenSemesterName');

  if (uidDB.get('gradelyPlus') == true) {
    gradelyPlus = true;
  } else {
    gradelyPlus = false;
  }

  if (uidDB.get('choosenSemester') == null) {
    FirebaseFirestore.instance
        .collection('userData')
        .doc(auth.currentUser.uid)
        .update({'choosenSemester': 'noSemesterChoosed'});
  } else {
    choosenSemester = uidDB.get('choosenSemester');
  }
  try {
    if (uidDB.get('defaultColor') != null) {
      defaultColor = Color(
          int.parse(uidDB.get('defaultColor').substring(1, 7), radix: 16) +
              0xFF000000);
    } else {
      defaultColor = Color(0xFF6C63FF);
    }
  } catch (e) {
    defaultColor = Color(0xFF6C63FF);
  }
}

void launchURL(_url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';

getUserAuthStatus() {
  if (FirebaseAuth.instance.currentUser == null) {
    navigatorKey.currentState.pushNamed('/settings');
  }
}

getReleaseNotes() async {
  uidDB = await FirebaseFirestore.instance
      .collection('shared/releaseNotes/releaseNotes/')
      .doc("1.0.3")
      .get();
if(Platform.localeName == "de"){
  releaseNotes = uidDB.get('de');
}else{
  releaseNotes = uidDB.get('en');
}
}
