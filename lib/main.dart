import 'package:flutter/material.dart';
import 'LessonsDetail.dart';
import 'data.dart';
import 'userAuth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

bool isLoggedIn = false;

var testList = [];

String selectedLesson = "";

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


  void initState() {
    super.initState();


    getLessons();
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

class HomeSite extends StatefulWidget {
  const HomeSite({
    Key key,
  }) : super(key: key);

  @override
  _HomeSiteState createState() => _HomeSiteState();
}



class _HomeSiteState extends State<HomeSite> {
  
  @override
  Widget build(BuildContext context) {
        setState(() {
      testList = [];
    });
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
          title: Text('Gradely'),
        ),
        body: ListView.builder(
          itemCount: courseList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(courseList[index]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LessonsDetail()),
                );

                setState(() {
                  selectedLesson = courseList[index];
                });

                print(courseList[index]);
              },
            );
          },
        ));
  }
}






var courseList = [];

Future<String> getLessons() async {
  final QuerySnapshot result = await FirebaseFirestore.instance
      .collection('grades/${auth.currentUser.uid}/grades')
      .get();
  List<DocumentSnapshot> documents = result.docs;
  documents.forEach((data) => courseList.add(data.id));
  print(courseList);
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

createLesson(String lessonName) {
  CollectionReference gradesCollection =
      FirebaseFirestore.instance.collection('grades/${auth.currentUser.uid}/grades/');
   gradesCollection.doc(lessonName).set({
    
  });
  
}