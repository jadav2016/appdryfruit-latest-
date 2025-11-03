import 'package:flutter/material.dart';
import 'package:rjfruits/repository/track_repository.dart';

class TrackOrderRepositoryProvider extends ChangeNotifier {
  final TrackOrderRepository _trackOrderRepositoryProvider = TrackOrderRepository();

  // Your local state variables
  String trackingUrl = '';
  String trackingId = '';
  String deliveryCompany = '';
  String destination = '';
  List<dynamic> shippedList = [];
  List<dynamic> outOfDeliveryList = [];
  List<dynamic> deliveredList = [];

  TrackOrderRepository get trackOrderRepositoryProvider => _trackOrderRepositoryProvider;

  void clearData() {
    trackingUrl = '';
    trackingId = '';
    deliveryCompany = '';
    destination = '';
    shippedList.clear();
    outOfDeliveryList.clear();
    deliveredList.clear();
    notifyListeners();
  }

  Future<void> fetchOrderDetails(
      BuildContext context,
      String id,
      String token,
      String shopRocketId,
      String customShipId,
      ) async {
    try {
      await _trackOrderRepositoryProvider.fetchOrderDetails(
        context,
        id,
        token,
        shopRocketId,
        customShipId,
      );
      debugPrint('fetchOrderDetails completed successfully');
    } catch (e, stackTrace) {
      debugPrint('Error in fetchOrderDetails: $e');
      debugPrint('StackTrace: $stackTrace');
    }
    notifyListeners();
  }

  Future<void> fetchShipData(String id, String token) async {
    try {
      await _trackOrderRepositoryProvider.fetchShipmentDetail(id, token);
      debugPrint('fetchShipData completed successfully');
    } catch (e, stackTrace) {
      debugPrint('Error in fetchShipData: $e');
      debugPrint('StackTrace: $stackTrace');
    }
    notifyListeners();
  }

  Future<void> customShip(String id, String token) async {
    try {
      await _trackOrderRepositoryProvider.fetchCustomDetailData(id, token);
      debugPrint('customShip completed successfully');
    } catch (e, stackTrace) {
      debugPrint('Error in customShip: $e');
      debugPrint('StackTrace: $stackTrace');
    }
    notifyListeners();
  }
}

