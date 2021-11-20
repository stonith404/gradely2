import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';

double progress = 0;

// ignore: must_be_immutable
class _IntroScreenWrapper extends StatelessWidget {
  Widget child;

  _IntroScreenWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          iconTheme: IconThemeData(color: primaryColor),
          title: SvgPicture.asset("assets/images/logo.svg",
              color: primaryColor, height: 30),
          backgroundColor: defaultBGColor,
          elevation: 0,
          actions: [
            progress >= 0.76
                ? IconButton(
                    color: primaryColor,
                    icon: Icon(FontAwesome5Solid.sign_out_alt),
                    onPressed: () async {
                      await signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "auth/home",
                        (Route<dynamic> route) => false,
                      );
                    },
                  )
                : Container(),
          ],
        ),
        body: Padding(padding: const EdgeInsets.all(24.0), child: child));
  }
}

Widget progressIndicator() {
  return ClipRRect(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    child: LinearProgressIndicator(
      value: progress,
      color: primaryColor,
    ),
  );
}

class Intro1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    progress = 0.16;
    return _IntroScreenWrapper(
      child: Column(
        children: [
          Spacer(
            flex: 6,
          ),
          SvgPicture.asset(
            'assets/images/BalletDoodle.svg',
            width: 300,
            color: primaryColor,
          ),
          Spacer(
            flex: 1,
          ),
          Text("welcome".tr(), textAlign: TextAlign.center, style: bigTitle),
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
                      GradelyPageRoute(builder: (context) => _Intro2()),
                    );
                  },
                  icon: Icon(Icons.arrow_forward_ios)),
            ],
          ),
          Spacer(
            flex: 1,
          ),
          progressIndicator(),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}

class _Intro2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    progress = 0.32;
    return _IntroScreenWrapper(
      child: Column(
        children: [
          Spacer(
            flex: 6,
          ),
          SvgPicture.asset(
            'assets/images/MeditatingDoodle.svg',
            width: 300,
            color: primaryColor,
          ),
          Spacer(
            flex: 1,
          ),
          Text("everywhere_available".tr(),
              textAlign: TextAlign.center, style: bigTitle),
          Spacer(
            flex: 1,
          ),
          Text(
            "intro_messaqge_sync".tr(),
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
                      GradelyPageRoute(builder: (context) => _Intro3()),
                    );
                  },
                  icon: Icon(Icons.arrow_forward_ios)),
            ],
          ),
          Spacer(
            flex: 1,
          ),
          progressIndicator(),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}

class _Intro3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    progress = 0.48;
    return _IntroScreenWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(
            flex: 6,
          ),
          SvgPicture.asset(
            'assets/images/MessyDoodle.svg',
            width: 300,
            color: primaryColor,
          ),
          Spacer(
            flex: 1,
          ),
          Text("pluspoints_or_average".tr(),
              textAlign: TextAlign.center, style: bigTitle),
          Spacer(
            flex: 1,
          ),
          Text(
            "grade_result_change_in_settings".tr(),
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
                      GradelyPageRoute(builder: (context) => _Intro4()),
                    );
                  },
                  icon: Icon(Icons.arrow_forward_ios)),
            ],
          ),
          Spacer(
            flex: 1,
          ),
          progressIndicator(),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}

class _Intro4 extends StatefulWidget {
  @override
  State<_Intro4> createState() => _Intro4State();
}

class _Intro4State extends State<_Intro4> {
  bool _obsecuredText = true;
  createUser() async {
    isLoadingController.add(true);
    Future resultCreateAccount = account.create(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );
    await resultCreateAccount.then((response) async {
      await account.createSession(
        email: emailController.text,
        password: passwordController.text,
      );
      response = jsonDecode(response.toString());

      await database.createDocument(collectionId: collectionUser, data: {
        "uid": response["\$id"],
        "gradelyPlus": false,
        "gradeType": "av",
        "choosenSemester": "noSemesterChoosed"
      });
      await getUserInfo();
      prefs.setBool("signedIn", true);
      passwordController.text = "";
      Navigator.pushAndRemoveUntil(
        context,
        GradelyPageRoute(builder: (context) => _Intro5()),
        (Route<dynamic> route) => false,
      );
    }).catchError((error) {
      errorSuccessDialog(context: context, error: true, text: error.message);
    });

    isLoadingController.add(false);
  }

  @override
  Widget build(BuildContext context) {
    progress = 0.64;
    return _IntroScreenWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("lets_get_started".tr(),
              textAlign: TextAlign.center, style: bigTitle),
          Spacer(
            flex: 1,
          ),
          MediaQuery.of(context).viewInsets.bottom == 0
              ? Text(
                  "intro_get_started_description".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                )
              : Container(),
          Spacer(
            flex: 1,
          ),
          TextField(
              controller: nameController,
              textAlign: TextAlign.left,
              decoration: inputDec(label: "your_name".tr())),
          Spacer(
            flex: 1,
          ),
          TextField(
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              textAlign: TextAlign.left,
              decoration: inputDec(label: "your_email".tr())),
          Spacer(
            flex: 1,
          ),
          TextField(
              controller: passwordController,
              textAlign: TextAlign.left,
              obscureText: _obsecuredText,
              decoration: inputDec(
                label: "your_password".tr(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obsecuredText = !_obsecuredText;
                    });
                  },
                  icon: Icon(Icons.remove_red_eye,
                      color: _obsecuredText ? Colors.grey : primaryColor),
                ),
              )),
          Spacer(
            flex: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              gradelyIconButton(
                  onPressed: () => createUser(),
                  icon: Icon(Icons.arrow_forward_ios)),
            ],
          ),
          Spacer(
            flex: 1,
          ),
          progressIndicator(),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}

