import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../res/components/cart_button.dart';
import '../../res/components/colors.dart';
import '../../res/components/vertical_spacing.dart';
import '../../view_model/home_view_model.dart';
import '../../view_model/shop_view_model.dart';
import '../HomeView/widgets/homeCard.dart';

class FilterSearchSection extends StatelessWidget {
  final Function onTapClear;
  final String? limited;
  const FilterSearchSection(
      {super.key, required this.onTapClear, this.limited});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Products',
                style: GoogleFonts.getFont(
                  "Roboto",
                  color: AppColor.textColor1,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              CartButton(onTap: onTapClear, text: 'Clear'),
            ],
          ),
        ),
        const VerticalSpeacing(12.0),
        Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
            child: Consumer<ShopRepositoryProvider>(
                builder: (context, homeRepo, child) {
              if (homeRepo.shopRepository.filteredProducts.isEmpty) {
                return Center(
                  child: Text(
                    'No Products Found',
                    style: GoogleFonts.getFont(
                      "Roboto",
                      color: AppColor.textColor1,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              } else {
                return GridView.count(
                  padding: const EdgeInsets.all(5.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: (180 / 280),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  children: List.generate(
                    // Limit to only two items

                    homeRepo.shopRepository.filteredProducts.length,
                    (index) => HomeCard(
                      isdiscount: false,
                      image: homeRepo.shopRepository.filteredProducts[index]
                          .thumbnailImage,
                      discount: homeRepo.shopRepository.filteredProducts[index]
                          .discountedPrice
                          .toString(),
                      title:
                          homeRepo.shopRepository.filteredProducts[index].title,
                      price: homeRepo
                          .shopRepository.filteredProducts[index].price
                          .toString(),
                      proId: homeRepo.shopRepository.filteredProducts[index].id
                          .toString(),
                      averageReview: homeRepo
                          .shopRepository.filteredProducts[index].averageReview
                          .toString(),
                      limited: limited,
                    ),
                  ),
                );
              }
            })),
      ],
    );
  }
}
