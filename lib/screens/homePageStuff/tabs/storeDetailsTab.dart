import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_my_ride_partners_1/apis/AllApis.dart';
import 'package:get_my_ride_partners_1/components/expandListView.dart';
import 'package:get_my_ride_partners_1/components/timeTextFields.dart';
import 'package:get_my_ride_partners_1/globalsAndConstants/allConstants.dart';
import 'package:get_my_ride_partners_1/models/weekDaysInfo.dart';
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
  Map<String, WeekDaysInfo> workingDays = {
    'Monday': WeekDaysInfo('Monday'),
    'Tuesday': WeekDaysInfo('Tuesday'),
    'Wednesday': WeekDaysInfo('Wednesday'),
    'Thursday': WeekDaysInfo('Thursday'),
    'Friday': WeekDaysInfo('Friday'),
    'Saturday': WeekDaysInfo('Saturday'),
    'Sunday': WeekDaysInfo('Sunday'),
  };
  Map<int, String> indexToDay = {
    0: 'Monday',
    1: 'Tuesday',
    2: 'Wednesday',
    3: 'Thursday',
    4: 'Friday',
    5: 'Saturday',
    6: 'Sunday'
  };
  Map<String, int> dayToIndex = {
    'Monday': 0,
    'Tuesday': 1,
    'Wednesday': 2,
    'Thursday': 3,
    'Friday': 4,
    'Saturday': 5,
    'Sunday': 6
  };
  var image;
  double lat = 0.0, lon = 0.0;
  bool isLoading = false;
  TextEditingController storeNameCon = TextEditingController(),
      phoneCon = TextEditingController(),
      cityCon = TextEditingController(),
      postalCodeCon = TextEditingController(),
      addressCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Basic ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: 'Information',
                              style: TextStyle(
                                  fontFamily: 'ZenKurenaido',
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          final updateDetails = {
                            'storeName': '${storeNameCon.text}',
                            'pinCode': '${postalCodeCon.text}',
                            'city': '${cityCon.text}',
                            'latitude': '$lat',
                            'longitude': '$lon',
                            'address': '${addressCon.text}',
                            'phoneNumber': '${phoneCon.text}',
                          };
                          SharedPreferences.getInstance().then((value) {
                            final token = value.getString('token');
                            final storeId = value.getString('storeId');
                            AllApis()
                                .updateStore(
                                    token: token,
                                    storeId: storeId,
                                    updateObject: updateDetails,
                                    file: image)
                                .then((value) {
                              setState(() {
                                isLoading = false;
                              });
                              if (value.statusCode == 200) {
                                AllData.productRepo = null;
                                AllData.storeRepo = null;
                                widget.changeTab(
                                    index: 0, msg: 'Update Successful');
                              }
                            });
                          });
                        },
                        child: Text(
                          'SAVE',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...getBasicInfo(),
                //___________________________Weekly Schedule starts from now on_________________________________________
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Weekly ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: 'Schedule',
                              style: TextStyle(
                                  fontFamily: 'ZenKurenaido',
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          Map<String, String> scheduleMap = {};
                          workingDays.forEach((key, value) {
                            if (checkIfOpen24(value)) {
                              scheduleMap['openHours[${dayToIndex[key]}]'] =
                                  '24';
                              scheduleMap['closeHours[${dayToIndex[key]}]'] =
                                  '24';
                            } else {
                              scheduleMap['openHours[${dayToIndex[key]}]'] =
                                  value.calculateOpenHourAsString();
                              scheduleMap['closeHours[${dayToIndex[key]}]'] =
                                  value.calculateCloseHourAsString();
                            }
                          });
                          print(scheduleMap);
                          SharedPreferences.getInstance().then((value) {
                            final token = value.getString('token');
                            final storeId = value.getString('storeId');
                            AllApis()
                                .updateStore(
                                    token: token,
                                    storeId: storeId,
                                    updateObject: scheduleMap,
                                    file: image)
                                .then((value) {
                              setState(() {
                                isLoading = false;
                              });
                              if (value.statusCode == 200) {
                                AllData.productRepo = null;
                                AllData.storeRepo = null;
                                widget.changeTab(
                                    index: 0, msg: 'Update Successful');
                              }
                            });
                          });
                        },
                        child: Text(
                          'SAVE',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                workingDaysSelectionCheckBoxes(),
                ...getDaysInfoCard(),
              ],
            ),
            Center(
              child: isLoading ? SpinKit.spinner : null,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getBasicInfo() {
    List<Widget> basicInfoList = [];
    Widget item = Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (AllData.storeRepo['storeImage'] != null) {
                          _showPopupMenu(onImageChoose: () async {
                            await chooseImage();
                          }, onImageDelete: () {
                            setState(() {
                              isLoading = true;
                              AllData.storeRepo['storeImage'] = null;
                            });
                            SharedPreferences.getInstance().then((value) {
                              final token = value.getString('token');
                              final storeId = value.getString('storeId');
                              AllApis()
                                  .deleteImageFromStore(
                                      token: token, storeId: storeId)
                                  .then((value) {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            });
                          });
                        } else {
                          await chooseImage();
                        }
                      },
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 100,
                          width: 100,
                          child: Center(
                            child: image == null
                                ? AllData.storeRepo['storeImage'] != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
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
                  ],
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
                        child: Material(
                          elevation: 5.0,
                          child: Container(
                            height: 40,
                            child: TextField(
                              controller: storeNameCon,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                hintText: 'Store Name',
                                hintStyle: TextStyle(
                                    fontSize: 14, fontFamily: 'ZenKurenaido'),
                                filled: true,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Material(
                          elevation: 5.0,
                          child: Container(
                            height: 40,
                            //TODO: Manage phone number text field so country code is not disturbed
                            //Suggestion: Re-verify the phone number and extract the value of phone number
                            child: TextField(
                              controller: phoneCon,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                hintText: 'Phone Number',
                                hintStyle: TextStyle(
                                    fontSize: 14, fontFamily: 'ZenKurenaido'),
                                filled: true,
                                border: InputBorder.none,
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
                    child: Material(
                      elevation: 5.0,
                      child: Container(
                        height: 40,
                        child: TextField(
                          enabled: false,
                          controller: cityCon,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            hintText: 'City',
                            hintStyle: TextStyle(
                                fontSize: 14, fontFamily: 'ZenKurenaido'),
                            filled: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Material(
                      elevation: 5.0,
                      child: Container(
                        height: 40,
                        child: TextField(
                          enabled: false,
                          controller: postalCodeCon,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            hintText: 'Postal Code',
                            hintStyle: TextStyle(
                                fontSize: 14, fontFamily: 'ZenKurenaido'),
                            filled: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Material(
                      elevation: 5.0,
                      child: Container(
                        height: 40,
                        child: TextField(
                          enabled: false,
                          controller: addressCon,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            hintText: 'Address',
                            hintStyle: TextStyle(
                                fontSize: 14, fontFamily: 'ZenKurenaido'),
                            filled: true,
                            border: InputBorder.none,
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

  workingDaysSelectionCheckBoxes() {
    List<Widget> checkBoxes = [];
    workingDays.forEach(
      (key, value) {
        checkBoxes.add(
          ChoiceChip(
            selectedColor: MyColors.primaryColor,
            label: Text(
              key.toString().substring(0, 1),
              style: TextStyle(
                color: value.getIsOpened() ? Colors.white : Colors.black,
              ),
            ),
            selected: value.getIsOpened(),
            onSelected: (_) {
              setState(() {
                workingDays[key]!.setIsOpened(_);
              });
            },
          ),
        );
      },
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          children: checkBoxes,
        ),
      ),
    );
  }

  getDaysInfoCard() {
    List<Widget> cards = [];
    bool first = true;
    workingDays.forEach(
      (key, value) {
        if (value.getIsOpened() == true) {
          final initiallyExpanded = first;
          first = false;
          cards.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpandListView(
                initiallyExpanded: initiallyExpanded,
                children: <Widget>[
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Checkbox(
                          activeColor: MyColors.primaryColor,
                          value: value.getIsOpen24(),
                          onChanged: (val) {
                            setState(
                              () {
                                value.setIsOpen24(val);
                              },
                            );
                          },
                        ),
                      ),
                      Text('OPEN 24H'),
                    ],
                  ),
                  if (value.getIsOpen24() == false)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          TimeTextField(
                            onTimeChange: (time) {
                              value.setOpenHour(time);
                            },
                            initialValue: value.getOpenHour(),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          TimeTextField(
                            onTimeChange: (time) {
                              value.setCloseHour(time);
                            },
                            initialValue: value.getCloseHour(),
                          ),
                        ],
                      ),
                    ),
                ],
                title: Text(
                  key,
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'ZenKurenaido',
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }
      },
    );
    return cards;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    initializeStoreDetails(AllData.storeRepo);
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
      final openHours = storeRepo['openHours'];
      final closeHours = storeRepo['closeHours'];
      for (int i = 0; i < 7; i++) {
        workingDays[indexToDay[i]]!.setOpenHour(
            openHours[i] != 'closed' && openHours[i] != '24'
                ? openHours[i]
                : '_ _ : _ _');
        workingDays[indexToDay[i]]!.setCloseHour(
            closeHours[i] != 'closed' && closeHours[i] != '24'
                ? closeHours[i]
                : '_ _ : _ _');
        workingDays[indexToDay[i]]!.setIsOpened(openHours[i] != 'closed');
        workingDays[indexToDay[i]]!.setIsOpen24(openHours[i] == '24');
      }
    }
  }

  bool checkIfOpen24(value) {
    final openTime = value.calculateOpenHourAsString();
    final closeTime = value.calculateCloseHourAsString();
    if (openTime == '24' ||
        openTime == 'closed' ||
        closeTime == '24' ||
        closeTime == 'closed') return false;
    if (openTime == closeTime) {
      return true;
    }
    return false;
  }

  _showPopupMenu({onImageChoose, onImageDelete}) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(50.0, 160.0, 100.0, 0.0),
      //position where you want to show the menu on screen
      items: [
        PopupMenuItem<String>(child: const Text('Choose Image'), value: '1'),
        PopupMenuItem<String>(child: const Text('Delete Image'), value: '2'),
      ],
      elevation: 8.0,
    ).then(
      (value) {
        if (value == '1') {
          onImageChoose();
        } else if (value == '2') {
          onImageDelete();
        }
      },
    );
  }

  Future<void> chooseImage() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
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
  }
}
