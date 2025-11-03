import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/repository/home_ui_repository.dart';
import 'package:rjfruits/res/components/cart_button.dart';
import 'package:rjfruits/res/components/colors.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:rjfruits/view/HomeView/widgets/homeCard.dart';
import 'package:rjfruits/view_model/home_view_model.dart';

class CategoriesSection extends StatefulWidget {
  final Function onTapClear;
  const CategoriesSection({super.key, required this.onTapClear});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  // Control how many items to display initially
  static const int initialItemCount = 6;
  // Control how many items to load when "Load More" is tapped
  static const int paginationStep = 6;

  int _currentItemCount = initialItemCount;
  bool _isLoading = false;

  void _loadMore(int totalItems) {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading with a small delay
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _currentItemCount = (_currentItemCount + paginationStep <= totalItems)
            ? _currentItemCount + paginationStep
            : totalItems;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: GoogleFonts.getFont(
                  "Roboto",
                  color: AppColor.textColor1,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              CartButton(
                  onTap: widget.onTapClear,
                  text: 'Clear'),
            ],
          ),
        ),
        const VerticalSpeacing(12.0),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Consumer<HomeRepositoryProvider>(
            builder: (context, homeRepo, child) {
              if (homeRepo.homeRepository.categriousProduct.isEmpty) {
                return Center(
                  child: Text(
                    'No Products to show',
                    style: GoogleFonts.getFont(
                      "Roboto",
                      color: AppColor.textColor1,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              } else {
                // Get total items and limit display items
                final totalItems = homeRepo.homeRepository.categriousProduct.length;
                final displayItemCount = _currentItemCount > totalItems ? totalItems : _currentItemCount;

                return Column(
                  children: [
                    GridView.builder(
                      padding: const EdgeInsets.all(5.0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: (180 / 280),
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                      ),
                      itemCount: displayItemCount,
                      itemBuilder: (context, index) {
                        final product = homeRepo.homeRepository.categriousProduct[index];
                        return HomeCard(
                          isdiscount: false,
                          image: product.thumbnailImage,
                          discount: product.discountedPrice.toString(),
                          title: product.title,
                          price: product.price.toString(),
                          proId: product.id.toString(),
                          averageReview: product.averageReview.toString(),
                        );
                      },
                    ),

                    // Show Load More button if there are more items to load
                    if (displayItemCount < totalItems)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : TextButton(
                          onPressed: () => _loadMore(totalItems),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColor.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                          ),
                          child: Text(
                            'Load More',
                            style: GoogleFonts.getFont(
                              "Roboto",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }
}