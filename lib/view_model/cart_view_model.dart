import 'package:flutter/material.dart';
import 'package:rjfruits/repository/cart_repository.dart';

class CartRepositoryProvider extends ChangeNotifier {
  final CartRepository _cartRepositoryProvider = CartRepository();

  CartRepository get cartRepositoryProvider => _cartRepositoryProvider;

  // Getter for cart items count (total quantity)
  int get totalItemCount => _cartRepositoryProvider.getTotalItemCount();

  // Getter for cart items count (number of different products)
  int get cartItemsCount => _cartRepositoryProvider.getCartItemsCount();

  Future<void> getCachedProducts(BuildContext context, String token) async {
    await _cartRepositoryProvider.getCachedProducts(context, token);
    notifyListeners();
  }

  Future<void> deleteProduct(int id, BuildContext context, String token) async {
    await _cartRepositoryProvider.deleteProduct(id, context, token);
    notifyListeners();
  }

  Future<void> addQuantity(int id, String productId, int quantity, BuildContext context,
      String token) async {
    await _cartRepositoryProvider.addQuantity(
        id, productId, quantity, context, token);
    notifyListeners();
  }

  Future<void> removeQuantity(int id, String productId, int quantity,
      BuildContext context, String token) async {
    await _cartRepositoryProvider.removeQuantity(
        id, productId, quantity, context, token);
    notifyListeners();
  }

  String calculateTotalPrice() {
    String totalPrice = _cartRepositoryProvider.calculateTotalPrice();
    return totalPrice;
  }

  int getTotalItemCount() {
    return _cartRepositoryProvider.getTotalItemCount();
  }

  // Method to get cart items count (alternative approach)
  int getCartItemsCount() {
    return _cartRepositoryProvider.getCartItemsCount();
  }

  // Add to cart method
  Future<void> addToCart(String productId, int quantity, BuildContext context, String token) async {
    await _cartRepositoryProvider.addToCart(productId, quantity, context, token);
    notifyListeners();
  }
}