import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gradely/main.dart';
import 'package:gradely/settings/settings.dart';
import 'package:flutter/services.dart';
import 'package:gradely/shared/FUNCTIONS.dart';
import 'package:gradely/shared/VARIABLES.dart';
import 'package:gradely/shared/WIDGETS.dart';
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
  List list = [1, 2, 3, 4, 5, 6, 7, 8, 9];
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
    controllerOne.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    darkModeColorChanger(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: defaultBGColor,
          elevation: 0,
          title: Image.asset(
            'assets/images/iconT.png',
            height: 60,
          ),
          leading: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: IconButton(
                icon: Icon(Icons.segment, color: primaryColor),
                onPressed: () async {
                  HapticFeedback.lightImpact();

                  settingsScreen(context);
                }),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.switch_left, color: primaryColor),
                onPressed: () {}),
          ],
        ),
        body: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                      tileMode: TileMode.mirror,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [animationOne.value, animationTwo.value])
                  .createShader(
                rect,
              );
            },
            child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                child: Column(children: [
                  Container(
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        )),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
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
                                    color: primaryColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  width: 200,
                                  height: 30.0,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15.0),
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
                                      color: primaryColor,
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
                          Spacer(flex: 1),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 15, 10),
                            child: IconButton(
                                icon: Icon(Icons.add),
                                color: Colors.white,
                                onPressed: () {}),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                decoration: listContainerDecoration(
                                    index: index, list: list),
                                child: ListTile(),
                              ),
                              listDivider()
                            ],
                          );
                        }),
                  ),
                ]))));
  }
}

Widget gradelyLoadingIndicator() {
  return Expanded(
    child: Center(
      child: SpinKitWave(
        color: primaryColor,
        size: 20.0,
      ),
    ),
  );
}
