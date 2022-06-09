import "package:appwrite/appwrite.dart";
import "package:appwrite/models.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:gradely2/components/controllers/user_controller.dart";
import "package:gradely2/components/utils/app.dart";
import "package:gradely2/components/variables.dart";
import "package:gradely2/components/widgets/buttons.dart";
import "package:gradely2/components/widgets/decorations.dart";
import "package:gradely2/components/widgets/dialogs.dart";

double progress = 0;
final UserController _userController = UserController();

class _IntroScreenWrapper extends StatelessWidget {
  final Widget? child;
  const _IntroScreenWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: SvgPicture.asset("assets/images/logo.svg",
              color: Theme.of(context).primaryColorDark, height: 30),
          actions: [
            progress >= 0.76
                ? IconButton(
                    color: Theme.of(context).primaryColorDark,
                    icon: Icon(Icons.logout),
                    onPressed: () => _userController.signOut(context))
                : Container(),
          ],
        ),
        body: Padding(padding: const EdgeInsets.all(24.0), child: child));
  }
}

Widget progressIndicator(context) {
  return ClipRRect(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    child: LinearProgressIndicator(
        backgroundColor: Theme.of(context).primaryColorLight,
        value: progress,
        color: Theme.of(context).primaryColorDark),
  );
}

class Intro1 extends StatelessWidget {
  const Intro1({Key? key}) : super(key: key);

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
            "assets/images/BalletDoodle.svg",
            width: 300,
            color: Theme.of(context).primaryColorDark,
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
                  icon: Icon(Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColorLight)),
            ],
          ),
          Spacer(
            flex: 1,
          ),
          progressIndicator(context),
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
            "assets/images/MeditatingDoodle.svg",
            width: 300,
            color: Theme.of(context).primaryColorDark,
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
                  icon: Icon(Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColorLight)),
            ],
          ),
          Spacer(
            flex: 1,
          ),
          progressIndicator(context),
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
            "assets/images/MessyDoodle.svg",
            width: 300,
            color: Theme.of(context).primaryColorDark,
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
                  icon: Icon(Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColorLight)),
            ],
          ),
          Spacer(
            flex: 1,
          ),
          progressIndicator(context),
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

final TextEditingController _nameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

class _Intro4State extends State<_Intro4> {
  bool _obsecuredText = true;
  createUser() async {
    isLoadingController.add(true);
    Future<User> resultCreateAccount = account.create(
      userId: "unique()",
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    await resultCreateAccount.then((response) async {
      await account.createSession(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await api.createDocument(context, collectionId: collectionUser, data: {
        "uid": response.$id,
        "gradeType": "av",
        "choosenSemester": "noSemesterChoosed"
      });
      await _userController.getUserInfo();
      prefs.setBool("signedIn", true);
      _passwordController.text = "";
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
    bool keyboardActive = MediaQuery.of(context).viewInsets.bottom == 0;
    progress = 0.64;
    return _IntroScreenWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("lets_get_started".tr(),
              textAlign: TextAlign.center, style: bigTitle),
          Spacer(
            flex: 3,
          ),
          keyboardActive
              ? Text(
                  "intro_get_started_description".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                )
              : Container(),
          Spacer(
            flex: keyboardActive ? 3 : 1,
          ),
          TextField(
              controller: _nameController,
              textAlign: TextAlign.left,
              decoration: inputDec(context, label: "your_name".tr())),
          Spacer(
            flex: keyboardActive ? 3 : 2,
          ),
          TextField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              textAlign: TextAlign.left,
              decoration: inputDec(context, label: "your_email".tr())),
          Spacer(
            flex: keyboardActive ? 3 : 2,
          ),
          TextField(
              controller: _passwordController,
              textAlign: TextAlign.left,
              obscureText: _obsecuredText,
              decoration: inputDec(
                context,
                label: "your_password".tr(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obsecuredText = !_obsecuredText;
                    });
                  },
                  icon: Icon(Icons.remove_red_eye,
                      color: _obsecuredText
                          ? Colors.grey
                          : Theme.of(context).primaryColorDark),
                ),
              )),
          Spacer(
            flex: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              gradelyIconButton(
                  onPressed: () => createUser(),
                  icon: Icon(Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColorLight)),
            ],
          ),
          Spacer(
            flex: 3,
          ),
          progressIndicator(context),
          Spacer(
            flex: 3,
          ),
        ],
      ),
    );
  }
}

class _Intro5 extends StatelessWidget {
  final TextEditingController _semesterNameController = TextEditingController();
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
              controller: _semesterNameController,
              textAlign: TextAlign.left,
              decoration: inputDec(context, label: "Semester Name")),
          Spacer(
            flex: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              gradelyIconButton(
                  onPressed: () async {
                    isLoadingController.add(true);
                    await _userController.getUserInfo();
                    Future result = api.createDocument(context,
                        collectionId: collectionSemester,
                        data: {
                          "parentId": user.dbID,
                          "name": _semesterNameController.text
                        });
                    result.then((response) {
                      api.updateDocument(context,
                          collectionId: collectionUser,
                          documentId: user.dbID,
                          data: {"choosenSemester": response.$id});
                    }).catchError((error) {
                      print(error.response);
                    });

                    errorSuccessDialog(
                        context: context,
                        error: false,
                        text: "success_semester_added".tr());

                    isLoadingController.add(false);
                    Navigator.push(
                      context,
                      GradelyPageRoute(builder: (context) => Intro6()),
                    );
                  },
                  icon: Icon(Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColorLight)),
            ],
          ),
          Spacer(
            flex: 1,
          ),
          progressIndicator(context),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}

class Intro6 extends StatefulWidget {
  const Intro6({Key? key}) : super(key: key);

  @override
  State<Intro6> createState() => _Intro6State();
}

class _Intro6State extends State<Intro6> {
  final TextEditingController _changeEmailController = TextEditingController();
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
            "${"intro_email_verification".tr()} ${user.email}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19),
          ),
          Text(
            "\n${"check_email_spam".tr()}",
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
                colorScheme: ColorScheme.fromSwatch()
                    .copyWith(secondary: Theme.of(context).primaryColorDark)),
            child: ExpansionTile(
              textColor: Theme.of(context).primaryColorDark,
              collapsedTextColor: Theme.of(context).primaryColorDark,
              trailing: SizedBox.shrink(),
              expandedAlignment: Alignment.center,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("        ${"change_email".tr()}",
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
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark),
                          keyboardType: TextInputType.emailAddress,
                          controller: _changeEmailController,
                          textAlign: TextAlign.left,
                          decoration: inputDec(context, label: "email".tr())),
                    ),
                    IconButton(
                      onPressed: () async {
                        try {
                          _userController.changeEmail(
                              _changeEmailController.text, context);
                        } on AppwriteException catch (e) {
                          errorSuccessDialog(
                              context: context,
                              error: true,
                              text: e.message.toString());
                        }
                      },
                      icon: Icon(
                        isCupertino
                            ? CupertinoIcons.square_arrow_down
                            : Icons.save_outlined,
                      ),
                      color: Theme.of(context).primaryColorDark,
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
                    await _userController.getUserInfo();
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
                  icon: Icon(Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColorLight)),
            ],
          ),
          Spacer(
            flex: 1,
          ),
          progressIndicator(context),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}