class _Intro5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    progress = 0.76;
    return _IntroScreenWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(
            flex: MediaQuery.of(context).viewInsets.bottom == 0 ? 6 : 1,
          ),
          Spacer(
            flex: 1,
          ),
          Text("add_first_semester".tr(),
              textAlign: TextAlign.center, style: bigTitle),
          Spacer(
            flex: 1,
          ),
          Text(
            "intro_add_semester".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17),
          ),
          Spacer(
            flex: MediaQuery.of(context).viewInsets.bottom == 0 ? 3 : 1,
          ),
          TextField(
              controller: addSemesterController,
              textAlign: TextAlign.left,
              decoration: inputDec(label: "Semester Name")),
          Spacer(
            flex: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              gradelyIconButton(
                  onPressed: () async {
                    isLoadingController.add(true);
                    await getUserInfo();
                    Future result = database.createDocument(
                        collectionId: collectionSemester,
                        data: {
                          "parentId": user.dbID,
                          "name": addSemesterController.text
                        });

                    result.then((response) {
                      response = jsonDecode(response.toString());

                      database.updateDocument(
                          collectionId: collectionUser,
                          documentId: user.dbID,
                          data: {"choosenSemester": response["\$id"]});
                    }).catchError((error) {
                      print(error.response);
                    });

                    errorSuccessDialog(
                        context: context,
                        error: false,
                        text: "success_semester_added".tr());

                    addLessonController.text = "";
                    semesterList = [];
                    isLoadingController.add(false);
                    Navigator.push(
                      context,
                      GradelyPageRoute(builder: (context) => Intro6()),
                    );
                  },
                  icon: Icon(Icons.arrow_forward_ios)),
            ],
          ),
          Spacer(
            flex: 1,
          ),
          progressIndicator(),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}

class Intro6 extends StatefulWidget {
  @override
  State<Intro6> createState() => _Intro6State();
}

class _Intro6State extends State<Intro6> {
  @override
  void initState() {
    super.initState();
    account.createVerification(url: "https://gradelyapp.com/user/verifyEmail");
  }

  @override
  Widget build(BuildContext context) {
    progress = 1;
    return _IntroScreenWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(
            flex: 6,
          ),
          Spacer(
            flex: 1,
          ),
          Text("almost_finished".tr(),
              textAlign: TextAlign.center, style: bigTitle),
          Spacer(
            flex: 1,
          ),
          Text(
            "intro_email_verification".tr() + " " + user.email,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19),
          ),
          Text(
            "\n" + "check_email_spam".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          Spacer(
            flex: 6,
          ),
          TextButton(
              onPressed: () {
                Future result = account.createVerification(
                    url: "https://gradelyapp.com/user/verifyEmail");

                result.then((response) {
                  errorSuccessDialog(
                      context: context,
                      error: false,
                      text: "success_email_sent".tr());
                }).catchError((error) {
                  errorSuccessDialog(
                      context: context, error: true, text: error.message);
                });
              },
              child: Text("send_again".tr())),
          Theme(
            data: ThemeData().copyWith(
                dividerColor: Colors.transparent,
                colorScheme:
                    ColorScheme.fromSwatch().copyWith(secondary: primaryColor)),
            child: ExpansionTile(
              textColor: primaryColor,
              collapsedTextColor: primaryColor,
              trailing: SizedBox.shrink(),
              expandedAlignment: Alignment.center,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("        " + "change_email".tr(),
                      style: TextStyle(
                        fontSize: 14,
                      )),
                ],
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                          style: TextStyle(color: wbColor),
                          keyboardType: TextInputType.emailAddress,
                          controller: changeEmailController,
                          textAlign: TextAlign.left,
                          decoration: inputDec(label: "email".tr())),
                    ),
                    IconButton(
                      onPressed: () async {
                        try {
                          changeEmail(changeEmailController.text, context);
                        } catch (e) {
                          errorSuccessDialog(
                              context: context, error: true, text: e.message);
                        }
                      },
                      icon: Icon(FontAwesome5Solid.save),
                      color: primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Spacer(
            flex: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              gradelyIconButton(
                  onPressed: () async {
                    isLoadingController.add(true);
                    await getUserInfo();
                    if (user.emailVerification) {
                      Navigator.pushNamed(
                        context,
                        "subjects",
                      );
                      errorSuccessDialog(
                          context: context,
                          error: false,
                          text: "success_email_verified".tr());
                    } else {
                      errorSuccessDialog(
                          context: context,
                          error: true,
                          text: "error_email_not_verified".tr());
                    }

                    isLoadingController.add(false);
                  },
                  icon: Icon(Icons.arrow_forward_ios)),
            ],
          ),
          Spacer(
            flex: 1,
          ),
          progressIndicator(),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}
