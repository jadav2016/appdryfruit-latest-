import 'package:flutter/material.dart';
import 'package:rjfruits/repository/rating_repository.dart';

class RatingRepositoryProvider extends ChangeNotifier {
  final RatingRepository _ratingRepository = RatingRepository();

  RatingRepository get ratingRepository => _ratingRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void rating(int rating, String prodId, String comment, BuildContext context,
      String token, int client, int order) {
    _ratingRepository.postOrderRating(
        rating, prodId, comment, context, token, client, order);
  }

  Future<void> pedingReview(String token, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _ratingRepository.getPendingReviews(context, token);
    } catch (e) {
      debugPrint("Error in pedingReview: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
