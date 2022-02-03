import 'package:flutter/material.dart';

class ElevatedIconComponent extends StatelessWidget {
  final height;
  final width;
  final elevation;
  final backgroundColor;
  final icon;
  final onTap;
  final title;
  final textColor;
  final shadowColor;

  const ElevatedIconComponent(
      {this.height = 50.0,
      this.width = 50.0,
      this.elevation = 10.0,
      this.backgroundColor = Colors.white,
      this.icon,
      this.onTap,
      this.title = '',
      this.textColor = Colors.black,
      this.shadowColor=Colors.white});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: this.onTap,
          child: Material(
            elevation: elevation,
            shadowColor: shadowColor,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: this.height,
              width: this.width,
              child: Center(child: this.icon),
              decoration: BoxDecoration(
                color: this.backgroundColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            this.title,
            style: TextStyle(
                color: this.textColor,
                fontSize: 10,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
