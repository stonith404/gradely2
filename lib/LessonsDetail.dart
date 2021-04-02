import 'main.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userAuth/login.dart';

class LessonsDetail extends StatefulWidget {
  @override
  _LessonsDetailState createState() => _LessonsDetailState();
}

class _LessonsDetailState extends State<LessonsDetail> {
  
  getTests() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(
            'grades/${auth.currentUser.uid}/grades/$selectedLesson/grades')
        .get();
    List<DocumentSnapshot> documents = result.docs;
    setState(() {
      documents.forEach((data) => testList.add(data.id));
    });

    print(testList);
  }

  void initState() {
    super.initState();
    getTests();
  }

  @override
  Widget build(BuildContext context) {
    print("object" + testList.toString());
    return Scaffold(
        appBar: AppBar(),
        body: ListView.builder(
          itemCount: testList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(testList[index]),
              onTap: () {
                print(testList[index]);
              },
            );
          },
        ));
  }
}
