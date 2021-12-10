import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_my_ride_partners_1/screens/offlinePage.dart';
import 'package:get_my_ride_partners_1/screens/verification/checkNumber.dart';
import 'package:http/http.dart' as http;

class AllApis {
  static const String base_url = 'https://madhuram-marketapis.herokuapp.com';
  static var staticContext;
  static var staticPage;

  Future<dynamic> sentOtp({phoneNumber}) async {
    try {
      Uri uri =
          Uri.parse('$base_url/verification/sendOtp?phoneNumber=$phoneNumber');
      final header = {
        'Content-Type': 'application/json',
      };
      http.Response response = await http.get(uri, headers: header);
      if (response.statusCode == 500) {
        navigate();
        return null;
      }
      return response;
    } catch (e) {
      navigate();
      return null;
    }
  }

  Future<dynamic> verifyOtp({phoneNumber, otp}) async {
    try {
      Uri uri = Uri.parse('$base_url/verification/verifyOtp');
      final header = {
        'Content-Type': 'application/json',
      };
      final body = json.encode({
        "phoneNumber": phoneNumber,
        "otp": otp,
      });
      http.Response response =
          await http.post(uri, headers: header, body: body);
      if (response.statusCode == 500) {
        navigate();
        return null;
      }
      return response;
    } catch (e) {
      navigate();
      return null;
    }
  }

  Future<dynamic> getStoresByPhone({token}) async {
    try {
      Uri uri = Uri.parse('$base_url/stores/getStoresByPhone');
      final header = {
        'Authorization': token.toString(),
        'Content-Type': 'application/json',
      };
      http.Response response = await http.get(uri, headers: header);
      if (response.statusCode == 500) {
        navigate();
        return null;
      } else if (response.statusCode == 401) {
        authenticate();
        return null;
      }
      return response;
    } catch (e) {
      navigate();
      return null;
    }
  }

  Future<dynamic> getStoresById({@required token, @required storeId}) async {
    try {
      Uri uri = Uri.parse('$base_url/stores/getStoreById?storeId=$storeId');
      final header = {
        'Authorization': token.toString(),
        'Content-Type': 'application/json',
      };
      http.Response response = await http.get(uri, headers: header);
      if (response.statusCode == 500) {
        navigate();
        return null;
      } else if (response.statusCode == 401) {
        authenticate();
        return null;
      }
      return response;
    } catch (e) {
      navigate();
      return null;
    }
  }

  Future<dynamic> getProductsOfStore(
      {@required token, @required storeId}) async {
    try {
      Uri uri =
          Uri.parse('$base_url/products/getProductsOfStore?storeId=$storeId');
      final header = {
        'Authorization': token.toString(),
        'Content-Type': 'application/json',
      };
      http.Response response = await http.get(uri, headers: header);
      if (response.statusCode == 500) {
        navigate();
        return null;
      } else if (response.statusCode == 401) {
        authenticate();
        return null;
      }
      return response;
    } catch (e) {
      navigate();
      return null;
    }
  }

  Future<dynamic> deleteProductById(
      {@required token, @required productId}) async {
    try {
      Uri uri = Uri.parse('$base_url/products/deleteProduct?id=$productId');
      final header = {
        'Authorization': token.toString(),
        'Content-Type': 'application/json',
      };
      http.Response response = await http.delete(uri, headers: header);
      if (response.statusCode == 500) {
        navigate();
        return null;
      } else if (response.statusCode == 401) {
        authenticate();
        return null;
      }
      return response;
    } catch (e) {
      navigate();
      return null;
    }
  }

  Future<dynamic> addOrUpdateProductToStore({
    @required token,
    @required storeId,
    @required file,
    @required model,
    @required licencePlate,
    @required rentPerHour,
    @required rentPerDay,
    @required criteria,
    isUpdating = false,
    id,
  }) async {
    try {
      var headers = {
        'Authorization': token.toString(),
      };
      String path = 'createProduct';
      String method = 'POST';
      if (isUpdating) {
        method = 'PATCH';
        path = 'updateProduct?id=$id';
      }
      var request =
          http.MultipartRequest(method, Uri.parse('$base_url/products/$path'));
      request.fields.addAll(
        {
          'store': storeId,
          'model': model,
          'licencePlate': licencePlate,
          'rentPerHour': rentPerHour,
          'rentPerDay': rentPerDay,
          'criteria': criteria,
        },
      );
      if (file != null) {
        var pic = await http.MultipartFile.fromPath("productImages", file.path);
        request.files.add(pic);
      }

      request.headers.addAll(headers);

      http.StreamedResponse responseStream = await request.send();
      final response = await http.Response.fromStream(responseStream);

      if (response.statusCode == 200) {
        return response;
      }
      if (response.statusCode == 500) {
        navigate();
        return null;
      } else if (response.statusCode == 401) {
        authenticate();
        return null;
      }
      return response;
    } catch (e) {
      navigate();
      return null;
    }
  }

  Future<dynamic> createNewStore(
      {@required token,
      @required address,
      @required file,
      @required storeName,
      @required latitude,
      @required longitude,
      @required phoneNumber}) async {
    try {
      var headers = {
        'Authorization': token.toString(),
      };
      var request = http.MultipartRequest(
          'POST', Uri.parse('$base_url/stores/createStore'));
      request.fields.addAll(
        {
          'storeName': storeName,
          'pinCode': address.postalCode,
          'city': address.locality,
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'address':
              '${address.name} ${address.postalCode} ${address.locality}',
          'phoneNumber': phoneNumber,
        },
      );
      if (file != null) {
        var pic = await http.MultipartFile.fromPath("storeImage", file.path);
        request.files.add(pic);
      }

      request.headers.addAll(headers);

      http.StreamedResponse responseStream = await request.send();
      final response = await http.Response.fromStream(responseStream);

      if (response.statusCode == 200) {
        return response;
      }
      if (response.statusCode == 500) {
        navigate();
        return null;
      } else if (response.statusCode == 401) {
        authenticate();
        return null;
      }
      return response;
    } catch (e) {
      navigate();
      return null;
    }
  }

  Future<dynamic> updateStore({
    @required token,
    @required storeId,
    @required updateObject,
    @required file,
  }) async {
    try {
      var headers = {
        'Authorization': token.toString(),
      };
      var request = http.MultipartRequest(
          'PATCH', Uri.parse('$base_url/stores/updateStore?id=$storeId'));
      request.fields.addAll(updateObject);
      if (file != null) {
        var pic = await http.MultipartFile.fromPath("storeImage", file.path);
        request.files.add(pic);
      }

      request.headers.addAll(headers);

      http.StreamedResponse responseStream = await request.send();
      final response = await http.Response.fromStream(responseStream);
      if (response.statusCode == 200) {
        return response;
      }
      if (response.statusCode == 500) {
        navigate();
        return null;
      } else if (response.statusCode == 401) {
        authenticate();
        return null;
      }
      return response;
    } catch (e) {
      navigate();
      return null;
    }
  }

  void navigate() {
    Navigator.pushReplacement(
      staticContext,
      MaterialPageRoute(
        builder: (context) => OfflinePage(comingFrom: staticPage),
      ),
    );
  }

  void authenticate() {
    Navigator.pushAndRemoveUntil(
      staticContext,
      MaterialPageRoute(builder: (context) => CheckNumber()),
      (route) => false,
    );
  }
}
