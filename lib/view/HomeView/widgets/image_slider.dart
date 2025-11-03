// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:custom_image_view/custom_image_view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/res/components/colors.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:rjfruits/view_model/save_view_model.dart';
import 'package:rjfruits/view_model/user_view_model.dart';

import '../../../model/product_detail_model.dart';
import '../../../res/const/response_handler.dart';
import '../../../utils/routes/utils.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({
    super.key,
    required this.image,
    required this.listImage,
    required this.id,
    required this.name,
    required this.discount,
  });

  final String image;
  final List<ProductImage> listImage;
  final String id;
  final String name;
  final String discount;

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  List<ProductImage> imgList = [];
  int currentIndex = 0;
  Color loveColor = AppColor.whiteColor;

  void checkProduct() async {
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    final userModel = await userPreferences.getUser();
    final token = userModel.key;

    SaveProductRepositoryProvider homeRepoProvider =
    Provider.of<SaveProductRepositoryProvider>(context, listen: false);
    await homeRepoProvider.getCachedProducts(context, token);

    bool isInCart = await homeRepoProvider.isProductInCart(widget.id);

    log('isInCart==>${isInCart}');
    setState(() {
      loveColor = isInCart ? AppColor.primaryColor : AppColor.whiteColor;
    });
  }

  Future<void> saveProductToSave({
    required String productId,
    required String name,
    required String image,
    required String price,
    required BuildContext context,
    required String token,
  }) async {
    final url = Uri.parse('https://rajasthandryfruitshouse.com/api/wish-list/');
    const csrfToken =
        'NGxAa947Y1IH8kL6Y0H28OV42wsR98ZvsIlRkFmMGCgccm8PM1HQmrOIQqypyzNL';

    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'X-CSRFToken': csrfToken,
      'authorization': "Token $token",
    };

    final body = jsonEncode({
      'product': productId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      log('Response==>${response.body}');

      var jsonData = jsonDecode(response.body);
      if (response.statusCode == 201) {
        setState(() {
          loveColor = AppColor.primaryColor;
        });

        Utils.toastMessage("Product added to wishlist successfully");
      } else {
        Utils.toastMessage(jsonData['non_field_errors'][0]);
      }
    } catch (e) {
      handleApiError(e, context);
    }
  }

  @override
  void initState() {
    checkProduct();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate square size based on screen width with more conservative sizing
    final imageSize = screenWidth * 0.56; // Reduced from 0.65 to 0.6 for better fit

    SaveProductRepositoryProvider saveRepo =
    Provider.of<SaveProductRepositoryProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(8.0), // Reduced padding
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColor.primaryColor, width: 2),
        color: const Color.fromRGBO(255, 255, 255, 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content column with flexible sizing
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top padding for love button clearance
              const SizedBox(height: 8),

              // Image container with 1:1 aspect ratio - CENTERED
              Center(
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: widget.listImage.isEmpty
                      ? CustomImageView(
                    url: widget.image ?? '',
                    fit: BoxFit.contain,
                    width: imageSize,
                    height: imageSize,
                  )
                      : CarouselSlider(
                    items: widget.listImage
                        .map(
                          (item) => CustomImageView(
                        url: item.image ?? '',
                        fit: BoxFit.contain,
                        width: imageSize,
                        height: imageSize,
                      ),
                    )
                        .toList(),
                    options: CarouselOptions(
                      autoPlay: false,
                      enlargeCenterPage: false,
                      viewportFraction: 1.0,
                      aspectRatio: 1.0,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // Indicator dots - only show if there are multiple images
              if (widget.listImage.length > 1) ...[
                const SizedBox(height: 6), // Reduced spacing
                SizedBox(
                  height: 12, // Fixed height for indicators
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.listImage.length, (index) {
                      return Container(
                        height: 4,
                        width: currentIndex == index ? 16 : 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? AppColor.primaryColor
                              : const Color(0xff898989),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      );
                    }),
                  ),
                ),
              ],

              const SizedBox(height: 6), // Reduced bottom spacing
            ],
          ),

          // Absolutely positioned love button
          Positioned(
            top: 8, // Reduced from 12
            right: 16, // Reduced from 20
            child: Container(
              height: 32, // Reduced from 35
              width: 32, // Reduced from 35
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.boxColor,
              ),
              child: Center(
                child: InkWell(
                  onTap: () async {
                    debugPrint("button is pressed");

                    // Fetch user token
                    final userModel = await userPreferences.getUser();
                    final token = userModel.key;

                    // Get cached products
                    await saveRepo.saveRepository
                        .getCachedProducts(context, token);

                    String? deleteId;

                    // Check if the product exists in the saved list
                    if (saveRepo.saveRepository.saveList.isNotEmpty) {
                      final itemToDelete =
                      saveRepo.saveRepository.saveList.firstWhere(
                            (item) => item["product"]["id"] == widget.id,
                        orElse: () => <String,
                            dynamic>{}, // Return an empty map if not found
                      );

                      if (itemToDelete.isNotEmpty) {
                        deleteId = itemToDelete["id"].toString();
                      }
                    }

                    // Delete the product if it exists, otherwise save the product
                    if (deleteId != null) {
                      await saveRepo.deleteProduct(
                          deleteId, context, token);
                      setState(() {
                        loveColor = AppColor.whiteColor;
                      });
                    } else {
                      saveProductToSave(
                        productId: widget.id.toString(),
                        name: widget.name,
                        image: widget.image,
                        price: widget.discount,
                        context: context,
                        token: token,
                      );
                    }
                  },
                  child: Icon(
                    Icons.favorite,
                    color: loveColor,
                    size: 18, // Reduced icon size
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}