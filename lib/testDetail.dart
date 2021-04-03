import 'main.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userAuth/login.dart';
import 'LessonsDetail.dart';

class TestDetail extends StatefulWidget {
  @override
  _TestDetailState createState() => _TestDetailState();
}

var testDetails;

class _TestDetailState extends State<TestDetail> {
  getTestInfo() async {
    testDetails = (await FirebaseFirestore.instance
            .collection(
                "grades/${auth.currentUser.uid}/grades/$selectedLesson/grades/")
            .doc(selectedTest)
            .get())
        .data();

    setState(() {
      testDetails = testDetails;
    });

    print("testde: " + testDetails.toString());
  }

  void initState() {
    super.initState();
    getTestInfo();
  }

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
        appBar: AppBar(title: Text(testDetails["name"]),),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(testDetails["name"]), Text(testDetails["grade"].toString())],
        ));
  }
}
