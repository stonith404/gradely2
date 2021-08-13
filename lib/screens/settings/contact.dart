import 'package:flutter/material.dart';
import 'package:gradely2/screens/main/lessons.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:gradely2/shared/WIDGETS.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:easy_localization/easy_localization.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  sendMail(String _message) async {
    String username = "gradelyapp@hotmail.com";
    String password = "gradlllyconntact!!5";

    final smtpServer = hotmail(username, password);

    // Create our email message.
    final message = Message()
      ..from = Address(username)
      ..recipients.add('elias@eliasschneider.com') //recipent email
      ..subject = 'New Message for Gradely' //subject of the email
      ..text =
          '$_message\n ________________\n Email: ${user.email}'; //body of the email

    try {
      await send(message, smtpServer);

      contactMessage.text = "";

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SemesterDetail()),
      );

      errorSuccessDialog(
          context: context,
          error: false,
          text: "${"contact_success_text".tr()} ${user.email}.",
          title: "sent".tr());
    } on MailerException catch (_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SemesterDetail()),
      );

      errorSuccessDialog(
          context: context, error: true, text: "error_contact".tr());
    }
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
              title: Text("contact_developer".tr(),
                  style: TextStyle(
                      color: primaryColor, fontWeight: FontWeight.w800))),
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
          ),
        ),
      ),
    );
  }
}
