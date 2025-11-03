// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:convert';
import 'dart:developer'as d;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rjfruits/model/home_model.dart';
import 'package:rjfruits/res/app_url.dart';
import 'package:rjfruits/res/components/colors.dart';
import 'package:rjfruits/res/const/response_handler.dart';
import 'package:http/http.dart' as http;
import 'package:rjfruits/view/dashBoard/dashboard.dart';
import 'dart:io' show File;
import 'package:dio/dio.dart';

import '../model/shop_model.dart' as shop;
import '../utils/routes/utils.dart';

class HomeRepository extends ChangeNotifier {
  List<Category> productCategories = [];
  List<Product> sliderList = [];
  List<Product> productsTopDiscount = [];
  List<Product> productsTopOrder = [];
  List<Product> productsTopRated = [];
  List<Week> productsBestWeek = [];
  List<Product> searchResults = [];

  List<shop.Shop> categriousProduct = [];
  List<Product> filteredProducts = [];
  List<Product> offerProducts = [];
  List<Product> festivalSpecial = [];
  List<shop.Shop> shopProducts = [];
  List<shop.Shop> dummySearchResults = [];
  List<shop.Shop> tempAllProducts = [];

  Future<void> getHomeProd(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse(AppUrl.home),
        headers: {
          'accept': 'application/json',
          'X-CSRFToken':
              'umFU4LBxVgOwgYL6jgTynbGicCd47wKL9otbehTcDRm1k08P7hTmBOzW0wjCwXy1',
        },
      );

      debugPrint("Response status code: ${response.statusCode}");
      debugPrint("AppUrl.home: ${AppUrl.home}");
    d.  log("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        // log('Response==> ${jsonEncode(jsonResponse)}');
        ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);

        productCategories = apiResponse.categories;
        productsTopDiscount = apiResponse.topDiscountedProducts;
        productsTopOrder = apiResponse.newProducts;
        productsTopRated = apiResponse.mostSales;
        productsBestWeek = apiResponse.week;
        
        sliderList = apiResponse.slideList;
        offerProducts = apiResponse.offerProducts;
        festivalSpecial = apiResponse.festivalSpecialList;

        if (productsTopOrder.isNotEmpty) {
          productsTopOrder.sort((a, b) => a.id.compareTo(b.id));
        }
        if (productCategories.isNotEmpty) {
          productCategories.sort((a, b) => a.id.compareTo(b.id));
        }

        notifyListeners();
      } else {
        debugPrint("Error: Unexpected status code ${response.statusCode}");

        if (response.statusCode == 404) {
          debugPrint("Error: Products not found (404)");
          // Utils.flushBarErrorMessage("Products not found", context);
        } else {
          debugPrint("Error: Unexpected error occurreds");
          // Utils.flushBarErrorMessage("Unexpected error", context);
        }
      }
    } catch (e, stackTrace) {
      // Detailed debug output for exceptions
      debugPrint("Exception occurred: $e");
      debugPrint("Stack trace: $stackTrace");

      // Handle API error (custom error handler)
      handleApiError(e, context);
    }
  }

  Future<void> getShopProd(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse(AppUrl.shop),
        headers: {
          'accept': 'application/json',
          'X-CSRFToken':
              'umFU4LBxVgOwgYL6jgTynbGicCd47wKL9otbehTcDRm1k08P7hTmBOzW0wjCwXy1',
        },
      );
      // log('Response===> product ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        final List<shop.Shop> shops =
            jsonResponse.map((e) => shop.Shop.fromJson(e)).toList();
        // Store a copy of the full list

// 1. Separate Dry Fruits (Case-Insensitive)
        List<shop.Shop> dryFruits = shops
            .where((p) => p.category.name.toLowerCase() == "dry fruit")
            .toList();

// 2. Get Other Products
        List<shop.Shop> others = shops
            .where((p) => p.category.name.toLowerCase() != "dry fruit")
            .toList();

// 3. Shuffle the Other Products
        others.shuffle(Random());

