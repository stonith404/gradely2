import 'dart:async';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:gradely2/components/functions/api.dart';
import 'package:gradely2/components/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

List lessonList = [];
List gradeList = [];
List semesterList = [];

User user;
SharedPreferences prefs;

//bools
bool isLoading = false;
bool isCupertino = (() {
  return Platform.isIOS || Platform.isMacOS;
}());

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

//final
const collectionUser = '60f40d07accb6';
const collectionSemester = '60f40d1b66424';
const collectionLessons = '60f40d0ed5da4';
const collectionGrades = '60f71651520e5';

//vars for customizing
var bigTitle = TextStyle(
    fontWeight: FontWeight.w900, fontFamily: 'PlayfairDisplay', fontSize: 30);

var title = TextStyle(
    fontWeight: FontWeight.w900, fontFamily: 'PlayfairDisplay', fontSize: 21);

//text controllers

TextEditingController addLessonController = TextEditingController();
TextEditingController changeEmailController = TextEditingController();
TextEditingController changeDisplayName = TextEditingController();
TextEditingController addSemesterController = TextEditingController();
TextEditingController renameTestWeightController = TextEditingController();
TextEditingController renameSemesterController = TextEditingController();
TextEditingController addGradeNameController = TextEditingController();
TextEditingController addGradeGradeController = TextEditingController();
TextEditingController addTestNameController = TextEditingController();
TextEditingController addTestGradeController = TextEditingController();
TextEditingController addTestWeightController = TextEditingController();
TextEditingController addTestDateController = TextEditingController();
TextEditingController editTestDateController = TextEditingController();
TextEditingController contactMessage = TextEditingController();
TextEditingController dreamGradeGrade = TextEditingController();
TextEditingController dreamGradeWeight = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController passwordPlaceholder = TextEditingController();
TextEditingController editTestInfoName = TextEditingController();
TextEditingController editTestInfoGrade = TextEditingController();
TextEditingController editTestInfoWeight = TextEditingController();

//Streams
StreamController<bool> isLoadingController = StreamController<bool>.broadcast();
Stream isLoadingStream = isLoadingController.stream;
