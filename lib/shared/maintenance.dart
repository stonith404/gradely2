import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradely2/main.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';

class MaintenanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: defaultBGColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Spacer(
              flex: 12,
            ),
            SvgPicture.asset(
              "assets/images/DumpingDoodle.svg",
              color: primaryColor,
              height: 200,
            ),
            Spacer(
              flex: 4,
            ),
            Text(
              "maintenance".tr(),
              style: bigTitle,
            ),
            Spacer(
              flex: 1,
            ),
            Text(
              "maintenance_description".tr(),
              textAlign: TextAlign.center,
            ),
            Text(
              "maintenance_hurry".tr(),
              textAlign: TextAlign.center,
            ),
            Spacer(
              flex: 20,
            ),
            Container(
                width: 300,
                child: gradelyButton(
                    onPressed: () async {
                      isLoadingController.add(true);
                      if (await isMaintenance()) {
                        errorSuccessDialog(
                            context: context,
                            error: true,
                            title: "sorry".tr(),
                            text: "still_maintenance".tr());
                      } else {
                        Navigator.pushReplacement(
                          context,
                          GradelyPageRoute(builder: (context) => HomeWrapper()),
                        );
                      }
                      isLoadingController.add(false);
                    },
                    text: "try_again".tr())),
            Spacer(
              flex: 1,
            ),
            Spacer(
              flex: 8,
            ),
          ]),
        ),
      ),
    );
  }
}
