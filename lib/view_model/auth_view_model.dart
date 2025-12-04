// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/res/app_url.dart';
import 'package:rjfruits/view_model/user_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import '../utils/routes/routes_name.dart';
import '../utils/routes/utils.dart';

class AuthViewModel with ChangeNotifier {
  // final _myRepo = AuthRepository();

  bool get isloading => _isLoading;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _signupLoading = false;
  bool get signupLoading => _signupLoading;

  void setSignUpLaoding(bool value) {
    _signupLoading = value;
    notifyListeners();
  }

  bool _isLoading = false;

  Future<void> loginApi(dynamic data, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    log('Working');
    try {
      final dio = Dio();

      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRFToken':
            ' XjM64o8umW9Tog5kpUyPTyZg3hW4OoXupvilLAmzvFfATCjQrBGe2cN89tPjxsKm',
      };

      final response = await dio.post(
        AppUrl.loginEndPoint,
        options: Options(headers: headers),
        data: data,
      );

      _isLoading = false;
      Utils.toastMessage('Successfully Logged In');
      await SessionManager.setLoggedIn(true);

      final userPreferences =
          Provider.of<UserViewModel>(context, listen: false);
      userPreferences.saveUser(UserModel(key: response.data['key'].toString()));

      Navigator.pushNamedAndRemoveUntil(
          context, RoutesName.dashboard, (route) => false);

      if (kDebugMode) {
        debugPrint('Login Success: ${response.data}');
      }
    } on DioError catch (error) {
      _isLoading = false;

      String errorMessage = 'An error occurred';

      if (error.response != null && error.response?.data != null) {
        final data = error.response?.data;

        // Handle the "non_field_errors" case
        if (data is Map && data.containsKey('non_field_errors')) {
          final errors = data['non_field_errors'];
          if (errors is List && errors.isNotEmpty) {
            errorMessage = errors.first.toString();
          }
        }
        // Handle other possible message formats
        else if (data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        }
      }

      Utils.flushBarErrorMessage(errorMessage, context);

      if (kDebugMode) {
        debugPrint('DioError: ${error.response?.data ?? error.message}');
      }
    } catch (error) {
      _isLoading = false;

      // Catch Unexpected Errors
      Utils.flushBarErrorMessage('An unexpected error occurred.', context);
      if (kDebugMode) {
        debugPrint('Unexpected Error: $error');
      }
    } finally {
      // Ensure Loading State Reset
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerDevice(dynamic data, BuildContext context) async {
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    final userModel = await userPreferences.getUser();
    final token = userModel.key;

    _isLoading = true;
    notifyListeners();

    try {
      final dio = Dio();

      final headers = {
        'authorization': 'Token $token',
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRFToken':
            'XjM64o8umW9Tog5kpUyPTyZg3hW4OoXupvilLAmzvFfATCjQrBGe2cN89tPjxsKm',
      };

      log('headers $headers');
      log('Data11111 $data');
      log('URL ${AppUrl.registerDevice}');

      final response = await dio.post(
        AppUrl.registerDevice,
        options: Options(headers: headers),
        data: data,
      );
      log('Token send Success${response.toString()}');
    } on DioError catch (error) {
      if (kDebugMode) {
        debugPrint('DioError001: ${error.response?.data ?? error.message}');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Unexpected Error: $error');
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> signUpApi(Map<String, String> data, BuildContext context) async {
    _isLoading = true;
    try {
      final dio = Dio();
      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRFToken':
            ' XjM64o8umW9Tog5kpUyPTyZg3hW4OoXupvilLAmzvFfATCjQrBGe2cN89tPjxsKm',
      };

      debugPrint("SignUp API Input Data: $data");
      debugPrint("SignUp API Header: $headers");
      debugPrint("SignUp API Enpoint: ${AppUrl.registerEndPoint}");

      final response = await dio.post(
        AppUrl.registerEndPoint,
        options: Options(headers: headers),
        data: data,
      );

      debugPrint("SignUp API Response: ${response.data}");

      _isLoading = false;
      Utils.toastMessage('Successfully Registered');
      Navigator.pushNamedAndRemoveUntil(
          context, RoutesName.login, (route) => false);

      if (kDebugMode) {
        print(response.toString());
      }
    } on DioError catch (error) {
      if (error.response != null) {
        debugPrint('Error Response Data: ${error.response?.data}');
        debugPrint('Error Response Headers: ${error.response?.headers}');
        debugPrint('Error Response Status: ${error.response?.statusCode}');
      } else {
        debugPrint('Error Message: ${error.message}');
      }
      Utils.flushBarErrorMessage(handleError(error), context);
    } catch (error) {
      Utils.flushBarErrorMessage(
          'An unexpected error occurred: $error.', context);
      _isLoading = false;
    }
  }

  String handleError(DioError error) {
    if (error.response != null && error.response?.data != null) {
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final errorMessages = responseData.entries
            .map((entry) {
              final key = entry.key;
              final value = entry.value;

              if (value is List) {
                return "$key: ${value.join(", ")}";
              } else if (value is String) {
                return "$key: $value";
              }
              return null;
            })
            .where((message) => message != null)
            .join("\n");

        if (errorMessages.isNotEmpty) {
          return errorMessages;
        }
      }

      return "An error occurred: ${error.response?.statusMessage ?? 'Unknown error'}";
    }

    switch (error.type) {
      case DioErrorType.connectionTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioErrorType.badResponse:
        return 'Invalid credentials.';
      case DioErrorType.cancel:
        return 'Request cancelled.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}

class SessionManager {
  static const _keyLoggedIn = 'isLoggedIn';

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);
  }
}
