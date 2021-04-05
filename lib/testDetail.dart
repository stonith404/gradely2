import 'main.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userAuth/login.dart';
import 'LessonsDetail.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TestDetail extends StatefulWidget {
  @override
  _TestDetailState createState() => _TestDetailState();
}


class _TestDetailState extends State<TestDetail> {
  

  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    
 
    // return Scaffold(
    //     appBar: AppBar(title: Text(testDetails["name"]),),
    //     body: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [Text(testDetails["name"]), Text(testDetails["grade"].toString())],
    //     ));
  }
}
