import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_my_ride_partners_1/apis/AllApis.dart';
import 'package:get_my_ride_partners_1/components/shimmerWidget.dart';
import 'package:get_my_ride_partners_1/globalsAndConstants/allConstants.dart';
import 'package:get_my_ride_partners_1/screens/homePageStuff/tabs/addVehiclesTab.dart';
import 'package:get_my_ride_partners_1/screens/homePageStuff/tabs/storeDetailsTab.dart';
import 'package:get_my_ride_partners_1/screens/homePageStuff/tabs/storeTab.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int navigationIndex = 0;
  bool isAbsorbing = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    isAbsorbing = false;
    AllApis.staticContext = context;
    AllApis.staticPage = HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isAbsorbing,
      child: Scaffold(
        resizeToAvoidBottomInset: navigationIndex == 1 ? false : true,
        backgroundColor: Colors.white,
        bottomNavigationBar: isAbsorbing
            ? Padding(
                padding: EdgeInsets.only(
                    left: navigationIndex == 2 ? 8.0 : 16.0,
                    right: navigationIndex == 2 ? 8.0 : 16.0,
                    top: 8.0),
                child: ShimmerWidget(
                  isLoading: isAbsorbing,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              )
            : BottomNavigationBar(
                currentIndex: navigationIndex,
                selectedItemColor: MyColors.primaryColor,
                backgroundColor: Colors.white,
                onTap: (index) {
                  navigationIndex = index;
                  setState(() {});
                },
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Store'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      activeIcon: Icon(Icons.add),
                      label: 'Add Vehicles'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.edit_outlined),
                      activeIcon: Icon(Icons.edit),
                      label: 'Store Details'),
                ],
              ),
        body: getBody(navigationIndex),
      ),
    );
  }

  changeTab({@required index, msg}) {
    setState(() {
      navigationIndex = index;
    });
    if (msg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
        ),
      );
    }
  }

  getBody(int navigationIndex) {
    if (navigationIndex == 0) {
      return StoreTab(
        changeTab: changeTab,
        onStateChange: ({@required touchWorks}) {
          if (mounted)
            setState(
              () {
                isAbsorbing = !touchWorks;
              },
            );
        },
      );
    } else if (navigationIndex == 1) {
      return AddVehiclesTab(
        changeTab: changeTab,
        onStateChange: ({@required touchWorks}) {
          if (mounted)
            setState(
              () {
                isAbsorbing = !touchWorks;
              },
            );
        },
      );
    } else {
      return StoreDetailsTab(
        changeTab: changeTab,
        onStateChange: ({@required touchWorks}) {
          if (mounted)
            setState(
              () {
                isAbsorbing = !touchWorks;
              },
            );
        },
      );
    }
  }
}
