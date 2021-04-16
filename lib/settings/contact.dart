import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:gradely/data.dart';
import 'package:gradely/shared/defaultWidgets.dart';
import 'package:easy_localization/easy_localization.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  sendMail(String _mail, String _message) async {
    String username = "gradelycontact@yandex.com";
    String password = "gradelyContact!!5";

    final smtpServer = yandex(username, password);


    // Create our email message.
    final message = Message()
      ..from = Address(username)
      ..recipients.add('elias@eliasschneider.com') //recipent email
      ..subject =
          'New Message for Gradely' //subject of the email
      ..text =
          '$_message\n\n Email: $_mail'; //body of the email

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' +
          sendReport.toString()); //print if the email is sent
    } on MailerException catch (e) {
      print('Message not sent. \n' +
          e.toString()); //print if the email is not sent
      // e.toString() will show why the email is not sending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(title: Text("contactDev".tr())),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            
            children: [
               SizedBox(height: 50),
              Image.asset("assets/images/contact.png"),
               SizedBox(height: 50),
               TextField(
                        controller: contactMail,
                        textAlign: TextAlign.left,
                        decoration: inputDec("Deine Email".tr())),
                         SizedBox(height: 20),

                         Container(
                            
                           child: TextField(
                        controller: contactMessage,
                        maxLines: 8,
                        
                        decoration: inputDec("Deine Nachricht".tr())),
                         ),
                         SizedBox(height: 50),
              ElevatedButton(
                  onPressed: () {
                    sendMail(contactMail.text, contactMessage.text);
                  },
                  child: Text("send")),
            ],
          ),
        ),
      ),
    );
  }
}
