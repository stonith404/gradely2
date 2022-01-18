import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:gradely2/shared/MODELS.dart';
import 'package:gradely2/shared/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

List lessonList = [];
List gradeList = [];
List semesterList = [];

User user;
SharedPreferences prefs;

//strings
String brightness = "light";

//bools
bool isLoading = false;
bool darkmode = false;

//num's
double screenwidth = 0;

//appwrite var's
Client client;
Account account;
Database database;
Locale locale;
Storage storage;
Functions functions;
GradelyApi api;

//colors
Color wbColor;

//final

final collectionUser = "60f40d07accb6";
final collectionSemester = "60f40d1b66424";
final collectionLessons = "60f40d0ed5da4";
final collectionGrades = "60f71651520e5";

//vars for customize
var appBarTextTheme = TextStyle();

var bigTitle = TextStyle(
    // color: Theme.of(context).primaryColorDark,
    fontWeight: FontWeight.w900,
    fontFamily: "PlayfairDisplay",
    fontSize: 30);

var title = TextStyle(
    // color: Theme.of(context).primaryColorDark,
    fontWeight: FontWeight.w900,
    fontFamily: "PlayfairDisplay",
    fontSize: 21);

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
TextEditingController emailController = new TextEditingController();
TextEditingController nameController = new TextEditingController();
TextEditingController passwordController = new TextEditingController();
TextEditingController passwordPlaceholder = new TextEditingController();
TextEditingController editTestInfoName = new TextEditingController();
TextEditingController editTestInfoGrade = new TextEditingController();
TextEditingController editTestInfoWeight = new TextEditingController();

//Streams
StreamController<bool> isLoadingController = StreamController<bool>.broadcast();
Stream isLoadingStream = isLoadingController.stream;
