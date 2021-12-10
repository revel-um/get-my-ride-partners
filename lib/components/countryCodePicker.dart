import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CountryCodePickerWidget extends StatelessWidget {
  final onChanged;
  CountryCodePickerWidget({@required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: Colors.white,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        child: Center(
          child: CountryCodePicker(
            initialSelection: 'IN',
            onChanged: onChanged,
            flagDecoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
