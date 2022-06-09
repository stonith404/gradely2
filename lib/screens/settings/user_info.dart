import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/controllers/user_controller.dart";
import "package:gradely2/components/widgets/buttons.dart";
import "package:gradely2/components/widgets/decorations.dart";
import "package:gradely2/components/variables.dart";
import "package:easy_localization/easy_localization.dart";
import "package:gradely2/components/widgets/toast.dart";

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final UserController userController = UserController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordPlaceholderController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = user.name;
    _emailController.text = user.email;
    _passwordPlaceholderController.text = "123456789";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(
                Icons.logout,
                size: 20,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: () => userController.signOut(context))
        ],
        title: Text("account".tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(height: 70),
            Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: _nameController,
                      textAlign: TextAlign.left,
                      decoration: inputDec(context, label: "your_name".tr())),
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      await account.updateName(name: _nameController.text);
                      toast.success(context, text: "name_updated".tr());
                    } catch (e) {
                      toast.error(context, text: "error_unknown".tr());
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
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      textAlign: TextAlign.left,
                      decoration: inputDec(context, label: "email".tr())),
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      userController.changeEmail(
                          _emailController.text, context);
                    } catch (e) {
                      toast.error(context, text: "error_unknown".tr());
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
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext contextP) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        title: Text("change_password".tr()),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("change_password_text".tr()),
                            SizedBox(height: 20),
                            gradelyButton(
                                onPressed: () {
                                  isLoadingController.add(true);
                                  Future result = account.createRecovery(
                                    email: user.email,
                                    url:
                                        "https://gradelyapp.com/user/changePassword",
                                  );
                                  result.then((response) {
                                    toast.success(context,
                                        text:
                                            "password_reset_success_text".tr(),
                                        title: "sent".tr());
                                  }).catchError((error) {
                                    toast.error(context, text: error.message);
                                  });

                                  Navigator.of(context).pop();
                                  isLoadingController.add(false);
                                },
                                text: "send".tr())
                          ],
                        ),
                      );
                    });
              },
              child: TextField(
                  enabled: false,
                  obscureText: true,
                  controller: _passwordPlaceholderController,
                  textAlign: TextAlign.left,
                  decoration: inputDec(context, label: "password".tr())),
            ),
            SizedBox(
              height: 20,
            ),
            Spacer(flex: 100),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext contextP) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            title: Text("delete_account".tr()),
                            content: SizedBox(
                              height: 150,
                              child: Column(
                                children: [
                                  Text("delete_account_text".tr()),
                                  SizedBox(height: 30),
                                  TextField(
                                      controller: _passwordController,
                                      textAlign: TextAlign.left,
                                      obscureText: true,
                                      decoration: inputDec(context,
                                          label: "your_password".tr())),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                  child: Text("delete".tr()),
                                  onPressed: () async {
                                    Navigator.of(contextP).pop();
                                    if (await userController.reAuthenticate(
                                        email: user.email,
                                        password: _passwordController.text)) {
                                      await functions.createExecution(
                                          functionId: "fcn_delete_account");
                                      _passwordController.text = "";
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        "auth/home",
                                        (Route<dynamic> route) => false,
                                      );
                                      prefs.setBool("signedIn", false);
                                    } else {
                                      toast.error(context,
                                          text: "error_wrong_password".tr());
                                    }
                                  }),
                            ],
                          );
                        });
                  },
                  child: Text(
                    "delete_account".tr(),
                    style: TextStyle(color: Colors.red),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
