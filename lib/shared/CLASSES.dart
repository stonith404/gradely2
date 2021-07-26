import 'package:flutter/material.dart';

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

  Semester(this.id, this.name);
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
  bool gradelyPlus;
  String gradeType;
  String choosenSemester;
  String dbID;
  Color color;

  User(
      this.id,
      this.name,
      this.registration,
      this.status,
      this.passwordUpdate,
      this.email,
      this.emailVerification,
      this.gradelyPlus,
      this.gradeType,
      this.choosenSemester,
      this.dbID,
      this.color);
}
