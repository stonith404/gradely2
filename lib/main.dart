import 'package:flutter/material.dart';
import 'LessonsDetail.dart';
import 'data.dart';
import 'userAuth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

bool isLoggedIn = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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

  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        setState(() {
          isLoggedIn = false;
        });
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
        print(auth.currentUser.uid);
        setState(() {
          isLoggedIn = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      names = names;
    });
    return isLoggedIn ? HomeSite() : LoginScreen();
  }
}

class HomeSite extends StatelessWidget {
  const HomeSite({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => addLesson()),
              );
            }),
        appBar: AppBar(
          actions: [
            IconButton(
                icon: Icon(Icons.login),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                })
          ],
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

createLesson(String lessonName) {
  CollectionReference gradesCollection =
      FirebaseFirestore.instance.collection('grades');
  return gradesCollection.doc(auth.currentUser.uid).update({
    lessonName: [5, true, "hello"],
  });
}

getLessons(String lessonName) {
  CollectionReference gradesCollection =
      FirebaseFirestore.instance.collection('grades');
  var list = gradesCollection.doc(auth.currentUser.uid).get();
  Future<DocumentSnapshot> names = list;
}



class addLesson extends StatefulWidget {
  @override
  _addLessonState createState() => _addLessonState();
}

class _addLessonState extends State<addLesson> {
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
            controller: addLessonController,
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
              createLesson(addLessonController.text);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
                (Route<dynamic> route) => false,
              );

              setState(() {
                addLessonController.text = "";
              });
            },
          ),
        ],
      ),
    );
  }
}
