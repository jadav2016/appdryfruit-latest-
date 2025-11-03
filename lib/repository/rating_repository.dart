// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rjfruits/model/pending_review_model.dart';
import 'package:rjfruits/res/const/response_handler.dart';
import 'package:rjfruits/utils/routes/routes_name.dart';
import 'package:rjfruits/utils/routes/utils.dart';

class RatingRepository extends ChangeNotifier {
  List<Order> orders = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Post Order Rating
  Future<void> postOrderRating(
      int rating,
      String prodId,
      String comment,
      BuildContext context,
      String token,
      int client,
      int order,
      ) async {
    try {
      _setLoading(true);

      final url = Uri.parse('https://rajasthandryfruitshouse.com/api/order/add/rating/');
      const csrfToken = 'b9pqcOKunanYdHklY0l2p337ishh9W0fFsuq6Ir8j5ecI1jiw1WLjH3leZH5nQ6P';

      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken,
        'authorization': "Token $token",
      };

      final body = jsonEncode({
        "order": order,
        "product": prodId,
        "rate": rating,
        "comment": comment,
        "client": client,
      });

      debugPrint("POST URL: $url");
      debugPrint("Headers: $headers");
      debugPrint("Body: $body");

      final response = await http.post(url, headers: headers, body: body);

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 201) {
        Utils.toastMessage("Rating added successfully.");
        Navigator.pushNamedAndRemoveUntil(context, RoutesName.dashboard, (route) => false);
      } else if (response.statusCode == 400) {
        try {
          final Map<String, dynamic> bodyJson = jsonDecode(response.body);

          // Collect all error messages from the response JSON
          List<String> errorMessages = [];
          bodyJson.forEach((key, value) {
            if (value is List) {
              for (var msg in value) {
                errorMessages.add(msg.toString());
              }
            } else {
              errorMessages.add(value.toString());
            }
          });

          final errorMessage = errorMessages.join('\n');
          Utils.flushBarErrorMessage(errorMessage, context);
        } catch (e) {
          // If parsing fails, fallback to raw body
          Utils.flushBarErrorMessage(response.body.toString(), context);
        }
      } else {
        Utils.flushBarErrorMessage("Unexpected error occurred", context);
      }
    } catch (e, stackTrace) {
      debugPrint("Caught error: $e");
      debugPrint("Stack trace: $stackTrace");
      handleApiError(e, context);
    } finally {
      _setLoading(false);
    }
  }



  // Get Pending Reviews
  Future<void> getPendingReviews(BuildContext context, String token) async {
    const url = 'https://rajasthandryfruitshouse.com/api/pending/reviews/';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          "Content-Type": 'application/json',
          'X-CSRFToken': '8DreMzsm686oLm67ak3JGC6M2p4WvHu8CWweGt9023XCgG54IlEsAg60YWuKJBAI',
          'authorization': 'Token $token',
        },
      );

      debugPrint("URL: $url");
      debugPrint("Token: $token");

      if (response.statusCode == 200) {
        debugPrint("Response body: ${response.body}");

        List<dynamic> jsonResponse = json.decode(response.body);

        // Always clear and update orders
        orders = jsonResponse.map((json) => Order.fromJson(json)).toList();
        notifyListeners();

        if (orders.isEmpty) {
          debugPrint("No pending reviews found.");
          // Utils.flushBarErrorMessage("No pending reviews found", context);
        } else {
          debugPrint("Parsed orders: ${orders.length} items");
        }
      } else {
        debugPrint("Response error: ${response.statusCode}");
        Utils.flushBarErrorMessage("Unexpected error", context);
      }
    } catch (e) {
      debugPrint("Error: $e");
      handleApiError(e, context);
    }
  }
}

