// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rjfruits/model/product_detail_model.dart';

import 'package:http/http.dart' as http;
import 'package:rjfruits/res/const/response_handler.dart';
import 'package:rjfruits/utils/routes/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view/HomeView/product_detail_view.dart';

class ProductDetailRepository extends ChangeNotifier {
  ProductDetail productDetail = ProductDetail();
  Future<ProductDetail> fetchProductDetails(
      BuildContext context, String id) async {
    final String url = 'https://rajasthandryfruitshouse.com/api/product/$id/';
    final Map<String, String> headers = {
      'accept': 'application/json',
      'X-CSRFToken':
      'ggUEuomf5SLMCluLyTUTe1TcfnGAZLVoViIVEUEUNtjhGnRumUUHsEMQ3hM8ocJE',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      debugPrint("this is the response product details: ${response.body}");
      if (response.statusCode == 200) {
        debugPrint('detail works');
        productDetail = ProductDetail.fromJson(jsonDecode(response.body));
        // Navigate to the next screen and pass the product detail
        debugPrint("this is the product details: ${productDetail.id}");
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => ProductDetailScreen(detail: productDetail),
        //   ),
        // );
        return productDetail;
        // notifyListeners();
      } else {
        throw Exception('Failed to load product detail');
      }
    } catch (e) {
      debugPrint("this is the error:$e");
      handleApiError(e, context);
    }
    return productDetail;
  }

  Future<void> saveProductToCache({
    required String productId,
    required String name,
    required String productWeight,
    required String price,
    required int quantity,
    required String token,
    required BuildContext context,
  }) async {
    try {
      debugPrint("function has been called");
      final url =
      Uri.parse('https://rajasthandryfruitshouse.com/api/cart/items/');
      dynamic we;

      if (productWeight == "null") {
        we = null;
      } else {
        we = int.parse(productWeight);
      }
      debugPrint("this is the product weight= $productWeight");
      debugPrint("this is the token of the user= $token");
      final response = await http.post(
        url,
        headers: <String, String>{
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRFToken':
          'kktm3pokcNxKVGEeXSiJrkLrmWNgCL4fZmhDdVGZUo5fZI1XLTixFXE5aQTO1cSv',
          'authorization': "Token $token"
        },
        body: jsonEncode(<String, dynamic>{
          'product': productId,
          'quantity': quantity,
          'product_weight': we,
        }),
      );
      print('Response add to cart: ${response.body}');
      if (response.statusCode == 201) {
        // Data sent successfully
        Utils.toastMessage("Product has been added to cart");
        notifyListeners();
      } else {
        final responseBody = json.decode(response.body);
        if (responseBody.containsKey('non_field_errors')) {
          log('${responseBody['non_field_errors'].join(", ")}');
          Utils.toastMessage(responseBody['non_field_errors'].join(", "));
        } else {
          Utils.toastMessage("Product is already in the cart");
        }
      }
    } catch (e) {
      log('Error add cart==>${e.toString()}');
      handleApiError(e, context);
    }
  }

  // Updated method to check product in cart via API
  Future<bool> isProductInCartFromApi(String productId, String token, BuildContext context) async {
    try {
      var url = Uri.parse('https://rajasthandryfruitshouse.com/api/cart/items/');
      var headers = {
        'accept': 'application/json',
        'authorization': "Token $token",
        'X-CSRFToken': '8ztwmgXx792DE5T8vL5kBl7KKbXArImwNBhNwMfcPKA8I7gRjM58PY0oy538Q9aM'
      };

      var response = await http.get(url, headers: headers);
      debugPrint('Get cart items response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        debugPrint('Get cart items response: $jsonResponse');

        var cartItemsJson = jsonResponse['cart_items'] as List<dynamic>;

        // Check if the product is in the cart
        bool isInCart = cartItemsJson.any((item) {
          return item['product']['id'].toString() == productId;
        });

        return isInCart;
      } else {
        log('Error getting cart items: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Error checking if product is in cart from API: ${e.toString()}');
      handleApiError(e, context);
      return false;
    }
  }

  // Keep the old method for backward compatibility (but mark as deprecated)
  @deprecated
  Future<bool> isProductInCart(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cachedProducts = prefs.getStringList('products') ?? [];

    for (String productJson in cachedProducts) {
      Map<String, dynamic> productMap = json.decode(productJson);
      if (productMap['productId'] == productId) {
        return true;
      }
    }

    return false;
  }

  Future<void> removeProductFromCart({
    required String cartItemId,
    required String token,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse('https://rajasthandryfruitshouse.com/api/cart/items/$cartItemId/');

      final response = await http.delete(
        url,
        headers: <String, String>{
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRFToken': 'kktm3pokcNxKVGEeXSiJrkLrmWNgCL4fZmhDdVGZUo5fZI1XLTixFXE5aQTO1cSv',
          'authorization': "Token $token"
        },
      );

      debugPrint('Response remove from cart: ${response.body}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        // Product removed successfully
        Utils.toastMessage("Product has been removed from cart");

        // Remove from local cache as well
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> cachedProducts = prefs.getStringList('products') ?? [];

        // Remove the product from cached list
        cachedProducts.removeWhere((productJson) {
          Map<String, dynamic> product = json.decode(productJson);
          return product['id'] == cartItemId;
        });

        await prefs.setStringList('products', cachedProducts);
        notifyListeners();

      } else {
        Utils.toastMessage("Failed to remove product from cart");
      }
    } catch (e) {
      log('Error removing from cart: ${e.toString()}');
      handleApiError(e, context);
    }
  }
}