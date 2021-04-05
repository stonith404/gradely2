import 'package:flutter/material.dart';

  RoundedRectangleBorder defaultRoundedCorners() {
    return RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(25),
    ),
  );
  }


  
  BoxDecoration boxDec() {
    return BoxDecoration(
      borderRadius: BorderRadius.all(
            Radius.circular(10)
            ),
      gradient: new LinearGradient(
                colors: [
                  const Color(0xFF3366FF),
                  const Color(0xFF00CCFF),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          
   boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3), // changes position of shadow
      ),
    ],
                    );
  }