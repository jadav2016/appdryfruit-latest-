// ignore_for_file: prefer_final_fields

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rjfruits/model/product_detail_model.dart';
import 'package:rjfruits/repository/product_detail_repositroy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductRepositoryProvider extends ChangeNotifier {
  ProductDetailRepository _productRepository = ProductDetailRepository();

  // Keep track of cart items for real-time updates
  List<Map<String, dynamic>> _cartItems = [];

  ProductDetailRepository get productRepository => _productRepository;
  List<Map<String, dynamic>> get cartItems => _cartItems;

  // Initialize and load cached products
  Future<void> initialize() async {
    await _loadCachedProducts();
  }

  Future<void> _loadCachedProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> cachedProducts = prefs.getStringList('products') ?? [];

      _cartItems = cachedProducts.map((productJson) {
        return json.decode(productJson) as Map<String, dynamic>;
      }).toList();

      notifyListeners();
    } catch (e) {
      log('Error loading cached products: $e');
    }
  }

  Future<ProductDetail> fetchProductDetails(BuildContext context, String id) async {
    return await _productRepository.fetchProductDetails(context, id);
  }

  Future<void> saveCartProducts(
      String productId,
      String name,
      String weight,
      String price,
      int quantity,
      String token,
      BuildContext context,
      ) async {
    try {
      await _productRepository.saveProductToCache(
        productId: productId,
        name: name,
        productWeight: weight,
        price: price,
        quantity: quantity,
        token: token,
        context: context,
      );

      // Reload cached products after successful API call
      await _loadCachedProducts();

    } catch (e) {
      log('Error saving cart product: $e');
      // Don't rethrow here as the repository handles errors
    }
  }

  // Updated to call API instead of checking local storage
  Future<bool> isProductInCart(String productId, String token, BuildContext context) async {
    try {
      return await _productRepository.isProductInCartFromApi(productId, token, context);
    } catch (e) {
      log('Error checking if product is in cart: $e');
      return false;
    }
  }

  // Synchronous version for immediate UI updates (still uses local cache)
  bool isProductInCartSync(String productId) {
    return _cartItems.any((product) => product['productId'] == productId);
  }

  // Get cart item ID for a specific product (useful for deletion)
  String? getCartItemId(String productId) {
    try {
      final item = _cartItems.firstWhere(
            (product) => product['productId'] == productId,
      );
      return item['id']?.toString();
    } catch (e) {
      return null;
    }
  }

  // FIXED: Now properly calls the API to remove from cart
  Future<void> removeFromCart(String productId, BuildContext context, String token) async {
    try {
      // First, get the cart item ID from local storage
      String? cartItemId = getCartItemId(productId);

      if (cartItemId != null && cartItemId.isNotEmpty) {
        // Call the API to remove from cart using the repository method
        await _productRepository.removeProductFromCart(
          cartItemId: cartItemId,
          token: token,
          context: context,
        );
      } else {
        // If cartItemId is not found locally, try to get it from API
        log('Cart item ID not found locally for product: $productId');

        // You might want to fetch cart items from API first to get the correct ID
        // For now, we'll still try to remove from local storage as fallback
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> cachedProducts = prefs.getStringList('products') ?? [];

        cachedProducts.removeWhere((productJson) {
          Map<String, dynamic> product = json.decode(productJson);
          return product['productId'] == productId;
        });

        await prefs.setStringList('products', cachedProducts);
        await _loadCachedProducts();

        log('Removed product from local storage only (API call skipped due to missing cart item ID)');
      }

      // Always reload cached products after any removal operation
      await _loadCachedProducts();

    } catch (e) {
      log('Error removing from cart: $e');
      // Even if API call fails, try to remove from local storage
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> cachedProducts = prefs.getStringList('products') ?? [];

        cachedProducts.removeWhere((productJson) {
          Map<String, dynamic> product = json.decode(productJson);
          return product['productId'] == productId;
        });

        await prefs.setStringList('products', cachedProducts);
        await _loadCachedProducts();

        log('Fallback: Removed product from local storage after API error');
      } catch (localError) {
        log('Error in fallback removal from local storage: $localError');
      }
    }
  }

  // Alternative method that forces API call by getting cart item ID from API first
  Future<void> removeFromCartWithApiLookup(String productId, BuildContext context, String token) async {
    try {
      // First check if product exists in cart via API and get the cart item details
      bool isInCart = await _productRepository.isProductInCartFromApi(productId, token, context);

      if (!isInCart) {
        log('Product not found in cart via API');
        return;
      }

      // Get cart items from API to find the correct cart item ID
      var url = Uri.parse('https://rajasthandryfruitshouse.com/api/cart/items/');
      var headers = {
        'accept': 'application/json',
        'authorization': "Token $token",
        'X-CSRFToken': '8ztwmgXx792DE5T8vL5kBl7KKbXArImwNBhNwMfcPKA8I7gRjM58PY0oy538Q9aM'
      };

      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var cartItemsJson = jsonResponse['cart_items'] as List<dynamic>;

        // Find the cart item with matching product ID
        var cartItem = cartItemsJson.firstWhere(
              (item) => item['product']['id'].toString() == productId,
          orElse: () => null,
        );

        if (cartItem != null && cartItem['id'] != null) {
          String cartItemId = cartItem['id'].toString();

          // Now call the API to remove the item
          await _productRepository.removeProductFromCart(
            cartItemId: cartItemId,
            token: token,
            context: context,
          );

          // Reload cached products after successful API call
          await _loadCachedProducts();
        } else {
          log('Cart item ID not found in API response');
        }
      } else {
        log('Failed to fetch cart items from API: ${response.statusCode}');
      }

    } catch (e) {
      log('Error in removeFromCartWithApiLookup: $e');
      // Fallback to local removal
      await removeFromCart(productId, context, token);
    }
  }

  // Get total cart count
  int get cartCount => _cartItems.length;

  // Clear all cart items
  Future<void> clearCart() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('products');
      _cartItems.clear();
      notifyListeners();
    } catch (e) {
      log('Error clearing cart: $e');
    }
  }

  // Update quantity for a specific product
  Future<void> updateProductQuantity(String productId, int newQuantity) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> cachedProducts = prefs.getStringList('products') ?? [];

      for (int i = 0; i < cachedProducts.length; i++) {
        Map<String, dynamic> product = json.decode(cachedProducts[i]);
        if (product['productId'] == productId) {
          product['quantity'] = newQuantity;
          cachedProducts[i] = json.encode(product);
          break;
        }
      }

      await prefs.setStringList('products', cachedProducts);
      await _loadCachedProducts();

    } catch (e) {
      log('Error updating product quantity: $e');
    }
  }
}