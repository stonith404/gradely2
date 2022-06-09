import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:gradely2/components/controllers/user_controller.dart";
import "package:gradely2/components/utils/app.dart";
import "package:gradely2/components/widgets/buttons.dart";
import "package:gradely2/components/widgets/toast.dart";
import "package:gradely2/screens/auth/auth_home.dart";
import "package:gradely2/screens/main/subjects/subjects.dart";
import "package:gradely2/components/variables.dart";

class MaintenanceScreen extends StatelessWidget {
  MaintenanceScreen({Key? key}) : super(key: key);
  final UserController userController = UserController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 1,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Spacer(
              flex: 12,
            ),
            SvgPicture.asset(
              "assets/images/DumpingDoodle.svg",
              color: Theme.of(context).primaryColorDark,
              height: 200,
            ),
            Spacer(
              flex: 4,
            ),
            Text(
              "maintenance".tr(),
              style: bigTitle,
              textAlign: TextAlign.center,
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
            SizedBox(
                width: 300,
                child: gradelyButton(
                    onPressed: () async {
                      isLoadingController.add(true);
                      if (await (isMaintenance())) {
                        toast.error(
                            context,
                            title: "sorry".tr(),
                            text: "still_maintenance".tr());
                      } else if (await userController.isSignedIn()) {
                        Navigator.pushReplacement(
                          context,
                          GradelyPageRoute(
                              builder: (context) => SubjectScreen()),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          GradelyPageRoute(
                              builder: (context) => AuthHomeScreen()),
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
