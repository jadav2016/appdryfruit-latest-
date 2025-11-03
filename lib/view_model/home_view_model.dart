import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rjfruits/model/home_model.dart';
import 'package:rjfruits/repository/home_repository.dart';
import 'dart:io' show File;

class HomeRepositoryProvider extends ChangeNotifier {
  final HomeRepository _homeRepository = HomeRepository();

  HomeRepository get homeRepository => _homeRepository;

  Future<void> getHomeProd(BuildContext context) async {
    await _homeRepository.getHomeProd(context);
    notifyListeners();
  }

  Future<void> getShopProd(BuildContext context) async {
    await _homeRepository.getShopProd(context);
    notifyListeners();
  }

  String calculateDiscountedPrice(double originalPrice, double discount) {
    String discountedPrice =
        _homeRepository.calculateDiscountedPrice(originalPrice, discount);
    notifyListeners();
    return discountedPrice;
  }

  void searchCategoriesProduct(String value) {
    print('filter categories ${value}');
    _homeRepository.searchCategoriesByProduct(value);

    notifyListeners();
  }

  void search(
    String searchTerm,
    List<Product> produtTopRated,
    List<Product> productsFeature,
    List<Product> productsTopDiscount,
  ) {
    _homeRepository.search(
      searchTerm,
      produtTopRated,
      productsTopDiscount,
      productsFeature,
    );
    notifyListeners();
  }

  Future categoryFilter(
    String categrio,
  ) async {
    // log('categrio${categrio}');

    _homeRepository.categoryFilter(categrio);
    notifyListeners();
  }

  void filterProducts(
    String? categrio,
    double? mixRating,
    double? minPrice,
    double? maxPrice,
    int? discountPer,
  ) {
    _homeRepository.filterProducts(
      categrio,
      mixRating,
      minPrice,
      maxPrice,
      discountPer,
    );
    notifyListeners();
  }

  Future<Map<String, dynamic>> getUserData(String token) async {
    final Map<String, dynamic> data = await _homeRepository.getUserData(token);
    notifyListeners();

    return data;
  }

  void updateUserData(
    String firstName,
    String lastName,
    String token,
    BuildContext context, {
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    File? profileImage,
  }) {
    _homeRepository.updateUserProfile(
      token,
      firstName,
      lastName,
      context,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      gender: gender,
      profileImage: profileImage,
    );
    notifyListeners();
  }
}
