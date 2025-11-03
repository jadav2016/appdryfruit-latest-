import 'dart:convert';
import 'dart:developer';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rjfruits/model/user_model.dart';
import 'package:rjfruits/repository/home_repository.dart';
import 'package:rjfruits/utils/routes/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel with ChangeNotifier {
  Map userData = {};
  final HomeRepository _homeRepository = HomeRepository();
  bool _isLoading = false;
  List<Map<String, dynamic>> _addresses = [];
  Map<String, dynamic>? _selectedAddress;
  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> states = [];
  bool _isFetchState = false;
  bool get isFetchState => _isFetchState;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get addresses => _addresses;
  Map<String, dynamic>? get selectedAddress => _selectedAddress;

  clearStates() {
    states = [];
    notifyListeners();
  }

  Future<void> fetchCountries() async {
    _isLoading = true;
    countries = [];
    notifyListeners();
    try {
      final userModel = await getUser();
      final token = userModel.key;
      final response = await http.get(
        Uri.parse(
            'https://rajasthandryfruitshouse.com/api/placeapi/countries/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      if (response.statusCode == 200) {
        print(response.body);
        countries = List<Map<String, dynamic>>.from(json.decode(response.body));
      }
    } catch (e) {
      Utils.toastMessage('Error Occurred: ${e.toString()}');
    }
    _isLoading = false;
    notifyListeners(); // Notify UI to update state
  }

  Future<void> fetchStates(int id) async {
    _isFetchState = true;
    states = [];
    notifyListeners();
    try {
      final userModel = await getUser();
      final token = userModel.key;
      final response = await http.get(
        Uri.parse(
            'https://rajasthandryfruitshouse.com/api/placeapi/regions/?country_id=$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      if (response.statusCode == 200) {
        print(response.body);
        states = List<Map<String, dynamic>>.from(
            json.decode(response.body)['regions']);
        print(states);
      }
    } catch (e) {
      Utils.toastMessage('Error Occurred: ${e.toString()}');
    }
    _isFetchState = false;
    notifyListeners(); // Notify UI to update state
  }

  Future<void> fetchAddresses(BuildContext context) async {
    _isLoading = true;
    notifyListeners(); // Notify UI to show loading state
    try {
      final userModel = await getUser();
      final token = userModel.key;
      final response = await http.get(
        Uri.parse('https://rajasthandryfruitshouse.com/api/address/'),
        headers: {
          'Accept': 'application/json',
          'X-CSRFToken':
              'SlSrUKA34Wtxgek0vbx9jfpCcTylfy7BjN8KqtVw38sdWYy7MS5IQdW1nKzKAOLj',
          'authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        _addresses =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        if (_addresses.isNotEmpty) {
          _selectedAddress = _addresses[0]; // Select first address
        }
      } else {
        Utils.flushBarErrorMessage('Failed to load addresses', context);
      }
    } catch (e) {
      Utils.toastMessage('Error Occurred: ${e.toString()}');
    }

    _isLoading = false;
    notifyListeners(); // Notify UI to update state
  }

  UserModel? user;
  Future<bool> saveUser(UserModel user) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    print(user.key);
    await sp.setString('key', user.key); // Ensure this call is awaited
    notifyListeners();
    return true;
  }

  Future<void> getAppData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String? token = sp.getString('key');
    user = UserModel(key: token ?? '');
    token = user!.key;
    final Map<String, dynamic> data = await _homeRepository.getUserData(token);
    userData = data;
    fetchCountries();
    notifyListeners();
  }

  Future<UserModel> getUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String? token = sp.getString('key');
    user = UserModel(key: token ?? '');
    return UserModel(key: token ?? '');
  }

  Future<bool> removerUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.remove('key');
  }


  static const String _countKey = 'notification_count';

  // Get current count
   Future<int> getCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_countKey) ?? 0;
  }

  // Increment count
   Future<void> incrementCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = await getCount();
    await prefs.setInt(_countKey, currentCount + 1);

    await FlutterNewBadger.setBadge(currentCount + 1); // Shows '5' on app icon

// Remove badge

log('Current Count===>$currentCount');
    notifyListeners();
  }

  // Reset count
   Future<void> resetCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, 0);
    await FlutterNewBadger.removeBadge();

    notifyListeners();
  }

  // Decrement count
   Future<void> decrementCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = await getCount();
    if (currentCount > 0) {
      await prefs.setInt(_countKey, currentCount - 1);
    }
    notifyListeners();
  }


}
