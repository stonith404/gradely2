import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:gradely/main.dart';
import 'package:gradely/shared/CLASSES.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Lesson> lessonList = [];
List<Grade> gradeList = [];
List<Semester> semesterList = [];

User user;

//strings

//bools
bool isLoading = false;
bool darkmode = false;

//num's
double screenwidth = 0;

//appwrite var's
Client client;
Account account;
Database database;

//colors
Color primaryColor = Color(0xFF6C63FF);
Color wbColor;
Color bwColor;
Color defaultBGColor;

//final

final collectionUser = "60f40d07accb6";
final collectionSemester = "60f40d1b66424";
final collectionLessons = "60f40d0ed5da4";
final collectionGrades = "60f71651520e5";

//

SharedPreferences prefs;

//vars for customize
var appBarTextTheme =
    TextStyle(color: primaryColor, fontWeight: FontWeight.w800);

//text controllers

TextEditingController addLessonController = new TextEditingController();
TextEditingController changeEmailController = new TextEditingController();
TextEditingController changeDisplayName = new TextEditingController();
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
