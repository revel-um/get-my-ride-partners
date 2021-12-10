import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_my_ride_partners_1/apis/AllApis.dart';
import 'package:get_my_ride_partners_1/components/expandListView.dart';
import 'package:get_my_ride_partners_1/globalsAndConstants/allConstants.dart';
import 'package:get_my_ride_partners_1/screens/storeCreationStuff/createStore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreDetailsTab extends StatefulWidget {
  final changeTab;
  final onStateChange;

  const StoreDetailsTab({this.changeTab, this.onStateChange});

  @override
  _StoreDetailsTabState createState() => _StoreDetailsTabState();
}

class _StoreDetailsTabState extends State<StoreDetailsTab> {
  Map<int, bool> days = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false,
  };

  Map<String, String> updateDetails = {}, initialDetails = {};

  final allSelected = {
    0: true,
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
    6: true,
  };

  Map<int, bool> hours_24 = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false,
  };

  bool isLoading = false;
  int errorIndex = -1;

  List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<dynamic> openHours = [], closeHours = [];

  bool areAllDaysSelected = false, areAll24HSelected = false;

  var image;
  double lat = 0.0, lon = 0.0;

  TextEditingController storeNameCon = TextEditingController(),
      phoneCon = TextEditingController(),
      cityCon = TextEditingController(),
      postalCodeCon = TextEditingController(),
      addressCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          AbsorbPointer(
            absorbing: isLoading,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                bottom: isLoading
                    ? PreferredSize(
                        child: LinearProgressIndicator(
                          color: MyColors.primaryColor,
                        ),
                        preferredSize: Size.zero,
                      )
                    : null,
                actions: [
                  TextButton(
                    onPressed: () async {
                      days.forEach((key, value) {
                        if (errorIndex != -1) {
                          return;
                        }
                        if ((openHours[key] == '24' &&
                                closeHours[key] != '24') ||
                            (openHours[key] == 'closed' &&
                                closeHours[key] != 'closed') ||
                            (openHours[key] != '24' &&
                                closeHours[key] == '24') ||
                            (openHours[key] != 'closed' &&
                                closeHours[key] == 'closed')) {
                          setState(() {
                            errorIndex = key;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Timings are inappropriate'),
                            ),
                          );
                          return;
                        }
                      });
                      if (errorIndex != -1) {
                        return;
                      }
                      if (storeNameCon.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Store Name can not be empty'),
                          ),
                        );
                        return;
                      }
                      if (phoneCon.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Phone Number can not be empty'),
                          ),
                        );
                        return;
                      }
                      if (!phoneCon.text.contains('+')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Please enter phone number with country code'),
                          ),
                        );
                        return;
                      }
                      updateDetails = createDataObject();
                      if (DeepCollectionEquality().equals(initialDetails, updateDetails) && image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'There is no change to update'),
                          ),
                        );
                        return;
                      }
                      if (mounted)
                        setState(() {
                          isLoading = true;
                          widget.onStateChange(touchWorks: !isLoading);
                        });
                      AllApis apis = AllApis();
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      final token = pref.getString('token');
                      final storeId = pref.getString('storeId');
                      final response = await apis.updateStore(
                        token: token,
                        storeId: storeId,
                        updateObject: updateDetails,
                        file: image,
                      );
                      if (mounted)
                        setState(() {
                          isLoading = false;
                          widget.onStateChange(touchWorks: !isLoading);
                        });
                      if (response != null && response.statusCode == 200) {
                        AllData.productRepo = null;
                        AllData.storeRepo = null;
                        setState(() {
                          widget.changeTab(index: 0, msg: 'Update Successful');
                        });
                      }
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
                title: Text(
                  'Store Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView(
                  children: [
                    ExpandListView(
                      children: getBasicInfo(),
                      collapsedColor: MyColors.primaryColor,
                      initiallyExpanded: true,
                      title: Text(
                        'Basic Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ExpandListView(
                      children: getWorkingDaysList(),
                      collapsedColor: MyColors.primaryColor,
                      title: Text(
                        'Store Timings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: isLoading ? SpinKit.spinner : null,
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    initializeStoreDetails(AllData.storeRepo);
  }

  List<Widget> getWorkingDaysList() {
    List<Widget> workingDaysList = [];
    if (AllData.storeRepo == null) return [];
    Widget initial = SingleChildScrollView(
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: MyColors.primaryColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 50,
                child: Center(
                  child: Text(
                    'All',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Switch(
                value: areAllDaysSelected,
                onChanged: (_) {
                  setState(
                    () {
                      areAllDaysSelected = _;
                      days = {
                        0: areAllDaysSelected,
                        1: areAllDaysSelected,
                        2: areAllDaysSelected,
                        3: areAllDaysSelected,
                        4: areAllDaysSelected,
                        5: areAllDaysSelected,
                        6: areAllDaysSelected,
                      };
                    },
                  );
                },
              ),
              Wrap(
                direction: Axis.vertical,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Checkbox(
                    checkColor: MyColors.primaryColor,
                    fillColor: MaterialStateColor.resolveWith((states) =>
                        areAllDaysSelected ? Colors.white : Colors.grey),
                    value: areAll24HSelected,
                    onChanged: areAllDaysSelected
                        ? (_) {
                            setState(
                              () {
                                if (_ == true) {
                                  openHours = [
                                    '24',
                                    '24',
                                    '24',
                                    '24',
                                    '24',
                                    '24',
                                    '24'
                                  ];
                                  closeHours = [
                                    '24',
                                    '24',
                                    '24',
                                    '24',
                                    '24',
                                    '24',
                                    '24'
                                  ];
                                }
                                areAll24HSelected = _!;
                                hours_24 = {
                                  0: areAll24HSelected,
                                  1: areAll24HSelected,
                                  2: areAll24HSelected,
                                  3: areAll24HSelected,
                                  4: areAll24HSelected,
                                  5: areAll24HSelected,
                                  6: areAll24HSelected,
                                };
                              },
                            );
                          }
                        : (_) {},
                  ),
                  Text(
                    '24H',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 40,
                  width: 60,
                  child: Center(
                    child: Text(
                      'Opening time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 40,
                  width: 60,
                  child: Center(
                    child: Text(
                      'Closing time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      scrollDirection: Axis.horizontal,
    );

    workingDaysList.add(initial);

    days.forEach((key, value) {
      Widget item = Container(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 50,
                    child: Center(
                      child: Text(
                        weekDays[key],
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Switch(
                    value: days[key] == true,
                    onChanged: (_) {
                      errorIndex = -1;
                      setState(() {
                        days[key] = _;
                        if (!_) {
                          openHours[key] = 'closed';
                          closeHours[key] = 'closed';
                        } else if (hours_24[key] == true) {
                          openHours[key] = '24';
                          closeHours[key] = '24';
                        }
                        if (days.toString() == allSelected.toString()) {
                          areAllDaysSelected = true;
                        } else {
                          areAllDaysSelected = false;
                        }
                      });
                    },
                  ),
                  Checkbox(
                    checkColor: Colors.white,
                    fillColor: MaterialStateColor.resolveWith((states) =>
                        value ? MyColors.primaryColor : Colors.grey),
                    value: hours_24[key] == true,
                    onChanged: value
                        ? (_) {
                            setState(() {
                              errorIndex = -1;
                              hours_24[key] = _!;
                              if (_) {
                                openHours[key] = '24';
                                closeHours[key] = '24';
                              }
                              if (hours_24.toString() ==
                                  allSelected.toString()) {
                                areAll24HSelected = true;
                              } else {
                                areAll24HSelected = false;
                              }
                            });
                          }
                        : (_) {},
                  ),
                  TextButton(
                    onPressed: value && hours_24[key] == false
                        ? () async {
                            errorIndex = -1;
                            final time = await showTimePicker(
                                context: context, initialTime: TimeOfDay.now());
                            if (time != null) {
                              setState(() {
                                openHours[key] =
                                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          }
                        : () {},
                    child: Container(
                      height: 40,
                      width: 60,
                      decoration: BoxDecoration(
                        color: value && hours_24[key] == false
                            ? Colors.white
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: value && hours_24[key] == false
                              ? MyColors.primaryColor
                              : Color(0xFF4A4A4A),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          openHours[key],
                          style: TextStyle(
                            color: value && hours_24[key] == false
                                ? Colors.black
                                : Color(0xFF4A4A4A),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: value && hours_24[key] == false
                        ? () async {
                            errorIndex = -1;
                            final time = await showTimePicker(
                                context: context, initialTime: TimeOfDay.now());
                            if (time != null) {
                              setState(() {
                                closeHours[key] =
                                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          }
                        : () {},
                    child: Container(
                      height: 40,
                      width: 60,
                      decoration: BoxDecoration(
                        color: value && hours_24[key] == false
                            ? Colors.white
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: value && hours_24[key] == false
                              ? MyColors.primaryColor
                              : Color(0xFF4A4A4A),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          closeHours[key],
                          style: TextStyle(
                            color: value && hours_24[key] == false
                                ? Colors.black
                                : Color(0xFF4A4A4A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        color: errorIndex == key ? Colors.red : Colors.white,
      );
      workingDaysList.add(item);
    });
    return workingDaysList;
  }

  List<Widget> getBasicInfo() {
    List<Widget> basicInfoList = [];
    Widget item = Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      final pickedImage = await ImagePicker()
                          .getImage(source: ImageSource.gallery);
                      if (pickedImage != null)
                        setState(() {
                          image = pickedImage;
                        });
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Image access denies'),
                          content: Text('Allow access?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await openAppSettings();
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    child: Center(
                      child: image == null
                          ? AllData.storeRepo['storeImage'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    AllData.storeRepo['storeImage'],
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.add_a_photo,
                                )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.file(
                                File(image.path),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Color(0xFFDADADA),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: storeNameCon,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 8.0),
                              labelText: 'Store Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: phoneCon,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 8.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              final details = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateStoreScreen(repo: AllData.storeRepo),
                ),
              );
              if (details != null) {
                final address = details['address'];
                final storeName = details['storeName'];
                lat = details['lat'];
                lon = details['lon'];
                storeNameCon.text = storeName;
                addressCon.text =
                    '${address.name} ${address.postalCode} ${address.subAdministrativeArea}';
                postalCodeCon.text = address.postalCode;
                cityCon.text = address.locality;
                setState(() {});
              }
            },
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      height: 40,
                      child: TextField(
                        enabled: false,
                        controller: cityCon,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 0, horizontal: 8.0),
                          labelText: 'City',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide:
                                BorderSide(width: 2, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      height: 40,
                      child: TextField(
                        enabled: false,
                        controller: postalCodeCon,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 0, horizontal: 8.0),
                          labelText: 'Postal Code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide:
                                BorderSide(width: 2, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      height: 40,
                      child: TextField(
                        enabled: false,
                        controller: addressCon,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 0, horizontal: 8.0),
                          labelText: 'Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide:
                                BorderSide(width: 2, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    basicInfoList.add(item);
    return basicInfoList;
  }

  void initializeStoreDetails(storeRepo) {
    if (storeRepo != null) {
      lat = storeRepo['latitude'];
      lon = storeRepo['longitude'];
      storeNameCon.text = storeRepo['storeName'];
      phoneCon.text = storeRepo['phoneNumber'];
      cityCon.text = storeRepo['city'];
      postalCodeCon.text = storeRepo['pinCode'].toString();
      addressCon.text = storeRepo['address'];
      openHours = storeRepo['openHours'];
      closeHours = storeRepo['closeHours'];
      for (int i = 0; i < 7; i++) {
        days[i] = openHours[i] != 'closed';
        hours_24[i] = openHours[i] == '24';
      }
      if (days.toString() == allSelected.toString()) {
        areAllDaysSelected = true;
      }
      if (hours_24.toString() == allSelected.toString()) {
        areAll24HSelected = true;
      }
      initialDetails = createDataObject();
    }
  }

  Map<String, String> createDataObject() {
    Map<String, String> timings = {};
    for (int i = 0; i < 7; i++) {
      timings.addAll({"openHours[$i]": openHours[i]});
      timings.addAll({"closeHours[$i]": closeHours[i]});
    }
    final updateDetails = {
      'storeName': '${storeNameCon.text}',
      'pinCode': '${postalCodeCon.text}',
      'city': '${cityCon.text}',
      'latitude': '$lat',
      'longitude': '$lon',
      'address': '${addressCon.text}',
      'phoneNumber': '${phoneCon.text}',
    };
    updateDetails.addAll(timings);
    return updateDetails;
  }
}
