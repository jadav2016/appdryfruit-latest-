// Updated CartRepository class with better state management

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rjfruits/model/cart_model.dart';
import 'package:rjfruits/utils/routes/utils.dart';
import 'package:http/http.dart' as http;

class CartRepository extends ChangeNotifier {
  List<ProductCategory> productCategories = [];
  List<Product> cartProducts = [];
  List<CartItem> cartItems = [];
  double totalPrice = 0;
  double discountPrice = 0;
  double shipRocketCharges = 0;
  double customShippingCharges = 0;
  double subTotal = 0;

  // Add these methods to get cart item counts
  int getTotalItemCount() {
    return cartItems.fold(0, (total, item) => total + item.quantity);
  }

  int getCartItemsCount() {
    return cartItems.length;
  }

  Future<void> getCachedProducts(BuildContext context, String token) async {
    print(token);
    try {
      var url = Uri.parse(
          'https://rajasthandryfruitshouse.com/api/cart/items/');
      var headers = {
        'accept': 'application/json',
        'authorization': "Token $token",
        'X-CSRFToken':
        '8ztwmgXx792DE5T8vL5kBl7KKbXArImwNBhNwMfcPKA8I7gRjM58PY0oy538Q9aM'
      };

      var response = await http.get(url, headers: headers);
      print('Get product res -== ${response.statusCode}');
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print('Get product res -== ${jsonResponse}');
        var cartItemsJson = jsonResponse['cart_items'] as List<dynamic>;

        productCategories = cartItemsJson
            .map(
                (item) => ProductCategory.fromJson(item['product']['category']))
            .toList();
        cartProducts = cartItemsJson
            .map((item) => Product.fromJson(item['product']))
            .toList();
        cartItems =
            cartItemsJson.map((item) => CartItem.fromJson(item)).toList();

        totalPrice = jsonResponse['total_price'].toDouble();
        discountPrice = jsonResponse['discount_price'].toDouble();
        shipRocketCharges =
            jsonResponse['shiprocket_shipping_charges'].toDouble();
        subTotal = jsonResponse['sub_total'].toDouble();
        customShippingCharges =
            jsonResponse['custom_shipping_charges'].toDouble();

        notifyListeners(); // Make sure to notify listeners after updating data
      } else {
        log('Error ${response.request}');
      }
    } catch (e) {
      print('Error::= ${e.toString()}');
    }
  }

  Future<void> deleteProduct(int productId, BuildContext context, String token) async {
    try {
      final url = 'https://rajasthandryfruitshouse.com/api/cart/$productId/';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'X-CSRFToken': 'eG9gGWbYQxkNMKGGvw4XSUDJ7PN27N8mTIXxQstDy8SiQM3pjx4L6xwnVJTAweWC',
          'authorization': "Token $token",
        },
      );

      if (response.statusCode == 204) {
        // Remove from local list
        cartItems.removeWhere((item) => item.id == productId);

        // Recalculate totals
        calculateTotalPrice();

        // Notify listeners to update UI and badge counter
        notifyListeners();

        Utils.toastMessage("Product has been deleted");
      } else {
        Utils.flushBarErrorMessage("Failed to delete product", context);
      }
    } catch (e) {
      print('Error deleting product: $e');
      Utils.flushBarErrorMessage("Problem in removing product", context);
    }
  }

  Future<void> addQuantity(int itemId, String product, int quantity,
      BuildContext context, String token) async {
    final updatedQuantity = quantity + 1;
    final url = 'https://rajasthandryfruitshouse.com/api/cart/$itemId/';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRFToken':
          "2yZ0t55418A2ce1TyGaKD5RmNUsFAwe6HANhDBnJJJ8xggoCmHayRIK0BOydZX2m",
          'authorization': "Token $token",
        },
        body: jsonEncode({
          'product': product,
          'quantity': updatedQuantity,
        }),
      );

      if (response.statusCode == 200) {
        // Update local cart item quantity
        final cartItemIndex = cartItems.indexWhere((item) => item.id == itemId);
        if (cartItemIndex != -1) {
          // Create a new CartItem with updated quantity since CartItem fields are final
          final updatedCartItem = CartItem(
            id: cartItems[cartItemIndex].id,
            product: cartItems[cartItemIndex].product,
            quantity: updatedQuantity,
            productWeight: cartItems[cartItemIndex].productWeight,
          );
          cartItems[cartItemIndex] = updatedCartItem;
          notifyListeners(); // This will update the badge count
        }
        log('response.body==>${response.body}');
      } else {
        // Handle other status codes
      }
    } catch (e) {
      Utils.flushBarErrorMessage("problem in updating product", context);
    }
  }

  Future<void> removeQuantity(int itemId, String product, int quantity,
      BuildContext context, String token) async {
    final updatedQuantity = quantity - 1;
    final url = 'https://rajasthandryfruitshouse.com/api/cart/$itemId/';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRFToken':
          "2yZ0t55418A2ce1TyGaKD5RmNUsFAwe6HANhDBnJJJ8xggoCmHayRIK0BOydZX2m",
          'authorization': "Token $token",
        },
        body: jsonEncode({
          'product': product,
          'quantity': updatedQuantity,
        }),
      );

      if (response.statusCode == 200) {
        // Update local cart item quantity
        final cartItemIndex = cartItems.indexWhere((item) => item.id == itemId);
        if (cartItemIndex != -1) {
          if (updatedQuantity <= 0) {
            cartItems.removeAt(cartItemIndex);
          } else {
            // Create a new CartItem with updated quantity since CartItem fields are final
            final updatedCartItem = CartItem(
              id: cartItems[cartItemIndex].id,
              product: cartItems[cartItemIndex].product,
              quantity: updatedQuantity,
              productWeight: cartItems[cartItemIndex].productWeight,
            );
            cartItems[cartItemIndex] = updatedCartItem;
          }
          notifyListeners(); // This will update the badge count
        }
      } else {
        // Handle other status codes
      }
    } catch (e) {
      Utils.flushBarErrorMessage("Check your internet connection", context);
    }
  }

  String calculateTotalPrice() {
    double totalPrice = 0.0;

    for (var cartItem in cartItems) {
      double productPrice = double.tryParse(cartItem.product.price) ?? 0.0;
      totalPrice += (productPrice * cartItem.quantity);
    }

    this.totalPrice = totalPrice;
    notifyListeners();

    return totalPrice.toString();
  }

  // Method to add item to cart (if you need to implement add to cart functionality)
  Future<void> addToCart(String productId, int quantity, BuildContext context, String token) async {
    try {
      final url = 'https://rajasthandryfruitshouse.com/api/cart/add/';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRFToken': "your_csrf_token_here",
          'authorization': "Token $token",
        },
        body: jsonEncode({
          'product': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Refresh cart data to get updated items
        await getCachedProducts(context, token);
        Utils.toastMessage("Product added to cart");
      } else {
        // Handle other status codes
        Utils.flushBarErrorMessage("Failed to add product to cart", context);
      }
    } catch (e) {
      Utils.flushBarErrorMessage("Problem adding product to cart", context);
    }
  }

  // Method to refresh cart data from server
  Future<void> refreshCartData(BuildContext context, String token) async {
    await getCachedProducts(context, token);
  }

}