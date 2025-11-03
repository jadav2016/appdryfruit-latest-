import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/view/HomeView/widgets/homeCard.dart';
import 'package:rjfruits/view_model/shop_view_model.dart';

import '../../model/shop_model.dart';

class DeaultSearchSection extends StatelessWidget {
  List<Shop>? shopProducts;
  final String? limited;
  DeaultSearchSection({super.key, this.shopProducts, this.limited});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: (180 / 280),
      mainAxisSpacing: 10.0, // Spacing between rows
      crossAxisSpacing: 10.0, // Spacing between columns
      children: List.generate(
        shopProducts?.length ?? 0,
        (index) => HomeCard(
          isdiscount: false,
          title: shopProducts?[index].title,
          image: shopProducts?[index].thumbnailImage,
          discount: shopProducts?[index].discountedPrice.toStringAsFixed(0),
          proId: shopProducts?[index].id.toString(),
          price: double.parse(shopProducts?[index].price ?? '0').toString(),
          averageReview: shopProducts?[index].averageReview.toString() ?? '0',
          limited: limited,
          // Pass other data properties here
        ),
      ),
    );
  }
}
