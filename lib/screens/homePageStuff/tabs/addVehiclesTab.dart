import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_my_ride_partners_1/apis/AllApis.dart';
import 'package:get_my_ride_partners_1/globalsAndConstants/allConstants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../homeScreen.dart';

class AddVehiclesTab extends StatefulWidget {
  final changeTab;
  final onStateChange;
  final repo;

  AddVehiclesTab(
      {@required this.changeTab, this.onStateChange = false, this.repo});

  @override
  _AddVehiclesTabState createState() => _AddVehiclesTabState();
}

class _AddVehiclesTabState extends State<AddVehiclesTab> {
  int vehicleTypeIndex = -1;
  List<String> vehicleTypes = ['CAR', 'BIKE', 'SCOOTER', 'BICYCLE'];
  List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  List<String> hints = [
    'Model name',
    'Licence plate number',
    'Rent per hour',
    'Rent per day',
  ];
  var image;
  bool isLoading = false;
  final spinner = SpinKitSpinningLines(
    color: MyColors.primaryColor,
  );
  String imageLink = '';
  bool isNetworkImage = false;
  var pickedFile;

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Stack(
          children: [
            Container(
              color: Color(0xFFF1F1F1),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.repo == null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 40.0),
                            child: Text(
                              'Add vehicle',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                          ),
                        for (int i = 0; i < hints.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: TextField(
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: MyColors.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                isDense: true,
                                hintText: hints[i],
                              ),
                              keyboardType: i == 2 || i == 3
                                  ? TextInputType.numberWithOptions(
                                      signed: false, decimal: false)
                                  : TextInputType.text,
                              inputFormatters: i == 2 || i == 3
                                  ? <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                    ]
                                  : null,
                              controller: controllers[i],
                            ),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RotatedBox(
                                quarterTurns: 3,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      vehicleTypeIndex = 0;
                                    });
                                  },
                                  child: Text(
                                    'CAR',
                                    style: TextStyle(
                                      fontWeight: vehicleTypeIndex == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: vehicleTypeIndex == 0
                                          ? MyColors.primaryColor
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              RotatedBox(
                                quarterTurns: 3,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      vehicleTypeIndex = 1;
                                    });
                                  },
                                  child: Text(
                                    'BIKE',
                                    style: TextStyle(
                                      fontWeight: vehicleTypeIndex == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: vehicleTypeIndex == 1
                                          ? MyColors.primaryColor
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              RotatedBox(
                                quarterTurns: 3,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      vehicleTypeIndex = 2;
                                    });
                                  },
                                  child: Text(
                                    'SCOOTER',
                                    style: TextStyle(
                                      fontWeight: vehicleTypeIndex == 2
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: vehicleTypeIndex == 2
                                          ? MyColors.primaryColor
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              RotatedBox(
                                quarterTurns: 3,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      vehicleTypeIndex = 3;
                                    });
                                  },
                                  child: Text(
                                    'BICYCLE',
                                    style: TextStyle(
                                      fontWeight: vehicleTypeIndex == 3
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: vehicleTypeIndex == 3
                                          ? MyColors.primaryColor
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 2,
                                width: MediaQuery.of(context).size.width / 1.5,
                                decoration: BoxDecoration(
                                  color: Color(0xFF1F1F1F),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final pickedFile = await ImagePicker()
                                              .getImage(
                                                  source: ImageSource.gallery);
                                          if (pickedFile != null) {
                                            this.pickedFile = pickedFile;
                                            setState(() {
                                              image = File(pickedFile.path);
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2 -
                                              100,
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.5 -
                                              50,
                                          decoration: BoxDecoration(
                                            color: MyColors.primaryColor,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(18),
                                              bottomLeft: Radius.circular(20),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: image == null
                                                    ? (imageLink.isNotEmpty &&
                                                            widget.repo != null)
                                                        ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topRight: Radius
                                                                  .circular(18),
                                                              bottomLeft: Radius
                                                                  .circular(18),
                                                            ),
                                                            child:
                                                                Image.network(
                                                              imageLink,
                                                              height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      2 -
                                                                  100,
                                                              width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      1.5 -
                                                                  50,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : Icon(
                                                            Icons
                                                                .add_photo_alternate,
                                                            color: Colors.white,
                                                          )
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  18),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  18),
                                                        ),
                                                        child: Image.file(
                                                          image,
                                                          height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  2 -
                                                              100,
                                                          width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.5 -
                                                              50,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                              ),
                                              if (image == null &&
                                                  (imageLink.isEmpty &&
                                                      widget.repo == null))
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      'Select Image >>>',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (vehicleTypeIndex == -1) {
                                            showSnackBar(
                                                'Choose a vehicle type');
                                            return;
                                          }
                                          if (!isNetworkImage &&
                                              image == null) {
                                            showSnackBar(
                                                'Please select an image');
                                            return;
                                          }
                                          int count = 0;
                                          for (TextEditingController element
                                              in controllers) {
                                            if (count == 1) {
                                              count++;
                                              continue;
                                            }
                                            count++;
                                            if (element.text.isEmpty) {
                                              return showSnackBar(
                                                'Some of the fields are empty',
                                              );
                                            }
                                          }
                                          setState(() {
                                            isLoading = true;
                                            if (widget.onStateChange != null)
                                              widget.onStateChange(
                                                  touchWorks: !isLoading);
                                          });
                                          AllApis apis = AllApis();
                                          SharedPreferences pref =
                                              await SharedPreferences
                                                  .getInstance();
                                          final token = pref.getString('token');
                                          final storeId =
                                              pref.getString('storeId');
                                          final response = await apis
                                              .addOrUpdateProductToStore(
                                            token: token,
                                            storeId: storeId,
                                            file: pickedFile,
                                            isUpdating: widget.repo != null,
                                            id: widget.repo != null
                                                ? widget.repo['_id']
                                                : null,
                                            model: controllers[0].text,
                                            licencePlate: controllers[1].text,
                                            rentPerHour: controllers[2].text,
                                            rentPerDay: controllers[3].text,
                                            criteria:
                                                vehicleTypes[vehicleTypeIndex],
                                          );
                                          if (response == null) {
                                            setState(() {
                                              isLoading = false;
                                              if (widget.onStateChange != null)
                                                widget.onStateChange(
                                                    touchWorks: !isLoading);
                                            });
                                            return;
                                          }
                                          if (response.statusCode == 200) {
                                            if (widget.repo != null) {
                                              AllData.resetStoreTabData();
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeScreen(),
                                                ),
                                                (route) => false,
                                              );
                                            } else {
                                              setState(() {
                                                AllData.resetStoreTabData();
                                                widget.changeTab(index: 0);
                                              });
                                            }
                                          }
                                          setState(() {
                                            isLoading = false;
                                            if (widget.onStateChange != null)
                                              widget.onStateChange(
                                                  touchWorks: !isLoading);
                                          });
                                        },
                                        child: Container(
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.5 -
                                              50,
                                          decoration: BoxDecoration(
                                            color: isLoading
                                                ? Colors.grey
                                                : MyColors.primaryColor,
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(18),
                                              topLeft: Radius.circular(20),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'DONE',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                        ),
                      ],
                    ),
                  ),
                  if (widget.repo != null)
                    TextButton(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              isLoading ? Colors.grey : MyColors.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            'DELETE',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                          if (widget.onStateChange != null)
                            widget.onStateChange(
                                touchWorks: !isLoading);
                        });
                        AllApis apis = AllApis();
                        final productId = widget.repo['_id'];
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        final token = pref.getString('token');
                        await apis.deleteProductById(
                            token: token, productId: productId);
                        AllData.resetStoreTabData();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(),
                          ),
                          (route) => false,
                        );
                        setState(() {
                          isLoading = false;
                          if (widget.onStateChange != null)
                            widget.onStateChange(
                                touchWorks: !isLoading);
                        });
                      },
                    ),
                ],
              ),
            ),
            Center(
              child: isLoading ? spinner : null,
            ),
          ],
        ),
      ),
    );
    if (widget.repo != null) {
      return AbsorbPointer(
        absorbing: isLoading,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('Edit Vehicle'),
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                  (route) => false,
                );
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
          ),
          body: body,
        ),
      );
    }
    return body;
  }

  @override
  void initState() {
    super.initState();
    if (widget.repo != null) {
      AllApis.staticContext = context;
      AllApis.staticPage = AddVehiclesTab(
        changeTab: widget.changeTab,
        onStateChange: widget.onStateChange,
        repo: widget.repo,
      );
    }
    if (widget.repo != null) {
      isNetworkImage = true;
      imageLink = widget.repo['productImages'] == null ||
              widget.repo['productImages'].isEmpty
          ? ''
          : widget.repo['productImages'][0];
      controllers[0].text = widget.repo['model'];
      controllers[1].text = widget.repo['licencePlate'];
      controllers[2].text = widget.repo['rentPerHour'];
      controllers[3].text = widget.repo['rentPerDay'];
      final vehicleType = widget.repo['criteria'];
      vehicleTypeIndex = vehicleTypes.indexOf(vehicleType);
    }
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Color(0xFFF1F1F1),
        systemNavigationBarDividerColor: Color(0xFFF1F1F1),
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void showSnackBar(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          s,
        ),
      ),
    );
  }
}
