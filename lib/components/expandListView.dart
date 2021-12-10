import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color teal = Color(0xFF3CD1BB);
class ExpandListView extends StatelessWidget {
  final collapsedColor;
  final expandedColor;
  final children;
  final title;
  final iconColor;
  final leading;
  final trailing;
  final outerPadding;
  final initiallyExpanded;

  ExpandListView({
    this.collapsedColor = Colors.white,
    this.title,
    this.expandedColor = Colors.white,
    @required this.children,
    this.iconColor = Colors.black,
    this.leading,
    this.trailing,
    this.outerPadding = 8.0,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: outerPadding, left: outerPadding, right: outerPadding),
          child: Material(
            elevation: 5,
            child: ExpansionTile(
              maintainState: false,
              initiallyExpanded: initiallyExpanded,
              iconColor: iconColor,
              backgroundColor: expandedColor,
              collapsedBackgroundColor: collapsedColor,
              title: title == null ? Text('Title') : title,
              leading: leading,
              trailing: trailing,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
