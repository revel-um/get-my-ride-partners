import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_my_ride_partners_1/apis/AllApis.dart';
import 'package:get_my_ride_partners_1/components/shimmerWidget.dart';
import 'package:get_my_ride_partners_1/globalsAndConstants/allConstants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'addVehiclesTab.dart';


class StoreTab extends StatefulWidget {
  final changeTab;
  final onStateChange;

  const StoreTab({@required this.changeTab, this.onStateChange});

  @override
  _StoreTabState createState() => _StoreTabState();
}

class _StoreTabState extends State<StoreTab> {
  bool isLoading = true;
  Color localPrimary = MyColors.primaryColor;
  dynamic storeRepo;
  List<dynamic> productRepo = [];
  List<Widget> children = [];
  Map<String, bool> vehicleTypes = {
    'CAR': true,
    'BIKE': true,
    'SCOOTER': true,
    'BICYCLE': true,
  };
  var _debounce;
  late StreamSubscription<bool> keyboardSubscription;
  TextEditingController searchCon = TextEditingController();
  bool showCancelButton = false;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && productRepo.isEmpty) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Color(0xFFECECEC), width: 2),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.search,
                                color: !isLoading && productRepo.isEmpty
                                    ? Color(0xFFECECEC)
                                    : localPrimary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Search...',
                                style: TextStyle(
                                    color: !isLoading && productRepo.isEmpty
                                        ? Color(0xFFECECEC)
                                        : Colors.grey,
                                    fontWeight: FontWeight.w600),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(99),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: CircleAvatar(
                          child: storeRepo != null
                              ? storeRepo['storeImage'] != null
                                  ? Image.network(
                                      storeRepo['storeImage'],
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: MyColors.primaryColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          storeRepo['storeName']
                                              .toString()
                                              .characters
                                              .first
                                              .toUpperCase(),
                                        ),
                                      ),
                                    )
                              : Icon(Icons.settings),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SvgPicture.asset(
                  'assets/svgs/no_data.svg',
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width / 3,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  FloatingActionButton(
                    backgroundColor: localPrimary,
                    onPressed: () {
                      storeRepo = null;
                      widget.changeTab(index: 1);
                    },
                    child: Icon(Icons.add),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '\nADD PRODUCTS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: localPrimary,
                          ),
                        ),
                      ],
                      text: 'You Do not have any vehicles in your store!',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return AbsorbPointer(
      absorbing: isLoading,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ShimmerWidget(
            isLoading: isLoading,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () async {},
                          child: Container(
                            height: 45,
                            child: TextField(
                              controller: searchCon,
                              onChanged: (_) {
                                _onSearchChanged(_);
                              },
                              decoration: InputDecoration(
                                suffixIcon: showCancelButton
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            showCancelButton = false;
                                          });
                                          searchCon.clear();
                                          _onSearchChanged('');
                                        },
                                      )
                                    : null,
                                hintText:
                                    'Model, licence plate, vehicle type...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                contentPadding: EdgeInsets.zero,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: MyColors.primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Color(0xFFECECEC),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(99),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: CircleAvatar(
                            child: storeRepo != null
                                ? storeRepo['storeImage'] != null
                                    ? Image.network(
                                        storeRepo['storeImage'],
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: MyColors.primaryColor),
                                        child: Center(
                                          child: Text(
                                            storeRepo['storeName']
                                                .toString()
                                                .characters
                                                .first,
                                          ),
                                        ),
                                      )
                                : Icon(Icons.settings),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isLoading
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            height: 20,
                            width: 100,
                          )
                        : Text(
                            storeRepo['storeName'],
                            style: TextStyle(
                              letterSpacing: 2,
                              wordSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                Wrap(
                  children: getVehicleChips(),
                ),
                isLoading
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: children,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    if (_debounce != null) _debounce.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('initState');
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        FocusScope.of(context).unfocus();
      }
    });
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    if (AllData.storeRepo == null) {
      initAll();
    } else {
      storeRepo = AllData.storeRepo;
      productRepo = AllData.productRepo;
      isLoading = false;
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        getVehicleList('');
      });
    }
  }

  void initAll() async {
    final pref = await SharedPreferences.getInstance();
    final storeId = pref.getString('storeId');
    final token = pref.getString('token');
    AllApis apis = AllApis();
    if (widget.onStateChange != null) widget.onStateChange(touchWorks: false);
    final response =
        await apis.getProductsOfStore(token: token, storeId: storeId);
    if (response == null) return;
    if (response.statusCode == 200) {
      if (mounted)
        setState(() {
          isLoading = false;
          if (widget.onStateChange != null)
            widget.onStateChange(touchWorks: true);
          productRepo = jsonDecode(response.body)['data']['products'];
          storeRepo = jsonDecode(response.body)['data']['store'];
          AllData.storeRepo = storeRepo;
          AllData.productRepo = productRepo;
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            getVehicleList('');
          });
        });
    } else {
      if (mounted)
        setState(() {
          isLoading = false;
          if (widget.onStateChange != null)
            widget.onStateChange(touchWorks: true);
        });
    }
  }

  List<Widget> getVehicleChips() {
    List<Widget> chips = [];
    vehicleTypes.forEach((key, value) {
      chips.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ChoiceChip(
          label: Text(
            key,
            style: TextStyle(
              color: value ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          selectedColor: MyColors.primaryColor,
          selected: value,
          onSelected: (bool selected) {
            setState(() {
              vehicleTypes[key] = !value;
              getVehicleList('');
            });
          },
        ),
      ));
    });
    return chips;
  }

  bool isSubsequence(str1, str2) {
    int i = 0;
    int j = 0;
    while (i < str1.length) {
      if (j == str2.length) {
        return false;
      }
      if (str1[i] == str2[j]) {
        i++;
      }
      j++;
    }
    return true;
  }

  List<Widget> getVehicleList(query) {
    List<Widget> list = [];
    productRepo.forEach((element) {
      if (vehicleTypes[element['criteria'].toString().toUpperCase()] == true) {
        final searchText =
            element['criteria'].toLowerCase() + element['model'].toLowerCase();
        query = query.toLowerCase();
        if (isSubsequence(query, searchText)) {
          Widget item = Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: MediaQuery.of(context).size.height / 2.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 3.5,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: element['productImages'] != null &&
                                    element['productImages'].isNotEmpty
                                ? Image.network(
                                    element['productImages'][0],
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.image_not_supported_sharp),
                          ),
                        ),
                        if (element['rentPerHour'] != null)
                          Positioned(
                            bottom: 20.0,
                            child: Container(
                              height: 35,
                              width: 80,
                              child: Center(
                                child: Text(
                                  '\u20B9${element['rentPerHour']} / hr',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: MyColors.primaryColor,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      element['model'].toString().toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        element['criteria']
                                            .toString()
                                            .toUpperCase(),
                                      ),
                                      Text(' : '),
                                      Text(
                                        element['licencePlate'] != null &&
                                                element['licencePlate']
                                                    .isNotEmpty
                                            ? element['licencePlate']
                                            : 'NA',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddVehiclesTab(
                                              changeTab: widget.changeTab,
                                              repo: element,
                                              onStateChange:
                                                  widget.onStateChange),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  height: 30,
                                  width: 100,
                                  child: Center(
                                    child: Text(
                                      'EDIT',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: MyColors.primaryColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Rent --> '),
                              Text(
                                '\u20B9${element['rentPerHour']} / hr',
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Text(
                                    '\u20B9${element['rentPerDay']} / day'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          list.add(item);
        }
      }
    });
    setState(() {
      children = list;
    });
    return list;
  }

  _onSearchChanged(String query) {
    if (_debounce != null && _debounce.isActive) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() {
          showCancelButton = false;
        });
      } else {
        setState(() {
          showCancelButton = true;
        });
      }
      getVehicleList(query);
    });
  }
}
