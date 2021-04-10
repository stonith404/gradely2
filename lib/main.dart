import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'LessonsDetail.dart';
import 'data.dart';
import 'userAuth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared/defaultWidgets.dart';
import 'chooseSemester.dart';
import 'dart:math' as math;
import 'settings/settings.dart';
import 'package:gradely/introScreen.dart';
import 'dart:async';

bool isLoggedIn = false;
const defaultBlue = Color(0xFF6C63FF);
var testList = [];
var courseListID = [];
var allAverageList = [];
var allAverageListPP = [];
String selectedLesson = "";
String selectedLessonName;
double averageOfLessons = 0 / -0;
num averageOfLessonsPP = 0 / -0;
String choosenSemesterName = "noSemesterChoosed";
var wbColor = Colors.white;
var bwColor = Colors.black;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: MyApp(),
    theme: ThemeData(
      fontFamily: 'Nunito',
      brightness: Brightness.light,
      primaryColor: defaultBlue,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(defaultBlue)),
      ),
    ),
    darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: defaultBlue,
        appBarTheme:
            AppBarTheme(color: Colors.black87, foregroundColor: Colors.white),
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
    timer = Timer.periodic(
        Duration(seconds: 1), (Timer t) => darkModeColorChanger());
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

  darkModeColorChanger() {
    var brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) {
      setState(() {
        bwColor = Colors.black;
        wbColor = Colors.white;
      });
    } else {
      bwColor = Colors.white;
      wbColor = Colors.black;
    }
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    getChoosenSemester();
    if (isLoggedIn) {
      if (choosenSemester == "noSemesterChoosed") {
        return chooseSemester();
      } else {
        return HomeSite();
      }
    } else {
      return LoginScreen();
    }
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
        .collection(
            'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/')
        .get();
    List<DocumentSnapshot> documents = result.docs;

    courseList = [];
    courseListID = [];
    allAverageList = [];
    allAverageListPP = [];
    setState(() {
      documents.forEach((data) => courseList.add(data["name"]));
      documents.forEach((data) => courseListID.add(data.id));
      documents.forEach((data) => allAverageList.add(data["average"]));

      documents.forEach((data) {
        getPluspointsallAverageList(data["average"]);

        allAverageListPP.add(plusPointsallAverageList.toString());
      });
    });

    //get average of all

    double _sum = 0;
    double _anzahl = 0;
    for (num e in allAverageList) {
      if (e.isNaN) {
      } else {
        _sum += e;
        _anzahl = _anzahl + 1;
        setState(() {
          averageOfLessons = _sum / _anzahl;
        });
      }
    }

    getPluspointsallAverageList(averageOfLessons);
    setState(() {
      averageOfLessonsPP = plusPointsallAverageList;
    });
  }

  @override
  void initState() {
    super.initState();
    getLessons();
    getChoosenSemester();
    getgradesResult();
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    getLessons();

    return Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => addLesson()),
              );
            }),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: defaultBlue,
                forceElevated: true,
                title: Image.asset(
                  'assets/iconT.png',
                  height: 60,
                ),
                bottom: PreferredSize(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 50, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                choosenSemesterName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: Colors.white),
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  child: (() {
                                    if (gradesResult == "Durchschnitt") {
                                      if (averageOfLessons.isNaN) {
                                        return Text("Notendurchschnitt: -",
                                            style:
                                                TextStyle(color: Colors.white));
                                      }
                                      return Text(
                                          "Notendurchschnitt: ${averageOfLessons.toStringAsFixed(2)}",
                                          style:
                                              TextStyle(color: Colors.white));
                                    } else if (averageOfLessons.isNaN) {
                                      return Text(
                                          "Pluspunkte: ${averageOfLessonsPP.toStringAsFixed(2)} / Notendurchschnitt: -",
                                          style:
                                              TextStyle(color: Colors.white));
                                    } else {
                                      return Text(
                                          "Pluspunkte: ${averageOfLessonsPP.toStringAsFixed(2)} / Notendurchschnitt: ${averageOfLessons.toStringAsFixed(2)}",
                                          style:
                                              TextStyle(color: Colors.white));
                                    }
                                  }())),
                            ],
                          ),
                        ),
                      ],
                    ),
                    preferredSize: Size(0, 130)),
                leading: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: IconButton(
                      icon: Icon(Icons.segment),
                      onPressed: () async {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage()),
                        );
                      }),
                ),
                floating: true,
                actions: [
                  IconButton(
                      icon: Icon(Icons.switch_left),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => chooseSemester()),
                        );
                      }),
                ],
                shape: defaultRoundedCorners(),
              ),
            ];
          },
          body: ListView.builder(
            itemCount: courseListID.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                child: Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'unbennen',
                      color: Colors.black45,
                      icon: Icons.edit,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => updateLesson()),
                        );
                        selectedLessonName = courseList[index];
                        selectedLesson = courseListID[index];
                      },
                    ),
                    IconSlideAction(
                      caption: 'löschen',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Attention."),
                                content: Text(
                                    "Bist du sicher, dass du ${courseList[index]} löschen willst?"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("Nein"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("Löschen"),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection(
                                              'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/')
                                          .doc(courseListID[index])
                                          .set({});
                                      FirebaseFirestore.instance
                                          .collection(
                                              'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/')
                                          .doc(courseListID[index])
                                          .delete();

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyApp()),
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
                    decoration: boxDec(),
                    child: ListTile(
                      title: Text(courseList[index],
                          style: TextStyle(color: Colors.white)),
                      trailing: ((() {
                        if (allAverageList[index].isNaN) {
                          return Text("-",
                              style: TextStyle(color: Colors.white));
                        } else if (gradesResult == "Pluspunkte") {
                          return Text(allAverageListPP[index],
                              style: TextStyle(color: Colors.white));
                        } else {
                          return Text(allAverageList[index].toStringAsFixed(2),
                              style: TextStyle(
                                color: Colors.white,
                              ));
                        }
                      })()),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LessonsDetail()),
                        );

                        setState(() {
                          selectedLesson = courseListID[index];
                          selectedLessonName = courseList[index];
                        });

                        getTestDetails();
                      },
                    ),
                  ),
                ),
              );
            },
          ),
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
        title: Text("Fach Hinzufügen"),
        shape: defaultRoundedCorners(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: addLessonController,
                textAlign: TextAlign.left,
                decoration: inputDec("Fach Name")),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
            child: Text("hinzufügen"),
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
  CollectionReference gradesCollection = FirebaseFirestore.instance.collection(
      'userData/${auth.currentUser.uid}/semester/$choosenSemester/lessons/');
  gradesCollection.doc().set(
    {"name": lessonName, "average": 0 / -0}, //generate NaN
  );
}

class updateLesson extends StatefulWidget {
  @override
  _updateLessonState createState() => _updateLessonState();
}

class _updateLessonState extends State<updateLesson> {
  @override
  Widget build(BuildContext context) {
    renameTestWeightController.text = selectedLessonName;
    return Scaffold(
      appBar: AppBar(
        title: Text("Fach unbennen"),
        shape: defaultRoundedCorners(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                controller: renameTestWeightController,
                textAlign: TextAlign.left,
                decoration: inputDec("Fach Name")),
            ElevatedButton(
              child: Text("unbennen"),
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
      ),
    );
  }
}

updateLessonF(String lessonUpdate) {
  FirebaseFirestore.instance
      .collection('userData')
      .doc(auth.currentUser.uid)
      .collection('semester')
      .doc(choosenSemester)
      .collection('lessons')
      .doc(selectedLesson)
      .update({"name": lessonUpdate});
}
