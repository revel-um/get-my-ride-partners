import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_my_ride_partners_1/apis/AllApis.dart';
import 'package:get_my_ride_partners_1/components/elevatedIconComponent.dart';
import 'package:get_my_ride_partners_1/components/networkAndFileImage.dart';
import 'package:get_my_ride_partners_1/globalsAndConstants/allConstants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../homeScreen.dart';

class AddVehiclesTab extends StatefulWidget {
  final repo;
  final changeTab;
  final onStateChange;

  AddVehiclesTab(
      {@required this.changeTab, this.onStateChange = false, this.repo});

  @override
  _AddVehiclesTabState createState() => _AddVehiclesTabState();
}

class _AddVehiclesTabState extends State<AddVehiclesTab> {
  Map<String, List> vehicleTypes = {
    'CAR': [false, Icon(Icons.directions_car_rounded)],
    'BIKE': [false, Icon(Icons.motorcycle_outlined)],
    'SCOOTER': [false, Icon(Icons.electric_scooter)],
    'BICYCLE': [false, Icon(Icons.directions_bike_outlined)]
  };
  int currentIndex = 0;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  List<String> imagePaths = [];
  List<String> imageLinks = [];
  CarouselController carouselController = CarouselController();
  String currentCriteria = '';
  Map<String, List<dynamic>> controllers = {
    'Model Name': [TextEditingController(), TextInputType.text],
    'License Plate Number': [TextEditingController(), TextInputType.text],
    'Price per day': [TextEditingController(), TextInputType.number],
    'Price per hour': [TextEditingController(), TextInputType.number],
  };

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    return Scaffold(
      appBar: widget.repo != null
          ? AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ),
                      (route) => false);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'Edit Vehicle',
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
            )
          : null,
      backgroundColor: Colors.white,
      body: Scrollbar(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: widget.repo != null ? 4.0 : 0.0),
              child: Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: getListOfOptions(),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Choose Images (Max: 4)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 200,
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  shadowColor: Colors.white,
                  elevation: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            imagePaths = [];
                            List<XFile>? pickedImages =
                                await _picker.pickMultiImage();
                            imagePaths.addAll(imageLinks);
                            final remaining = 4 - imagePaths.length;
                            setState(() {
                              currentIndex = 0;
                            });
                            if (pickedImages != null) {
                              if (imagePaths.isNotEmpty)
                                carouselController.animateToPage(0);
                              int count = 0;
                              for (XFile image in pickedImages) {
                                count++;
                                imagePaths.add(image.path);
                                if (count == remaining) break;
                              }
                              setState(() {});
                            }
                          },
                          child: imagePaths.isNotEmpty
                              ? Container(
                                  color: Color(0xFFEBECF0),
                                  child: CarouselSlider(
                                    carouselController: carouselController,
                                    options: CarouselOptions(
                                        viewportFraction: 1.0,
                                        height: 3 * height / 4.3,
                                        enlargeCenterPage: false,
                                        enableInfiniteScroll:
                                            imagePaths.length > 1,
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            currentIndex = index;
                                          });
                                        }),
                                    items: imagePaths.map((i) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            width: double.infinity,
                                            child: NetworkAndFileImage(
                                              imageData: i,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Icon(Icons.add_a_photo),
                                  color: Color(0xFFFFFFFF),
                                ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            color: Colors.white38,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ...imagePaths.asMap().entries.map((entry) {
                                  return Container(
                                    width: 8.0,
                                    height: 8.0,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(
                                        currentIndex == entry.key ? 0.9 : 0.4,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                if (imagePaths.isNotEmpty)
                                  IconButton(
                                    onPressed: () async {
                                      if (imagePaths[currentIndex]
                                          .toString()
                                          .startsWith('http')) {
                                        final link =
                                            imageLinks.removeAt(currentIndex);
                                        imagePaths.removeAt(currentIndex);
                                        setState(() {
                                          print('link = $link');
                                        });
                                        SharedPreferences.getInstance()
                                            .then((value) {
                                          final token =
                                              value.getString('token');
                                          final productId = widget.repo['_id'];
                                          AllApis()
                                              .deleteImageFromProduct(
                                                  token: token,
                                                  productId: productId,
                                                  deleteLink: link)
                                              .then((value) {
                                            if (value.statusCode == 200) {
                                              print('statusCode 200');
                                              AllData.storeRepo = null;
                                              AllData.productRepo = null;
                                            }
                                          });
                                        });
                                      } else {
                                        imagePaths.removeAt(currentIndex);
                                        if (imagePaths.isNotEmpty)
                                          carouselController.animateToPage(0);
                                        setState(() {
                                          currentIndex = 0;
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ...getTextFields(),
            GestureDetector(
              onTap: () async {
                if (currentCriteria.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('You have to select to criteria of vehicle')));
                  return;
                }
                bool stopLoop = false;
                controllers.forEach((key, value) {
                  if (stopLoop == true) {
                    return;
                  }
                  if (value[0].text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$key can not be empty'),
                      ),
                    );
                    stopLoop = true;
                  }
                });
                if (stopLoop) {
                  stopLoop = false;
                  return;
                }
                setState(() {
                  isLoading = true;
                  if (widget.onStateChange != null)
                    widget.onStateChange(touchWorks: !isLoading);
                });
                AllApis apis = AllApis();
                List pickedFiles = [];
                imagePaths.forEach((element) {
                  if (!element.startsWith('http')) {
                    pickedFiles.add(element);
                  }
                });
                SharedPreferences pref = await SharedPreferences.getInstance();
                final token = pref.getString('token');
                final storeId = pref.getString('storeId');
                final response = await apis.addOrUpdateProductToStore(
                  token: token,
                  storeId: storeId,
                  files: pickedFiles,
                  isUpdating: widget.repo != null,
                  id: widget.repo != null ? widget.repo['_id'] : null,
                  model: controllers['Model Name']![0].text,
                  licencePlate: controllers['License Plate Number']![0].text,
                  rentPerHour: controllers['Price per day']![0].text,
                  rentPerDay: controllers['Price per hour']![0].text,
                  criteria: currentCriteria,
                );
                if (response == null) {
                  setState(() {
                    isLoading = false;
                    if (widget.onStateChange != null)
                      widget.onStateChange(touchWorks: !isLoading);
                  });
                  return;
                }
                if (response.statusCode == 200) {
                  if (widget.repo != null) {
                    AllData.resetStoreTabData();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
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
                    widget.onStateChange(touchWorks: !isLoading);
                });
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Material(
                    elevation: 10,
                    child: Container(
                      width: 100,
                      height: 40,
                      child: Center(
                          child: Text(
                        'SAVE',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                      decoration: BoxDecoration(color: MyColors.primaryColor),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print(widget.repo);
    AllApis.staticPage = AddVehiclesTab(
      changeTab: widget.changeTab,
      repo: widget.repo,
      onStateChange: widget.onStateChange,
    );
    AllApis.staticContext = context;
    if (widget.repo != null) {
      populateRepoData(widget.repo);
    }
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white, // navigation bar color
      statusBarColor: Colors.white12, // status bar color
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  getListOfOptions({height = 20, width = 20}) {
    List<Widget> items = [];
    vehicleTypes.forEach((key, value) {
      items.add(
        ElevatedIconComponent(
          backgroundColor:
              value[0] == true ? MyColors.primaryColor : Colors.white,
          icon: value[1],
          shadowColor: Colors.white,
          title: key,
          onTap: () {
            setState(
              () {
                final currentState = !value[0];
                vehicleTypes = vehicleTypes = {
                  'CAR': [false, Icon(Icons.directions_car_rounded)],
                  'BIKE': [false, Icon(Icons.motorcycle_outlined)],
                  'SCOOTER': [false, Icon(Icons.electric_scooter)],
                  'BICYCLE': [false, Icon(Icons.directions_bike_outlined)]
                };
                vehicleTypes[key] = [currentState, value[1]];
                if (currentState == true) {
                  currentCriteria = key;
                } else {
                  currentCriteria = '';
                }
              },
            );
          },
        ),
      );
    });
    return items;
  }

  getTextFields() {
    List<Widget> items = [];
    controllers.forEach((key, value) {
      items.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Material(
          elevation: 10,
          child: TextField(
            controller: value[0],
            keyboardType: value[1],
            inputFormatters: value[1] == TextInputType.number
                ? <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ]
                : [],
            textCapitalization: TextCapitalization.words,
            style: TextStyle(fontFamily: 'ZenKurenaido'),
            decoration: InputDecoration(
              fillColor: Colors.grey[100],
              prefix: value[1] == TextInputType.number ? Text('\u20B9') : null,
              labelText: key,
              hintStyle: TextStyle(fontSize: 14, fontFamily: 'ZenKurenaido'),
              filled: true,
              border: InputBorder.none,
            ),
          ),
        ),
      ));
    });
    return items;
  }

  void populateRepoData(repo) {
    for (String image in repo['productImages']) {
      imageLinks.add(image);
    }
    imagePaths.addAll(imageLinks);
    final criteria = repo['criteria'].toString().toUpperCase();
    currentCriteria = criteria;
    final icon = vehicleTypes[criteria]![1];
    vehicleTypes[repo['criteria'].toString().toUpperCase()] = [true, icon];
    controllers['Model Name']![0].text =
        repo['model'] != null ? repo['model'] : '';
    controllers['License Plate Number']![0].text =
        repo['licencePlate'] != null ? repo['licencePlate'] : '';
    controllers['Price per day']![0].text =
        repo['rentPerDay'] != null ? repo['rentPerDay'] : '';
    controllers['Price per hour']![0].text =
        repo['rentPerHour'] != null ? repo['rentPerHour'] : '';
  }
}
