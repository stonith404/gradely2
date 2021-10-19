import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';

double progress = 0;

// ignore: must_be_immutable
class IntroScreenWrapper extends StatelessWidget {
  int index = 0;
  IntroScreenWrapper(this.index);

  @override
  Widget build(BuildContext context) {
    if (index == 2) {
    } else if (index == 3) {
    } else if (index == 4) {
    } else if (index == 5) {
    } else {
      return _Intro1();
    }
  }
}

class _Intro1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    progress = 0.2;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(
              flex: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: SvgPicture.asset(
                'assets/images/BalletDoodle.svg',
                width: 300,
                color: primaryColor,
              ),
            ),
            Spacer(
              flex: 1,
            ),
            Text("welcome".tr(), style: bigTitle),
            Spacer(
              flex: 1,
            ),
            Text(
              "intro_gradely_helps_monitoring".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            Spacer(
              flex: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                gradelyIconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => _Intro2()),
                      );
                    },
                    icon: Icon(Icons.arrow_forward_ios)),
              ],
            ),
            Spacer(
              flex: 1,
            ),
            LinearProgressIndicator(
              value: progress,
              color: primaryColor,
            ),
            Spacer(
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _Intro2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    progress = 0.4;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(
              flex: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: SvgPicture.asset(
                'assets/images/BalletDoodle.svg',
                width: 300,
                color: primaryColor,
              ),
            ),
            Spacer(
              flex: 1,
            ),
            Text("welcome".tr(), style: bigTitle),
            Spacer(
              flex: 1,
            ),
            Text(
              "intro_gradely_helps_monitoring".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            Spacer(
              flex: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                gradelyIconButton(
                    onPressed: () {}, icon: Icon(Icons.arrow_forward_ios)),
              ],
            ),
            Spacer(
              flex: 1,
            ),
            LinearProgressIndicator(
              value: progress,
              color: primaryColor,
            ),
            Spacer(
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}
