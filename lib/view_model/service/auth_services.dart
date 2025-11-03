// ignore_for_file: use_build_context_synchronously

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rjfruits/utils/routes/utils.dart';

import '../../utils/routes/routes_name.dart';
import '../user_view_model.dart';
import 'package:rjfruits/utils/routes/routes_name.dart';
import 'package:rjfruits/view_model/user_view_model.dart';

import '../../model/user_model.dart';
import 'package:flutter/foundation.dart';

import 'dart:convert';

class AuthService {
  /*Bool isLogined(BuildContext context) {
    Future<UserModel> getUserData() => UserViewModel().getUser();
    getUserData().then((value) {
      if (value.key.isEmpty || value.key == '') {
        return false;
      } else {
        return true;
      }
    }).onError((error, stackTrace) {
      return false;
    });
  }*/

  Future<void> logout(BuildContext context) async {
    try {
      final userPreferences =
          Provider.of<UserViewModel>(context, listen: false);
      final userModel = await userPreferences.getUser();
      final token = userModel.key;

      final response = await http.post(
        Uri.parse('https://rajasthandryfruitshouse.com/rest-auth/logout/'),
        headers: {
          'accept': 'application/json',
          'authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        Utils.toastMessage('Successfully Logout');
        userPreferences.removerUser();
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.login, // Update this if your login route is named differently
              (Route<dynamic> route) => false,
        );
      } else {
        Utils.toastMessage('Logout Failed');
        //Workaround to go around server issues
        userPreferences.removerUser();
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.login, // Update this if your login route is named differently
              (Route<dynamic> route) => false,
        );
        //debugPrint("failed logout: $token => ${response.statusCode}");
      }
    } catch (e) {
      Utils.toastMessage('Error during logout: $e');
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    /*try {
      final userPreferences =
          Provider.of<UserViewModel>(context, listen: false);
      final userModel = await userPreferences.getUser();
      final token = userModel.key;

      final url =
          Uri.parse('https://rajasthandryfruitshouse.com/api/delete-account/');
      final request = http.Request("DELETE", url);
      request.headers.addAll(<String, String>{
        'Accept': 'application/json',
        'Authorization': 'Token $token',
      });
      //request.body = jsonEncode({"username": 4});
      final response = await request.send();
      /*if (response.statusCode != 200)
        return Future.error("error: status code ${response.statusCode}");
      return await response.stream.bytesToString();*/
      if (response.statusCode == 200) {
        Utils.toastMessage('Deletion Request Sent');
        userPreferences.removerUser();
        Navigator.pushNamed(context, RoutesName.login);
      } else {
        Utils.toastMessage('Deletion Failed');
        debugPrint("failed deletion:${response.statusCode}");
      }
    } catch (e) {
      Utils.toastMessage('Error during deletion: $e');
    }*/

    try {
      final userPreferences =
          Provider.of<UserViewModel>(context, listen: false);
      final userModel = await userPreferences.getUser();
      final token = userModel.key;

      final response = await http.post(
        Uri.parse('https://rajasthandryfruitshouse.com/api/delete-account/'),
        headers: {
          'accept': 'application/json',
          'authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Utils.toastMessage('Deletion Request Sent');
        userPreferences.removerUser();
        Navigator.pushNamed(context, RoutesName.login);
      } else {
        Utils.toastMessage('Deletion Failed');
        debugPrint("failed deletion: $token => ${response.statusCode}");
      }
    } catch (e) {
      Utils.toastMessage('Error during deletion: $e');
    }
  }
}
