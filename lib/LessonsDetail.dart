import 'main.dart';
import 'package:flutter/material.dart';



class LessonDetail extends StatefulWidget {
  @override
  _LessonDetailState createState() => _LessonDetailState();
}

class _LessonDetailState extends State<LessonDetail> {
  @override
  Widget build(BuildContext context) {
setState(() {
   currentIndex = currentIndex;
  currentName = currentName; 
});
    return Scaffold(
      appBar: AppBar(title: Text(currentName),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(currentIndex.toString()),
          Text("nAme: " + currentName)
        ],
      ),
    );
  }
}
