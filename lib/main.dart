import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'LessonsDetail.dart';
import 'data.dart';
import 'userAuth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared/defaultWidgets.dart';

bool isLoggedIn = false;

var testList = [];
var courseListID = [];
var allAverageList = [];
String selectedLesson = "";
String selectedLessonName;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: MyApp(),
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.grey[50],
    ),
    darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          color: Colors.black87,
        ),
        textTheme: TextTheme(
          subhead: TextStyle(color: Colors.white),
          title: TextStyle(color: Colors.white),
        )),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyApp> {
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        setState(() {
          isLoggedIn = false;
        });
      } else {
        setState(() {
          isLoggedIn = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
  getLessons() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('grades/${auth.currentUser.uid}/grades')
        .get();
    List<DocumentSnapshot> documents = result.docs;

    courseList = [];
    courseListID = [];
    allAverageList = [];

    documents.forEach((data) => courseList.add(data["name"]));
    documents.forEach((data) => courseListID.add(data.id));
    documents.forEach((data) => allAverageList.add(data["average"]));


  }

  @override
  void initState() { 
    super.initState();
       getLessons();
  }

  @override
  Widget build(BuildContext context) {
   getLessons();
setState(() {
  courseListID  = courseListID;
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
          leading: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              }),
          actions: [
            IconButton(
                icon: Icon(Icons.login),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                }),
          ],
          shape: defaultRoundedCorners(),
          title: Image.asset('assets/iconT.png', height: 60),
        ),
        body: ListView.builder(
          itemCount: courseListID.length,
          itemBuilder: (BuildContext context, int index) {
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: 'More',
                  color: Colors.black45,
                  icon: Icons.more_horiz,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => updateLesson()),
                    );

                    selectedLesson = courseListID[index];
                  },
                ),
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Attention."),
                            content: Text(
                                "Do you want to delete ${courseList[index]} ?"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("No"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text("Delete"),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection(
                                          'grades/${auth.currentUser.uid}/grades/')
                                      .doc(courseListID[index])
                                      .set({});
                                  FirebaseFirestore.instance
                                      .collection(
                                          'grades/${auth.currentUser.uid}/grades/')
                                      .doc(courseListID[index])
                                      .delete();

                                  Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
                (Route<dynamic> route) => false,
              );

                                  selectedLesson = courseListID[index];
                                },
                              )
                            ],
                          );
                        });
                  },
                ),
              ],
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 1))),
                child: ListTile(
                  title: Text(courseList[index]),
                  subtitle: Text(allAverageList[index].toStringAsFixed(2)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LessonsDetail()),
                    );

                    setState(() {
                      selectedLesson = courseListID[index];
                      selectedLessonName = courseList[index];
                    });
                  },
                ),
              ),
            );
          },
        ));
  }
}

var courseList = [];

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
        shape: defaultRoundedCorners(),
      ),
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

              addLessonController.text = "";
              courseList = [];
            },
          ),
        ],
      ),
    );
  }
}

createLesson(String lessonName) {
  CollectionReference gradesCollection = FirebaseFirestore.instance
      .collection('grades/${auth.currentUser.uid}/grades/');
  gradesCollection.doc().set(
    {"name": lessonName, "average": 0},
  );
}

class updateLesson extends StatefulWidget {
  @override
  _updateLessonState createState() => _updateLessonState();
}

class _updateLessonState extends State<updateLesson> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("update"),
        shape: defaultRoundedCorners(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: renameTestWeightController,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter Lesson Name',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            child: Text("update"),
            onPressed: () {
              updateLessonF(renameTestWeightController.text);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
                (Route<dynamic> route) => false,
              );

              renameTestWeightController.text = "";
              courseList = [];
            },
          ),
        ],
      ),
    );
  }
}

updateLessonF(String lessonUpdate) {
  print(selectedLesson);
  FirebaseFirestore.instance
      .collection('grades')
      .doc(auth.currentUser.uid)
      .collection("grades")
      .doc(selectedLesson)
      .update({"name": lessonUpdate});
}
