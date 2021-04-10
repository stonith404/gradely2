import 'package:flutter/material.dart';
import 'package:gradely/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlatformList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plattformen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SizedBox(height: 50),
            Text(
              "Die Verfügbarkeit und Synchronisation mach Gradely einzigartig. ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Text('Auf "gradelyapp.com/download" kannst du Gradely für all deine Gerät herunterladen'),
                 SizedBox(height: 15),
             Text(
              "Gradely ist auf folgenden Plattformen erhältlich:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
                 SizedBox(height: 50),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text("Ios"),
                    trailing: FaIcon(FontAwesomeIcons.appStoreIos),
                  ),
                  ListTile(
                    title: Text("Android"),
                     trailing: FaIcon(FontAwesomeIcons.android),
                  ),
                  ListTile(
                    title: Text("MacOS"),
                     trailing: FaIcon(FontAwesomeIcons.appStoreIos),
                  ),
                
                  ListTile(
                    title: Text("Web"),
                     trailing: FaIcon(FontAwesomeIcons.chrome),
                  ),
                ],
              ),
            ),

      
          ],
        ),
      ),
    );
  }
}
