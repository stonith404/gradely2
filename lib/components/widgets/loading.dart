import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:gradely2/components/widgets/decorations.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradely2/screens/settings/settings.dart';
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
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      elevation: 0,
                      title: SvgPicture.asset("assets/images/logo.svg",
                          color: Theme.of(context).primaryColorDark,
                          height: 30),
                      leading: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: IconButton(
                            icon: Icon(Icons.segment,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: () async {
                              settingsScreen(context);
                            }),
                      ),
                      actions: [
                        IconButton(
                            icon: Icon(Icons.switch_left,
                                color: Theme.of(context).primaryColorDark),
                            onPressed: () async {}),
                      ],
                    ),
                  ];
                },
                body: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Column(children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorDark,
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
                                      color: Theme.of(context).primaryColorDark,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    width: 200,
                                    height: 30.0,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
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
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
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
                                  color: Theme.of(context).primaryColorLight,
                                  onPressed: () {}),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Platform.isMacOS || Platform.isWindows
                        ? SizedBox(
                            height: 10,
                          )
                        : Container(),
                    Expanded(
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
                      child: ListView.builder(
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  decoration: listContainerDecoration(context,
                                      index: index, list: list),
                                  child: ListTile(),
                                ),
                                listDivider()
                              ],
                            );
                          }),
                    ))
                  ]),
                ),
              ),
            )));
  }
}

class GradelyLoadingIndicator extends StatefulWidget {
  @override
  _GradelyLoadingIndicatorState createState() =>
      _GradelyLoadingIndicatorState();
}

class _GradelyLoadingIndicatorState extends State<GradelyLoadingIndicator> {
  bool show = false;
  Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 7), (Timer t) {
      setState(() {
        show = true;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Platform.isIOS || Platform.isMacOS
                  ? CupertinoActivityIndicator()
                  : CircularProgressIndicator(
                      color: Theme.of(context).primaryColorDark,
                    ),
              SizedBox(
                height: 30,
              ),
              show
                  ? Text(
                      "no_network_offline_loading".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 15,
                          fontStyle: FontStyle.italic),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
