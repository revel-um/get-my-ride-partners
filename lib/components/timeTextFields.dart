import 'package:flutter/material.dart';
class TimeTextField extends StatefulWidget {
  final onTimeChange;
  final initialValue;

  const TimeTextField({this.onTimeChange, this.initialValue});

  @override
  _TimeTextFieldState createState() => _TimeTextFieldState();
}

class _TimeTextFieldState extends State<TimeTextField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(5),
      child: GestureDetector(
        onTap: () async {
          final time = await showTimePicker(
              context: context, initialTime: TimeOfDay.now());
          if (time != null) {
            final timing =
                '${time.hour.toString().padLeft(2, '0')} : ${time.minute.toString().padLeft(2, '0')}';
            controller.text = timing;
            widget.onTimeChange(timing);
          }
        },
        child: Container(
          width: 130,
          height: 60,
          child: TextField(
            enabled: false,
            controller: controller,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              fillColor: Colors.white,
              suffixIcon: Icon(
                Icons.access_time,
                color: Colors.black,
              ),
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0.0),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}