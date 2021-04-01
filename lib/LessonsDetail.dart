import 'main.dart';
import 'package:flutter/material.dart';
import 'data.dart';

var currentLesson = "10";
var testGradesFiltered = testGrades.where((f) => f.contains(currentLesson)).toList();

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
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => addGrade()),
              );
            }),
        appBar: AppBar(
          title: Text(currentName),
        ),
        body: Column(children: <Widget>[
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: testGradesFiltered.length,
                  // ignore: missing_return
                  itemBuilder: (BuildContext context, int index) {
            
                    return Container(
                      height: 50,
                      margin: EdgeInsets.all(2),
                      child: Center(
                          child: GestureDetector(
                        onTap: () {
                          LessonDetailIndex(index, testNames[index]);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LessonDetail(),
                              ));
                        },
                        child:   Text(
                          '${testNames[index]} ${testGradesFiltered[index]}',
                          style: TextStyle(fontSize: 18),
                        ),
                      )),
                    );
                  
                  }))
        ]));
  }
}

class addGrade extends StatefulWidget {
  @override
  _addGradeState createState() => _addGradeState();
}

class _addGradeState extends State<addGrade> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("add"),
      ),
      backgroundColor: Colors.white.withOpacity(
          0.85), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: addGradeNameController,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter Lesson Name',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          TextField(
            controller: addGradeGradeController,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter Lesson Name',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            child: Text("add"),
            onPressed: () {
              testNames.add(addGradeNameController.text);
              testGrades.add(addGradeGradeController.text);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LessonDetail()),
              );
              setState(() {
                addGradeNameController.text = "";
              });
            },
          ),
        ],
      ),
    );
  }
}
