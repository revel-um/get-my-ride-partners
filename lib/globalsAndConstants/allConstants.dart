import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyColors {
  static const primaryColor = Color(0xFF259568);
  static const secondaryColor = Color(0xFFBA68C8);
  static const tertiaryColor = Colors.blueAccent;
  static const Map<int, Color> colorMap = {
    50: Color.fromRGBO(136, 14, 79, .1),
    100: Color.fromRGBO(136, 14, 79, .2),
    200: Color.fromRGBO(136, 14, 79, .3),
    300: Color.fromRGBO(136, 14, 79, .4),
    400: Color.fromRGBO(136, 14, 79, .5),
    500: Color.fromRGBO(136, 14, 79, .6),
    600: Color.fromRGBO(136, 14, 79, .7),
    700: Color.fromRGBO(136, 14, 79, .8),
    800: Color.fromRGBO(136, 14, 79, .9),
    900: Color.fromRGBO(136, 14, 79, 1),
  };
}

class SpinKit {
  static const spinner = SpinKitSpinningLines(color: Color(0xFFFF9933));
}

class AllData {
  static dynamic storeRepo;
  static dynamic productRepo;
  static resetStoreTabData(){
    storeRepo = null;
    productRepo = [];
  }


}
