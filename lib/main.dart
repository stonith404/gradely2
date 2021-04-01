import 'package:flutter/material.dart';
import 'LessonsDetail.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyApp> {
  addItem() {
    setState(() {
      names.add("test");
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      names = names;
    });
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => addScreen()),
              );
            }),
        appBar: AppBar(
          title: Text('Flutter Tutorial - googleflutter.com'),
        ),
        body: Column(children: <Widget>[
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: names.length,
                  itemBuilder: (BuildContext context, int index) {
                 
                    return Container(
                      height: 50,
                      margin: EdgeInsets.all(2),
                      child: Center(
                          child: GestureDetector(
                        onTap: () {
                          LessonDetailIndex(index, names[index]);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LessonDetail(),
                              ));
                        },
                        child: Text(
                          '${names[index]} $index',
                          style: TextStyle(fontSize: 18),
                        ),
                      )),
                    );
                  }))
        ]));
  }
}

List<String> names = <String>[
  'Aby',
  'Aish',
  'Ayan',
  'Ben',
  'Bob',
  'Charlie',
  'Cook',
  'Carline'
];

class addScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(
          0.85), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            child: Text("add"),
            onPressed: () {
              names.add("test");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
          ),
        ],
      ),
    );
  }
}

int currentIndex = 0;
String currentName = "";
LessonDetailIndex(int index, String names) {
  currentIndex = index;
  currentName = names;
}
