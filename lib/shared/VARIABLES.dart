import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:gradely/main.dart';
import 'package:gradely/shared/CLASSES.dart';

List<Lesson> lessonList = [];
List<Grade> gradeList = [];
List<Semester> semesterList = [];

User user;

//bools
bool isLoading = false;
bool darkmode = false;

//int's
double screenwidth = 0;

//appwrite var's
Client client;
Account account;
Database database;

//colors
Color wbColor;
Color bwColor;
Color defaultBGColor;

//final

final collectionUser = "60f40d07accb6";
final collectionSemester = "60f40d1b66424";
final collectionLessons = "60f40d0ed5da4";
final collectionGrades = "60f71651520e5";

//vars for customize
var appBarTextTheme =
    TextStyle(color: primaryColor, fontWeight: FontWeight.w800);
