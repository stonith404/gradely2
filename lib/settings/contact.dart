import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradely/semesterDetail.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:gradely/data.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:gradely/main.dart';
import 'package:gradely/userAuth/login.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  bool isEmailsent = false;
  sendMail(String _message) async {
    setState(() {
      isEmailsent = true;
    });

    String username = "gradelyapp@hotmail.com";
    String password = "gradlllyconntact!!5";

    final smtpServer = hotmail(username, password);

    // Create our email message.
    final message = Message()
      ..from = Address(username)
      ..recipients.add('elias@eliasschneider.com') //recipent email
      ..subject = 'New Message for Gradely' //subject of the email
      ..text =
          '$_message\n ________________\n Email: ${auth.currentUser.email}'; //body of the email

    try {
      final sendReport = await send(message, smtpServer);
      setState(() {
        isEmailsent = false;
      });
      contactMessage.text = "";
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeSite()),
      );
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  FaIcon(FontAwesomeIcons.checkCircle),
                  Spacer(flex: 1),
                  Text("contactSuccess1".tr()),
                  Spacer(flex: 10)
                ],
              ),
              content:
                  Text("${"contactSuccess2".tr()} ${auth.currentUser.email}."),
              actions: <Widget>[
                FlatButton(
                  color: defaultColor,
                  child: Text("ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            );
          });
    } on MailerException catch (e) {
      setState(() {
        isEmailsent = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeSite()),
      );
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  FaIcon(FontAwesomeIcons.exclamationCircle),
                  Spacer(flex: 1),
                  Text("fehler".tr()),
                  Spacer(flex: 10)
                ],
              ),
              content: Text("contactError1".tr()),
              actions: <Widget>[
                FlatButton(
                  color: defaultColor,
                  child: Text("Super".tr()),
                  onPressed: () {
                    Navigator.of(context).pop();
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            );
          });
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
              backgroundColor: defaultColor, title: Text("contactDev".tr())),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(height: 50),
                Text("contact1".tr()),
                SizedBox(height: 50),
                Container(
                  child: TextField(
                      controller: contactMessage,
                      maxLines: 8,
                      decoration: inputDec("Deine Nachricht".tr())),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                    style: elev(),
                    onPressed: isEmailsent
                        ? null
                        : () {
                            if (contactMessage.text == "") {
                            } else {
                              sendMail(contactMessage.text);
                              HapticFeedback.mediumImpact();
                            }
                          },
                    child: Text("send")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
