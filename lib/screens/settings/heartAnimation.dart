import 'package:flutter/material.dart';

class HeartScreen extends StatefulWidget {
  @override
  _HeartScreenState createState() => _HeartScreenState();
}

class _HeartScreenState extends State<HeartScreen>
    with SingleTickerProviderStateMixin {
  static final base = [Colors.white, Colors.black].reversed.toList();
  final colors = base + base + base;

  AnimationController animation;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () => Navigator.pop(context));
    animation = AnimationController(vsync: this);
    animation.duration = Duration(seconds: 6);
    animation.addListener(() => setState(() {}));
    animation.forward();
    animation.repeat();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var count = 0;
    final children = (colors.map((color) {
      final offset = 1 - (count++ / colors.length);
      final fraction = (animation.value + offset) % 1;

      return Helper(
        Transform.scale(
          scale: 100 * Curves.decelerate.transform(fraction),
          child: Icon(Icons.favorite, color: color),
          //child: Image.asset("assets/heart.png", color: color),
        ),
        fraction,
      );
    }).toList()
          ..sort((a, b) => -a.scale.compareTo(b.scale)))
        .map((helper) => helper.child)
        .toList();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: children,
      ),
    );
  }
}

class Helper {
  final Widget child;
  final double scale;

  Helper(this.child, this.scale);
}
