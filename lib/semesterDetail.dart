import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely/shared/loading.dart';
import 'LessonsDetail.dart';
import 'data.dart';
import 'userAuth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared/defaultWidgets.dart';
import 'chooseSemester.dart';
import 'dart:math' as math;
import 'settings/settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

List semesterAveragePP = [];

class HomeSite extends StatefulWidget {
  const HomeSite({
    Key key,
  }) : super(key: key);

  @override
  _HomeSiteState createState() => _HomeSiteState();
}

class _HomeSiteState extends State<HomeSite> {
  pushNotification() {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
    });
// Asks permission for push notifcations in ios
    _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
  }

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
    semesterAveragePP = [];

    setState(() {
      documents.forEach((data) => courseList.add(data["name"]));
      documents.forEach((data) => courseListID.add(data.id));
      documents.forEach((data) => allAverageList.add(data["average"]));

      documents.forEach((data) {
        getPluspointsallAverageList(data["average"]);
        if (data["average"].isNaN) {
          allAverageListPP.add(0.toString());
          semesterAveragePP.add(0);
        } else {
          allAverageListPP.add(plusPointsallAverageList.toString());
          semesterAveragePP.add(plusPointsallAverageList);
        }
      });
    });

    //getSemesteraverage
    num _pp = 0;

    for (num e in semesterAveragePP) {
      _pp += e;
    }
    setState(() {
      averageOfSemesterPP = _pp;
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
          averageOfSemester = _sum / _anzahl;
        });
      }
    }
  }

  darkModeColorChanger() {
    var brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) {
      setState(() {
        bwColor = Colors.grey[850];
        wbColor = Colors.white;
      });
    } else {
      bwColor = Colors.white;
      wbColor = Colors.grey[850];
    }
  }

  @override
  void initState() {
    super.initState();
    getPlusStatus();
    getLessons();
    getChoosenSemester();
    getgradesResult();
    pushNotification();
  }


  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    getLessons();
    darkModeColorChanger();

    if (choosenSemesterName == "noSemesterChoosed") {
      return LoadingScreen();
    } else {
      return Scaffold(
          body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: defaultColor,
              forceElevated: true,
              title: Image.asset(
                'assets/images/iconT.png',
                height: 60,
              ),
              bottom: PreferredSize(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                child: (() {
                                  if (gradesResult == "Durchschnitt") {
                                    if (averageOfSemester.isNaN) {
                                      return Text(
                                          "${'Notendurchschnitt'.tr()}: -",
                                          style:
                                              TextStyle(color: Colors.white));
                                    }
                                    return Text(
                                        "${'Notendurchschnitt'.tr()}: ${averageOfSemester.toStringAsFixed(2)}",
                                        style: TextStyle(color: Colors.white));
                                  } else if (averageOfSemester.isNaN) {
                                    return Text(
                                        "${'Pluspunkte'.tr()}: ${averageOfSemesterPP.toStringAsFixed(2)} / ${'Notendurchschnitt'.tr()}: -",
                                        style: TextStyle(color: Colors.white));
                                  } else {
                                    return Text(
                                        "${'Pluspunkte'.tr()}: ${averageOfSemesterPP.toStringAsFixed(2)} / ${'Notendurchschnitt'.tr()}: ${averageOfSemester.toStringAsFixed(2)}",
                                        style: TextStyle(color: Colors.white));
                                  }
                                }())),
                          ],
                        ),
                      ),
                      Spacer(flex: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 15, 10),
                        child: IconButton(
                            icon: Icon(Icons.add),
                            color: Colors.white,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => addLesson()),
                              );
                            }),
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
                      HapticFeedback.lightImpact();

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    }),
              ),
              floating: true,
              actions: [
                IconButton(
      
                    icon: Icon(Icons.switch_left),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
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
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 5, 8, 0),
                  child: Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: 'unbenennen'.tr(),
                        color: defaultColor,
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
                        caption: 'löschen'.tr(),
                        color: defaultColor,
                        icon: Icons.delete,
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Achtung".tr()),
                                  content: Text(
                                      "${'Bist du sicher, dass du'.tr()} ${courseList[index]} ${'löschen willst?'.tr()}"),
                                  actions: <Widget>[
                                    FlatButton(
                                      color: defaultColor,
                                      child: Text("Nein".tr()),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      color: defaultColor,
                                      child: Text("Löschen".tr()),
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
                                        HapticFeedback.heavyImpact();
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeWrapper()),
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
                        title: Row(
                          children: [
                            Text(
                              courseList[index],
                            ),
                          ],
                        ),
                        trailing: ((() {
                          if (allAverageList[index].isNaN) {
                            return Text(
                              "-",
                            );
                          } else if (gradesResult == "Pluspunkte") {
                            return Text(
                              allAverageListPP[index],
                            );
                          } else {
                            return Text(
                              allAverageList[index].toStringAsFixed(2),
                            );
                          }
                        })()),
                        onTap: () {
                          HapticFeedback.lightImpact();
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
                ),
              ],
            );
          },
        ),
      ));
    }
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
        backgroundColor: defaultColor,
        title: Text("Fach hinzufügen".tr()),
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
                decoration: inputDec("Fach Name".tr())),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: defaultColor,
            ),
            child: Text("hinzufügen".tr()),
            onPressed: () {
              createLesson(addLessonController.text);
              HapticFeedback.mediumImpact();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeWrapper()),
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
        backgroundColor: defaultColor,
        title: Text("Fach unbenennen".tr()),
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
                decoration: inputDec("Fach Name".tr())),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: defaultColor,
              ),
              child: Text("unbenennen".tr()),
              onPressed: () {
                updateLessonF(renameTestWeightController.text);
                HapticFeedback.mediumImpact();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeWrapper()),
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
