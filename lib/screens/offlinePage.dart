import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_my_ride_partners_1/globalsAndConstants/allConstants.dart';
import 'package:get_my_ride_partners_1/globalsAndConstants/networkChecker.dart';

class OfflinePage extends StatefulWidget {
  final comingFrom;
  final serverIssue;
  final locationError;

  OfflinePage(
      {@required this.comingFrom,
      this.serverIssue = false,
      this.locationError = false});

  @override
  _OfflinePageState createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  bool serverIssue = true;

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final height = query.size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(height: height / 2 - 200),
                SvgPicture.asset(
                  widget.locationError
                      ? 'assets/svgs/location.svg'
                      : serverIssue
                          ? 'assets/svgs/error.svg'
                          : 'assets/svgs/no_internet.svg',
                  height: 200,
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.locationError
                        ? 'Please provide permission to access location and enable gps'
                        : serverIssue
                            ? 'Server down please try after sometime'
                            : 'No Internet connection ❌',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(MyColors.primaryColor),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => widget.comingFrom),
                    );
                  },
                  child: Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    serverIssue = widget.serverIssue;
    checkNet();
  }

  void checkNet() async {
    if (await NetworkCheckingClass().hasNetwork()) {
      setState(() {
        serverIssue = true;
      });
    } else {
      setState(() {
        serverIssue = false;
      });
    }
  }
}
