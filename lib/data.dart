import 'main.dart';
import 'package:flutter/material.dart';
import 'LessonsDetail.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userAuth/login.dart';
import 'LessonsDetail.dart';


double plusPoints = 0;
getPluspoints(double value) {
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
  }else if (value >= 3.25) {
    plusPoints = -1;
  }else if (value >= 2.75) {
    plusPoints = -2;
  }else if (value >= 2.25) {
    plusPoints = -3;
  }else if (value >= 1.75) {
    plusPoints = -4;
  }else if (value >= 1.25) {
    plusPoints = -5;
  }else if (value >= 1) {
    plusPoints = -6;
  }
}


TextEditingController addLessonController = new TextEditingController();
TextEditingController renameTestWeightController = new TextEditingController();
TextEditingController addGradeNameController = new TextEditingController();
TextEditingController addGradeGradeController = new TextEditingController();
TextEditingController addTestNameController = new TextEditingController();
TextEditingController addTestGradeController = new TextEditingController();
TextEditingController addTestWeightController = new TextEditingController();


var testDetails;

  getTestDetails() async {
     testDetails = (await FirebaseFirestore.instance
                                .collection(
                                    "grades/${auth.currentUser.uid}/grades/$selectedLesson/grades/")
                                .doc(selectedTest)
                                .get())
                            .data();
      
    }