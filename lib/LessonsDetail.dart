import 'main.dart';
import 'package:flutter/material.dart';
import 'data.dart';

class LessonsDetail extends StatefulWidget {


  @override
  _LessonsDetailState createState() => _LessonsDetailState();
}

class _LessonsDetailState extends State<LessonsDetail> {
  void initState() {
    super.initState();
    getTests(selectedLesson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ListView.builder(
          itemCount: testList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(testList[index]),
              onTap: () {
                getTests(testList[index]);
                print(testList[index]);
              },
            );
          },
        ));
  }
}
