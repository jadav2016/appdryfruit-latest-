// ignore_for_file: prefer_final_fields

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rjfruits/repository/shop_repository.dart';

class ShopRepositoryProvider extends ChangeNotifier {
  ShopRepository _shopRepository = ShopRepository();


  ShopRepository get shopRepository => _shopRepository;

  Future<void> getShopProd(BuildContext context) async {
    await _shopRepository.getShopProd(context);
    notifyListeners();
  }

  void filterProducts(
      String? categrio,
      double? mixRating,
      double? minPrice,
      double? maxPrice,
      int? discountPer,
      ) {
    _shopRepository.filterProducts(
      categrio,
      mixRating,
      minPrice,
      maxPrice,
      discountPer,
    );
    notifyListeners();
  }

  void search(
    String searchTerm,
  ) {
    _shopRepository.search(
      searchTerm,
    );
    notifyListeners();
  }
}
