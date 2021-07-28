import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gradely/GRADELY_OLD/data.dart';
import 'package:gradely/GRADELY_OLD/main.dart';
import 'package:gradely/GRADELY_OLD/settings/settings.dart';
import 'package:flutter/services.dart';
import 'package:gradely/GRADELY_OLD/shared/defaultWidgets.dart';
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
        body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            backgroundColor: primaryColor,
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
                                color: primaryColor,
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
                preferredSize: Size(0, 130)),
            leading: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: IconButton(
                  icon: Icon(Icons.segment),
                  onPressed: () async {
                    settingsScreen(context);
                  }),
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

class LoadingInApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpinKitDoubleBounce(
        color: primaryColor,
      ),
    );
  }
}
