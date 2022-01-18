import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:easy_localization/easy_localization.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  sendMail(String _message) async {
    var maildata = jsonEncode({"sender": user.email, "message": _message});
    Future result = functions.createExecution(
        functionId: 'fcn_contact', data: maildata.toString());
    await result.then((response) {
      Navigator.pushNamed(context, "subjects");
      errorSuccessDialog(
          context: context,
          error: false,
          text: "${"contact_success_text".tr()} ${user.email}.",
          title: "sent".tr());
    }).catchError((error) {
      Navigator.pushNamed(context, "subjects");
      errorSuccessDialog(
          context: context, error: true, text: "error_contact".tr());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
              iconTheme: IconThemeData(
                color: primaryColor,
              ),
              backgroundColor: defaultBGColor,
              elevation: 0,
              title: Text("contact_developer".tr(), style: appBarTextTheme)),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                SizedBox(height: 40),
                Container(
                  child: TextField(
                      controller: contactMessage,
                      maxLines: 8,
                      decoration: inputDec(label: "your_message".tr())),
                ),
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    gradelyButton(
                        onPressed: () async {
                          isLoadingController.add(true);
                          if (contactMessage.text == "") {
                          } else {
                            await sendMail(contactMessage.text);
                          }
                          isLoadingController.add(false);
                        },
                        text: "send".tr()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
