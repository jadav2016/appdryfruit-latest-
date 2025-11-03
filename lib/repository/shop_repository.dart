// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as l;
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rjfruits/model/shop_model.dart';
import 'package:http/http.dart' as http;
import 'package:rjfruits/res/app_url.dart';
import 'package:rjfruits/res/const/response_handler.dart';
import 'package:rjfruits/utils/routes/utils.dart';

import '../model/cart_model.dart';

class ShopRepository extends ChangeNotifier {
  List<Shop> shopProducts = [];
  List<Shop> searchResults = [];
  List<Shop> tempShopProducts = [];
  List<Shop> filteredProducts = [];
  List<Shop> tempFilteredProducts = [];
  int productLength = 0;
  bool isLoading = false;
  Timer? debounce;

  Future<void> getShopProd(BuildContext context) async {
    isLoading = true;


    try {

      final response = await http.get(
        Uri.parse(AppUrl.shop),
        headers: {
          'accept': 'application/json',
          'X-CSRFToken':
          'umFU4LBxVgOwgYL6jgTynbGicCd47wKL9otbehTcDRm1k08P7hTmBOzW0wjCwXy1',
        },
      );
      l.log('Response===>${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        final List<Shop> shops = jsonResponse.map((e) => Shop.fromJson(e)).toList();
        productLength = shops.length;
      // Store a copy of the full list

// 1. Separate Dry Fruits (Case-Insensitive)
        List<Shop> dryFruits = shops
            .where((p) => p.category.name.toLowerCase() == "dry fruit")
            .toList();

// 2. Get Other Products
        List<Shop> others = shops
            .where((p) => p.category.name.toLowerCase() != "dry fruit")
            .toList();

// 3. Shuffle the Other Products
        others.shuffle(Random());

// 4. Combine Dry Fruits First, Then Shuffled Others
        shopProducts = [...dryFruits, ...others];
        tempFilteredProducts= shopProducts;

// 5. Log the First Product for Debugging
//         l.log('Response===> ${shopProducts.isNotEmpty ? shopProducts[0].category.name : "No Products"}');
        tempShopProducts = List.from(shopProducts);


// 6. Take 20 Items from the Sorted List
        List<Shop> newItems = tempShopProducts.take(20).toList();

// 7. Assign Only the First 20 Items
        shopProducts = newItems;

// 8. Remove Added Items from tempShopProducts
        if (tempShopProducts.length >= 20) {
          tempShopProducts.removeRange(0, 20);
        } else {
          tempShopProducts.clear();
        }

// 9. Notify UI About Changes
        notifyListeners();

      //   final List<dynamic> jsonResponse = json.decode(response.body);
      //   final List<Shop> shops =
      //   jsonResponse.map((e) => Shop.fromJson(e)).toList();
      //   productLength = shops.length;
      //   tempShopProducts = shops;
      //   shopProducts.clear(); // Clear the existing list
      //
      //   // 1. Filter Dry Fruits (Convert both values to lowercase)
      //   List<Shop> dryFruits = shopProducts
      //       .where((p) => p.category.name.toLowerCase() == "dry fruit")
      //       .toList();
      //
      //   // 2. Get Remaining Products
      //   List<Shop> others = shopProducts
      //       .where((p) => p.category.name.toLowerCase() != "dry fruit")
      //       .toList();
      //
      //   // 3. Shuffle the "others" list
      //   others.shuffle(Random());
      //
      //   // 4. Combine Dry Fruits first, then shuffled others
      //   shopProducts = [...dryFruits, ...others];
      //   l.log('Response===>${shopProducts[0].category.name}');
      //
      //   shopProducts.addAll(tempShopProducts.take(20)); // Add the new items
      //   // 1. Separate Dry Fruits
      //
      //
      //   if (tempShopProducts.length >= 20) {
      //     tempShopProducts.removeRange(0, 20);
      //   } else {
      //     tempShopProducts.removeRange(0, shopProducts.length);
      //   }
      //   notifyListeners();
      // } else {
      //   if (response.statusCode == 404) {
      //     Utils.flushBarErrorMessage("Products not found", context);
      //   } else {
      //     Utils.flushBarErrorMessage("Unexpected error", context);
      //   }
      }
      notifyListeners();
    } catch (e) {
      handleApiError(e, context);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }








  //
  // @override
  // void dispose() {
  //   scrollController.dispose();
  //   super.dispose();
  // }


  void filterProducts(
      String? category,
      double? minRating,
      double? minPrice,
      double? maxPrice,
      int? discountPer,
      ) {
    try {
      l.log('category==1$category');
      l.log('minRating==2$minRating');
      l.log('minPrice==3$minPrice');
      l.log('maxPrice==4$maxPrice');
      l.log('discountPer===5$discountPer');
      filteredProducts.clear();

      filteredProducts.addAll(tempFilteredProducts.where((product) {

        // Category Filter
        bool categoryFilter = category == null ||
            (product.category?.name?.toLowerCase().contains(category.toLowerCase()) ?? false);

        // Price Filter
        double price = double.parse(product.price)  ?? 0.0;  // Ensure price is not null
        bool priceFilter = (minPrice == null || price >= minPrice) &&
            (maxPrice == null || price <= maxPrice);

        // Discount Filter
        bool discountFilter = discountPer == null ||
            (product.discount ?? 0) >= discountPer;

        // Return products matching all conditions
        return categoryFilter && priceFilter && discountFilter;

      }));



      l.log('Enter11=+${filteredProducts.length}');

    } catch (e) {
      print('Error filtering products: $e');



  // void filterProducts(String? category, double? minRating, double? minPrice,
  //     double? maxPrice, int? discountPer) {
  //   try {
  //     filteredProducts.clear();
  //
  //
  //
  //     for (var product in shopProducts) {
  //
  //
  //       if (category != null && (product.category.name.toLowerCase().contains(category.toLowerCase()))) {
  //
  //       }
  //
  //
  //
  //       // filteredProducts.addAll(productList.where((product) {
  //       //   bool categoryFilter = category == null ||
  //       //       (product.category?.name?.toLowerCase().contains(category.toLowerCase()) ?? false);
  //       //
        //   bool priceFilter = (minPrice == null || (product.price ?? 0) >= minPrice) &&
        //       (maxPrice == null || (product.price ?? 0) <= maxPrice);
  //       //
  //       //   bool discountFilter = discountPer == null || (product.discount ?? 0) >= discountPer;
  //       //
  //       //   return categoryFilter && discountFilter && priceFilter;
  //       // }));
  //
  //     }

      notifyListeners();
    }

  }


  void _isolateSearch(List<dynamic> args) {
    List<Shop> products = args[0] as List<Shop>;
    String searchTerm = args[1] as String;
    SendPort sendPort = args[2] as SendPort;

    // Perform the search in the isolate
    List<Shop> results = products
        .where((product) =>
        product.title.toLowerCase().contains(searchTerm))
        .toList();

    // Send the result back to the main isolate
    sendPort.send(results);
    notifyListeners();
  }
  void search(String searchTerm) async{
    if (searchTerm.isEmpty) {
      searchResults = List.from(shopProducts);  // Reset to full list if empty
    } else {
      final lowerCaseTerm = searchTerm.toLowerCase();

      // // Use efficient filtering with .where()
      // searchResults = tempShopProducts.where((product) =>
      //     product.title.toLowerCase().contains(lowerCaseTerm)).toList();

      // Create a port to receive messages from the isolate
      final receivePort = ReceivePort();

      await Isolate.spawn(_isolateSearch, [tempFilteredProducts, lowerCaseTerm, receivePort.sendPort]);

      // Listen to the result from the isolate
      receivePort.listen((dynamic message) {
        if (message is List<Shop>) {
          searchResults = message;

          notifyListeners();
          receivePort.close();
        }
      });

    }
  }

}
