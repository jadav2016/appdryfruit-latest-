// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:rjfruits/view/HomeView/widgets/homeCard.dart';
import 'package:rjfruits/view_model/shop_view_model.dart';

import '../../res/components/colors.dart';

class SearchSectionUi extends StatelessWidget {
  final String? limited;
  const SearchSectionUi({super.key, this.limited});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopRepositoryProvider>(
        builder: (context, homeRepo, child) {
      if (homeRepo.shopRepository.searchResults.isEmpty) {
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
          childAspectRatio: (180 / 270),
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          children: List.generate(
            // Limit to only two items
            homeRepo.shopRepository.searchResults.length,
            (index) => HomeCard(
                isdiscount: false,
                image:
                    homeRepo.shopRepository.searchResults[index].thumbnailImage,
                discount: homeRepo
                    .shopRepository.searchResults[index].discountedPrice
                    .toString(),
                title: homeRepo.shopRepository.searchResults[index].title,
                price: double.parse(
                        homeRepo.shopRepository.searchResults[index].price)
                    .toString(),
                proId:
                    homeRepo.shopRepository.searchResults[index].id.toString(),
                averageReview: homeRepo
                    .shopRepository.searchResults[index].averageReview
                    .toString(),
                limited: limited),
          ),
        );
      }
    });
  }
}
