import 'package:flutter/material.dart';

class RatingView extends StatelessWidget {
  final double rating; // Accepts rating as double (e.g., 3.5, 4.0)
  final Color starColor;
  final double iconSize;

  const RatingView({
    super.key,
    required this.rating,
    this.starColor = Colors.amber,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor(); // Full stars count
    bool hasHalfStar = rating - fullStars >= 0.5; // Check for half star
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0); // Remaining empty stars

    return Row(
      children: [
        // Full Stars
        for (int i = 0; i < fullStars; i++)
          Icon(Icons.star, color: starColor, size: iconSize),

        // Half Star (if applicable)
        if (hasHalfStar)
          Icon(Icons.star_half, color: starColor, size: iconSize),

        // Empty Stars
        for (int i = 0; i < emptyStars; i++)
          Icon(Icons.star_border, color: starColor, size: iconSize),

        // Forward Arrow
        const Icon(Icons.arrow_forward_ios_outlined, color: Colors.blue, size: 16),
      ],
    );
  }
}
