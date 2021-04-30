import 'package:flutter/material.dart';
import 'package:gradely/main.dart';
import 'package:gradely/data.dart';

class Customize extends StatefulWidget {
  @override
  _CustomizeState createState() => _CustomizeState();
}

class _CustomizeState extends State<Customize> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 60),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    
                    defaultColor = Colors.red;
                  });
                },
                child: Text("change"))
          ],
        ),
      ),
    );
  }
}
