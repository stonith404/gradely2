import 'package:flutter/material.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';

class Lesson {
  String id;
  String name;
  double average;
  String emoji;

  Lesson(this.id, this.name, this.emoji, this.average);
}

class Semester {
  String id;
  String name;
  double round;

  Semester(this.id, this.name, this.round);
}

class Grade {
  String id;
  String name;
  double grade;
  double weight;
  String date;

  Grade(this.id, this.name, this.grade, this.weight, this.date);
}

class User {
  String id;
  String name;
  int registration;
  int status;
  int passwordUpdate;
  String email;
  bool emailVerification;
  String gradeType;
  String choosenSemester;
  String dbID;
  Color color;
  Future<bool> isSignedIn() async {
    if (await internetConnection()) {
      try {
        await account.get();
        prefs.setBool("signedIn", true);
        return true;
      } catch (_) {
        prefs.setBool("signedIn", false);
        return false;
      }
    } else if (prefs.getBool("signedIn")) {
      return true;
    } else {
      return false;
    }
  }

  User(
    this.id,
    this.name,
    this.registration,
    this.status,
    this.passwordUpdate,
    this.email,
    this.emailVerification,
    this.gradeType,
    this.choosenSemester,
    this.dbID,
  );
}
