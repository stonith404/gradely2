import 'package:flutter/material.dart';
import 'package:gradely/main.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gradely/LessonsDetail.dart';
import 'package:gradely/shared/loading.dart';
import 'package:gradely/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradely/introScreen.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:gradely/semesterDetail.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'defaultWidgets.dart';
import 'dart:math' as math;

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controllerOne;
  Animation<Color> animationOne;
  Animation<Color> animationTwo;

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

    controllerOne = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    animationOne = ColorTween(begin: Colors.white, end: Colors.grey[300])
        .animate(controllerOne);
    animationTwo = ColorTween(begin: Colors.grey[300], end: Colors.white)
        .animate(controllerOne);
    controllerOne.forward();
    controllerOne.addListener(() {
      if (controllerOne.status == AnimationStatus.completed) {
        controllerOne.reverse();
      } else if (controllerOne.status == AnimationStatus.dismissed) {
        controllerOne.forward();
      }
      this.setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controllerOne.dispose();

  }


  @override
  Widget build(BuildContext context) {
    darkModeColorChanger();
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
                          ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                  tileMode: TileMode.mirror,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    animationOne.value,
                                    animationTwo.value
                                  ]).createShader(
                                rect,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: defaultColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              width: 200,
                              height: 30.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return LinearGradient(
                                    tileMode: TileMode.mirror,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      animationOne.value,
                                      animationTwo.value
                                    ]).createShader(
                                  rect,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: defaultColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                width: 200,
                                height: 17.0,
                              ),
                            ),
                          )
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
              child:
                  IconButton(icon: Icon(Icons.segment), onPressed: () async {}),
            ),
            floating: true,
            actions: [
              IconButton(icon: Icon(Icons.switch_left), onPressed: () async {}),
            ],
            shape: defaultRoundedCorners(),
          ),
        ];
      },
      body: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
              tileMode: TileMode.mirror,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [animationOne.value, animationTwo.value]).createShader(
            rect,
          );
        },
        child: ListView.builder(
            itemCount: 10,
            itemBuilder: (index, context) {
              return Padding(
                  padding: EdgeInsets.fromLTRB(8, 5, 8, 0),
                  child: Container(
                    decoration: boxDec(),
                    child: ListTile(),
                  ));
            }),
      ),
    ));
  }
}

class LoadingBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.white,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            height: 8.0,
            color: Colors.white,
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            width: double.infinity,
            height: 8.0,
            color: Colors.white,
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            width: 40.0,
            height: 8.0,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
