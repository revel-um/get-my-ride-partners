import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_my_ride_partners_1/apis/AllApis.dart';
import 'package:get_my_ride_partners_1/components/shimmerWidget.dart';
import 'package:get_my_ride_partners_1/globalsAndConstants/allConstants.dart';
import 'package:get_my_ride_partners_1/globalsAndConstants/networkChecker.dart';
import 'package:get_my_ride_partners_1/screens/homePageStuff/homeScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../offlinePage.dart';

class CreateStoreScreen extends StatefulWidget {
  final repo;

  const CreateStoreScreen({this.repo});

  @override
  _CreateStoreScreenState createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  late GoogleMapController _googleMapController;
  Marker marker = Marker(
    markerId: MarkerId('location'),
    position: LatLng(28.7041, 77.1025),
  );
  var image;
  String networkImageLink = '';
  bool isNetworkImage = false;
  bool isLoading = true;
  var address;
  bool showError = false;
  double zoom = 15;
  TextEditingController _nameCon = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _googleMapController.dispose();
  }

  double lat = double.infinity, lon = double.infinity;
  var initialCameraPosition =
      CameraPosition(target: LatLng(28.7041, 77.1025), zoom: 11.5);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        appBar: widget.repo == null
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                title: Text('Address Details'),
              ),
        bottomSheet: BottomSheet(
          enableDrag: false,
          elevation: 10,
          builder: (BuildContext context) {
            return Container(
              height: MediaQuery.of(context).size.height / 4 < 180
                  ? 180
                  : MediaQuery.of(context).size.height / 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ShimmerWidget(
                  isLoading: isLoading,
                  child: AbsorbPointer(
                    absorbing: isLoading,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.repo == null)
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    final pickedImage = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);
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
                                        ? isNetworkImage
                                            ? Image.network(networkImageLink)
                                            : Icon(
                                                Icons.add_a_photo,
                                              )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
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
                            Expanded(
                              child: Container(
                                height: 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Container(
                                        height: 40,
                                        child: TextField(
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textAlign: TextAlign.center,
                                          controller: _nameCon,
                                          onChanged: (_) {
                                            setState(() {
                                              showError = false;
                                            });
                                          },
                                          decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: MyColors.primaryColor,
                                                  width: 2,
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: MyColors.primaryColor,
                                                  width: 2,
                                                ),
                                              ),
                                              errorText: showError
                                                  ? 'Store name requires'
                                                  : null,
                                              isDense: true,
                                              labelText: 'Name of Store',
                                              labelStyle: TextStyle(
                                                  color: Colors.black)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        address == null ? '' : address.name,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          child: Center(child: Text('DONE')),
                          onPressed: () async {
                            if (_nameCon.text.isEmpty) {
                              setState(
                                () {
                                  showError = true;
                                },
                              );
                              return;
                            }
                            if (lat == double.infinity ||
                                lon == double.infinity) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('No location found'),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              isLoading = true;
                            });
                            if (widget.repo == null) {
                              AllApis apis = AllApis();
                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                              final token = pref.getString('token');
                              final phoneNumber = pref.getString('phoneNumber');
                              final response = await apis.createNewStore(
                                token: token,
                                address: address,
                                file: image,
                                storeName: _nameCon.text,
                                latitude: lat,
                                longitude: lon,
                                phoneNumber: phoneNumber,
                              );
                              if (response != null &&
                                  response.statusCode == 200) {
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                final body = jsonDecode(response.body);
                                await pref.setString(
                                    'storeId', body["object"]["_id"]);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            } else {
                              Navigator.pop(
                                context,
                                {
                                  'storeName': _nameCon.text,
                                  'storeImage': image == null ? null : image,
                                  'lat': lat,
                                  'lon': lon,
                                  'address': address,
                                },
                              );
                            }
                            setState(() {
                              isLoading = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            );
          },
          onClosing: () {},
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Permission.locationWhenInUse.status.then(
              (value) => onStatusReceived(value),
            );
            _googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                lat == double.infinity
                    ? initialCameraPosition
                    : CameraPosition(target: LatLng(lat, lon), zoom: zoom),
              ),
            );
            if (lat == double.infinity || lon == double.infinity) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'We are not able to get your location try restarting the app'),
                ),
              );
            }
          },
          tooltip: 'My Location',
          child: Icon(
            Icons.location_on,
            color: MyColors.primaryColor,
          ),
        ),
        body: GoogleMap(
          markers: {
            if (lat != double.infinity && lon != double.infinity) marker
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onTap: (val) async {
            setState(() {
              isLoading = true;
              lat = val.latitude;
              lon = val.longitude;
            });
            marker = Marker(
              markerId: MarkerId('location'),
              position: LatLng(lat, lon),
            );
            _googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: LatLng(lat, lon), zoom: zoom),
              ),
            );
            try {
              List<Placemark> addresses =
                  await placemarkFromCoordinates(lat, lon);
              address = addresses[0];
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Address not found'),
                ),
              );
            }
            setState(() {
              isLoading = false;
            });
          },
          onMapCreated: (controller) => _googleMapController = controller,
          initialCameraPosition: initialCameraPosition,
        ),
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
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    if (widget.repo != null) {
      print(widget.repo);
      lat = widget.repo['latitude'];
      lon = widget.repo['longitude'];
      _nameCon.text = widget.repo['storeName'];
      networkImageLink =
          widget.repo['storeImage'] == null ? '' : widget.repo['storeImage'];
      if (networkImageLink.isNotEmpty) {
        isNetworkImage = true;
      }
    }
    AllApis.staticPage = CreateStoreScreen(
      repo: widget.repo,
    );
    AllApis.staticContext = context;
    Permission.locationWhenInUse.status.then(
      (value) => onStatusReceived(value),
    );
  }

  onStatusReceived(PermissionStatus status) async {
    if (await NetworkCheckingClass().hasNetwork() == false) {
      goOffline(isLocationError: false);
      return;
    }
    if (status == PermissionStatus.denied) {
      await Permission.locationWhenInUse.request().isGranted;
    }
    if (status == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }
    bool permissionGranted = await Permission.location.isGranted;
    bool locationAvailable = await Geolocator.isLocationServiceEnabled();
    if (!permissionGranted || !locationAvailable) {
      goOffline(isLocationError: true);
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      lat = position.latitude;
      lon = position.longitude;
      try {
        final addresses = await placemarkFromCoordinates(lat, lon);
        marker = Marker(
          markerId: MarkerId('location'),
          position: LatLng(lat, lon),
        );
        setState(() {
          var mark1;
          if (addresses.isNotEmpty) mark1 = addresses[0];
          if (mark1 != null) address = mark1;
          _googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(lat, lon), zoom: zoom),
            ),
          );
          isLoading = false;
        });
      } catch (e) {}
      setState(() {
        isLoading = false;
      });
    }
  }

  void goOffline({isLocationError}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OfflinePage(
          comingFrom: AllApis.staticPage,
          locationError: isLocationError,
        ),
      ),
    );
  }
}
