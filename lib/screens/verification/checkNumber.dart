import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_my_ride_partners_1/apis/AllApis.dart';
import 'package:get_my_ride_partners_1/components/countryCodePicker.dart';
import 'package:get_my_ride_partners_1/globalsAndConstants/allConstants.dart';
import 'package:get_my_ride_partners_1/screens/verification/verifyNumber.dart';

class CheckNumber extends StatefulWidget {
  @override
  _CheckNumberState createState() => _CheckNumberState();
}

String countryCode = '+91';

class _CheckNumberState extends State<CheckNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double animationValue = 0;
  bool animatedOnce = false;
  Color focusColor = Colors.blueGrey;
  final fieldController = TextEditingController();
  bool requesting = false;

  @override
  void initState() {
    super.initState();
    AllApis.staticContext = context;
    AllApis.staticPage = CheckNumber();

    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _controller.addListener(() {
      setState(() {
        animationValue = _controller.value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACCOUNT',
                          style: TextStyle(
                            color: MyColors.primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            wordSpacing: 1,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Connect to account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                            wordSpacing: 0,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    CountryCodePickerWidget(
                      onChanged: (_) {
                        countryCode = _.toString();
                      },
                    ),
                  ],
                ),
                SvgPicture.asset(
                  'assets/svgs/signin.svg',
                  height: MediaQuery.of(context).size.height / 2,
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 60,
                  child: TextButton(
                    onPressed: animatedOnce && !requesting
                        ? () async {
                            setState(() {
                              requesting = true;
                              focusColor = Colors.blueGrey;
                            });
                            final phoneNumber =
                                '$countryCode${fieldController.text}';
                            AllApis apis = AllApis();
                            final response = await apis.sentOtp(
                                phoneNumber:
                                    '$countryCode${fieldController.text}');
                            if (response == null) return;
                            if (response.statusCode == 200) {
                              setState(() {
                                requesting = false;
                                focusColor = MyColors.primaryColor;
                              });
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1,
                                          animation2) =>
                                      VerifyNumber(phoneNumber: phoneNumber),
                                  transitionDuration: Duration(seconds: 1),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Invalid request'),
                                ),
                              );
                            }
                          }
                        : !animatedOnce
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Please enter 10 digit phone number'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'A request is already in progress'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                    child: Text(
                      'REQUEST OTP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                        wordSpacing: 4,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: focusColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  maxLength: 10,
                  onChanged: (_) {
                    if (_.length == 10) {
                      animatedOnce = true;
                      focusColor = MyColors.primaryColor;
                      _controller.forward();
                    } else if (animatedOnce) {
                      focusColor = Colors.blueGrey;
                      animatedOnce = false;
                      _controller.reverse(from: 1);
                    }
                  },
                  controller: fieldController,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    prefixIcon: Icon(
                      Icons.phone,
                      color: focusColor,
                    ),
                    suffixIcon: Transform.rotate(
                      angle: 360 * animationValue * 3.14 / 180,
                      child: Hero(
                        tag: 'verify',
                        child: Icon(
                          Icons.verified,
                          color: MyColors.primaryColor,
                          size: 20 * animationValue,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: focusColor, width: 2.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: requesting ? SpinKit.spinner : null,
          )
        ],
      ),
    );
  }
}