// 4. Combine Dry Fruits First, Then Shuffled Others
        shopProducts = [...dryFruits, ...others];
        tempAllProducts = shopProducts;
      }
      notifyListeners();
    } catch (e) {
      handleApiError(e, context);
    } finally {}
  }

  void searchCategoriesByProduct(String value) {
    if (value.isNotEmpty) {
      final filteredResults = dummySearchResults.where((item) {
        return item.title.toLowerCase().contains(value.toLowerCase());
      }).toList();
      debugPrint("search by categories trigger");
      categriousProduct = filteredResults;
    } else {
      categriousProduct = dummySearchResults;
    }

    notifyListeners();
  }

  String calculateDiscountedPrice(
      double originalPrice, double discountPercentage) {
    double discountedPrice =
        originalPrice - (originalPrice * (discountPercentage / 100));
    return discountedPrice.toStringAsFixed(2);
  }

  void search(
    String searchTerm,
    List<Product> productsNew,
    List<Product> productsTopDiscount,
    List<Product> productsTopOrder,
  ) {
    searchResults.clear();

    for (var product in productsTopRated) {
      if (product.title.toLowerCase().contains(searchTerm.toLowerCase())) {
        searchResults.add(product);
      }
    }

    for (var product in productsTopDiscount) {
      if (product.title.toLowerCase().contains(searchTerm.toLowerCase())) {
        searchResults.add(product);
      }
    }

    for (var product in productsTopOrder) {
      if (product.title.toLowerCase().contains(searchTerm.toLowerCase())) {
        searchResults.add(product);
      }
    }
    if (searchResults.isNotEmpty) {
      notifyListeners();
    }
  }

  void categoryFilter(String category) {
    categriousProduct.clear();

    //
    for (var product in tempAllProducts) {
      if (product.category.name
              .toLowerCase()
              .contains(category.toLowerCase()) ??
          false) {
        categriousProduct.add(product);
      }
    }
    // //
    // for (var product in productsTopRated) {
    //   if (product.category?.name
    //           ?.toLowerCase()
    //           .contains(category.toLowerCase()) ??
    //       false) {
    //     categriousProduct.add(product);
    //   }
    // }
    // for (var product in productsTopOrder) {
    //   if (product.category?.name
    //           ?.toLowerCase()
    //           .contains(category.toLowerCase()) ??
    //       false) {
    //     categriousProduct.add(product);
    //   }
    // }

    dummySearchResults = categriousProduct;
    if (categriousProduct.isNotEmpty) {
      notifyListeners();
    }
  }

  void filterProducts(String? category, double? minRating, double? minPrice,
      double? maxPrice, int? discountPer) {
    try {
      filteredProducts.clear();

      List<List<Product>> productLists = [
        productsTopRated,
        productsTopDiscount,
        productsTopOrder,
      ];

      for (var productList in productLists) {
        filteredProducts.addAll(productList.where((product) {
          bool categoryFilter = category == null ||
              (product.category?.name
                      ?.toLowerCase()
                      .contains(category.toLowerCase()) ??
                  false);

          bool priceFilter =
              (minPrice == null || (product.price ?? 0) >= minPrice) &&
                  (maxPrice == null || (product.price ?? 0) <= maxPrice);

          bool discountFilter =
              discountPer == null || (product.discount ?? 0) >= discountPer;

          return categoryFilter && discountFilter && priceFilter;
        }));
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error in filterProducts: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>> getUserData(String token) async {
    final url =
        Uri.parse('https://rajasthandryfruitshouse.com/rest-auth/user/');
    const csrfToken =
        'XITMQkr5pQsag0M81aHHGNPIoaCGlYbfwwqJhkab7uzOG9XZvHpDYqf0sckwPRmU';

    final headers = {
      'accept': 'application/json',
      'X-CSRFToken': csrfToken,
      'authorization': "Token $token",
    };

    try {
      debugPrint("this is the token:$token");
      debugPrint("this is the url:$url");
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        debugPrint("this is the response of the profile api:${response.body}");
        final userData = json.decode(response.body) as Map<String, dynamic>;
        notifyListeners();

        return userData;
      } else {
        // Handle HTTP error response
        debugPrint(
            'Failed to get user data. Status code: ${response.statusCode}');
        return {}; // Return empty map in case of failure
      }
    } catch (e) {
      // Handle network error
      debugPrint('Error fetching user data: $e');
      return {}; // Return empty map in case of error
    }
  }

  Future<void> updateUserProfile(
    String token,
    String firstName,
    String lastName,
    BuildContext context, {
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    File? profileImage,
  }) async {
    bool isStoringData = true;

    // Show circular indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColor.primaryColor,
          ),
        );
      },
    );

    try {
      final dio = Dio();
      final url = 'https://rajasthandryfruitshouse.com/rest-auth/user/';

      // Create FormData for multipart request
      FormData formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (gender != null) 'gender': gender,
        if (profileImage != null)
          'profile_image': await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split('/').last,
          ),
      });

      // Send PATCH request
      final response = await dio.patch(
        url,
        data: formData,
        options: Options(
          headers: {
            'accept': 'application/json',
            'authorization': "Token $token",
          },
        ),
      );

      // Pop loading dialog
      Navigator.of(context).pop();
      isStoringData = false;

      if (response.statusCode == 200) {
        Utils.toastMessage('Profile updated successfully');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => DashBoardScreen()),
        );
      } else {
        Utils.flushBarErrorMessage(
          'Failed to update profile. Please try again.',
          context,
        );
        debugPrint(
            'Failed to update user profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Pop loading dialog
      Navigator.of(context).pop();
      isStoringData = false;

      Utils.flushBarErrorMessage('Error updating profile: $e', context);
      debugPrint('Error updating user profile: $e');
    }
  }

// Helper function to upload profile image
  Future<String?> uploadProfileImage(String token, File imageFile) async {
    try {
      final url = Uri.parse(
          'https://rajasthandryfruitshouse.com/rest-auth/upload-profile-image/');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll({
        'accept': 'application/json',
        'authorization': "Token $token",
      });

      // Add file
      var multipartFile = await http.MultipartFile.fromPath(
        'profile_image',
        imageFile.path,
      );
      request.files.add(multipartFile);

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonResponse['image_url'];
      } else {
        debugPrint(
            'Failed to upload image. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }
}
