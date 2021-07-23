import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:gradely/shared/CLASSES.dart';

List<Lesson> lessonList = [];
List<Grade> gradeList = [];

User user;

//appwrite var's
Client client;
Account account;
Database database;

//colors
Color wbColor;
Color bwColor;

//final

final collectionUser = "60f40d07accb6";
final collectionSemester = "60f40d1b66424";
final collectionLessons = "60f40d0ed5da4";
final collectionGrades = "60f71651520e5";
