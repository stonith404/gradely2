import "dart:async";
import "package:appwrite/appwrite.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/utils/api.dart";
import "package:gradely2/components/models.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:universal_io/io.dart';

late User user;
late SharedPreferences prefs;

//bools
bool isLoading = false;
bool isCupertino = (() {
  return Platform.isIOS || Platform.isMacOS;
}());

//appwrite var's
late Client client;
late Account account;
late Database database;
Locale? locale;
Storage? storage;
late Functions functions;
late GradelyApi api;

//final
const collectionUser = "60f40d07accb6";
const collectionSemester = "60f40d1b66424";
const collectionSubjects = "60f40d0ed5da4";
const collectionGrades = "60f71651520e5";

//vars for customizing
var bigTitle = TextStyle(
    fontWeight: FontWeight.w900, fontFamily: "PlayfairDisplay", fontSize: 30);

var title = TextStyle(
    fontWeight: FontWeight.w900, fontFamily: "PlayfairDisplay", fontSize: 21);

//Streams
StreamController<bool> isLoadingController = StreamController<bool>.broadcast();
Stream isLoadingStream = isLoadingController.stream;
