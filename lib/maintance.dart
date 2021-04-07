import 'main.dart';
import 'package:flutter/material.dart';
import 'package:gradely/data.dart';

class MaintanceMode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    getMaintanceStatus();
    return Scaffold(
      appBar: AppBar(
        title: Text("Wartung"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/maintance.png',
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Text(
              "Im Moment wird gerade etwas umgebaut. In wenigen Augenblicken sollte alles wieder funktionieren.",
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
