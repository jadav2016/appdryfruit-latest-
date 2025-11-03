// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/model/product_detail_model.dart';
import 'package:rjfruits/res/components/colors.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:rjfruits/view/HomeView/widgets/image_slider.dart';
import 'package:rjfruits/view/checkOut/check_out_view.dart';
import 'package:rjfruits/view/total_review/total_review.dart';
import 'package:rjfruits/view_model/home_view_model.dart';
import 'package:rjfruits/view_model/product_detail_view_model.dart';
import 'package:rjfruits/view_model/save_view_model.dart';
import 'package:rjfruits/view_model/user_view_model.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import '../../utils/rating_builder.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key,required this.productId});
  // final ProductDetail detail;
  final String productId;
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isLoading = false;
  String? weight;
  String? weightPrice;
  String? weightid;
  String discountedPrice = "0";
  String intPrice = "";
  String intweight = "";
  int amount = 1;
  ProductDetail detail = ProductDetail();
  List<dynamic> sortedWeights = []; // Store sorted weights for display

  void increament() {}

  void decrement() {
    if (amount == 0) {
    } else {
      setState(() {
        amount--;
      });
    }
  }

  String parseHtmlString(String htmlString) {
    dom.Document document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  calclutePrice() {
    HomeRepositoryProvider homeRepoProvider =
    Provider.of<HomeRepositoryProvider>(context, listen: false);
    double originalPrice = double.tryParse(detail.price ??'0.0') ?? 0.0;
    String per = detail.discount.toString();
    double originalDiscount = double.parse(per);
    discountedPrice = homeRepoProvider.homeRepository
        .calculateDiscountedPrice(originalPrice, originalDiscount);
    String dr = detail.discountedPrice.toString();
    intPrice = dr;
  }

  gettingAllTheData() async {
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    final userModel =
    await userPreferences.getUser(); // Await the Future<UserModel> result
    final token = userModel.key;
    Provider.of<SaveProductRepositoryProvider>(context, listen: false)
        .getCachedProducts(context, token);
  }

  double _extractNumericValue(String weightName) {
    // Extract numeric part from strings like "500g", "1kg", etc.
    RegExp regExp = RegExp(r'([\d.]+)');
    Match? match = regExp.firstMatch(weightName);
    if (match != null && match.group(1) != null) {
      double value = double.tryParse(match.group(1)!) ?? 0.0;

      // Convert to common unit (assuming grams)
      if (weightName.toLowerCase().contains('kg')) {
        value *= 1000; // Convert kg to g
      } else if (weightName.toLowerCase().contains('l') || weightName.toLowerCase().contains('ml')) {
        // Handle liters/milliliters if needed
        if (weightName.toLowerCase().contains('l') && !weightName.toLowerCase().contains('ml')) {
          value *= 1000; // Convert liters to ml
        }
      }
      return value;
    }
    return 0.0;
  }

  void _sortWeightsBySize() {
    if (detail.productWeight != null && detail.productWeight!.isNotEmpty) {
      log('Original weights count: ${detail.productWeight!.length}');

      // Create a copy of the list to sort
      sortedWeights = List.from(detail.productWeight!);

      try {
        // Sort weights based on numeric value (ascending - smallest first)
        sortedWeights.sort((a, b) {
          String aName = a?.weight?.name ?? '';
          String bName = b?.weight?.name ?? '';

          double aValue = _extractNumericValue(aName);
          double bValue = _extractNumericValue(bName);

          // Log for debugging
          log('Comparing: $aName ($aValue) vs $bName ($bValue)');

          return aValue.compareTo(bValue);
        });

        // Auto-select the smallest (first) weight option
        if (sortedWeights.isNotEmpty) {
          final smallestWeight = sortedWeights[0];
          weight = smallestWeight?.weight?.name ?? '';
          weightPrice = smallestWeight?.discountedPrice?.toString() ?? '';
          intweight = smallestWeight?.price ?? '';
          weightid = smallestWeight?.id?.toString() ?? '';

          log('Selected smallest weight: $weight with price: $weightPrice');
        }
      } catch (e) {
        log('Error sorting weights: $e');
        // Fallback to original logic if sorting fails
        sortedWeights = List.from(detail.productWeight!);
        if (sortedWeights.isNotEmpty) {
          final firstWeight = sortedWeights[0];
          weight = firstWeight?.weight?.name ?? '';
          weightPrice = firstWeight?.discountedPrice?.toString() ?? '';
          intweight = firstWeight?.price ?? '';
          weightid = firstWeight?.id?.toString() ?? '';
        }
      }
    } else {
      log('No product weights available');
      sortedWeights = [];
    }
  }

  Future getProductDetail() async {
    isLoading = true;
    setState(() {});
    final productDetailsProvider =
    Provider.of<ProductRepositoryProvider>(context, listen: false);
    detail = await productDetailsProvider.fetchProductDetails(
      context,
      widget.productId,
    );
    log('detail.discount==>${detail.discount}');

    // Sort weights and select the smallest one
    _sortWeightsBySize();
  }

  @override
  void initState() {
    super.initState();
    getProductDetail().then((v){
      calclutePrice();
      gettingAllTheData();
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);

    ProductRepositoryProvider proRepoProvider =
    Provider.of<ProductRepositoryProvider>(context, listen: false);

    debugPrint(sortedWeights.toString());

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          image: DecorationImage(
              image: AssetImage("images/bgimg.png"), fit: BoxFit.cover),
        ),
        child: SafeArea( // Added SafeArea to prevent overlap with system UI
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.west,
                        color: AppColor.textColor1,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Product Details",
                          style: GoogleFonts.getFont(
                            "Poppins",
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: AppColor.textColor1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the IconButton width
                  ],
                ),
              ),

              // Loading or Content
              isLoading == true
                  ? Expanded(
                child: const Center(
                    child: CircularProgressIndicator(color: AppColor.primaryColor)
                ),
              )
                  : Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [


                      // Fixed Image Container with proper aspect ratio
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.35, // Fixed height
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: ImageSlider(
                            image: detail.thumbnailImage ?? '',
                            listImage: detail.images ?? [],
                            id: detail.id.toString(),
                            name: detail.title ?? '',
                            discount: discountedPrice,
                          ),
                        ),
                      ),

                      // Product Title and Stock Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 3,
                            child: Text(
                              detail.title ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2, // Allow up to 2 lines
                              style: GoogleFonts.getFont(
                                "Poppins",
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.textColor1,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 14,
                                  width: 14,
                                  decoration: const BoxDecoration(
                                      color: AppColor.primaryColor,
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "In stock",
                                  style: GoogleFonts.getFont(
                                    "Poppins",
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.textColor1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const VerticalSpeacing(8),

                      // Price Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Available in",
                            style: GoogleFonts.getFont(
                              "Poppins",
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColor.textColor1,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Visibility(
                                visible: detail.discount != 0,
                                child: Text(
                                  "₹${detail.priceWithTax.toString()}",
                                  style: GoogleFonts.getFont(
                                    "Poppins",
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.textColor1,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "₹${detail.discountedPrice.toString()}",
                                style: GoogleFonts.getFont(
                                  "Poppins",
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const VerticalSpeacing(15),

                      // Weight Selection and Quantity Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weight options - Now using sortedWeights with fallback
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 65,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: sortedWeights.isNotEmpty
                                    ? sortedWeights.length
                                    : (detail.productWeight?.length ?? 0), // Fallback to original if sortedWeights is empty
                                itemBuilder: (BuildContext context, int index) {
                                  // Use sortedWeights if available, otherwise fallback to original
                                  final productWeight = sortedWeights.isNotEmpty
                                      ? sortedWeights[index]
                                      : detail.productWeight?[index];

                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          weight = productWeight?.weight?.name ?? '';
                                          weightPrice = productWeight?.discountedPrice?.toString() ?? '';
                                          intweight = productWeight?.price ?? '';
                                          weightid = productWeight?.id?.toString() ?? '';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(25),
                                          color: weight == productWeight?.weight?.name
                                              ? AppColor.primaryColor
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: AppColor.primaryColor,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              productWeight?.weight?.name ?? '',
                                              style: GoogleFonts.getFont(
                                                "Poppins",
                                                textStyle: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: weight == productWeight?.weight?.name
                                                      ? AppColor.whiteColor
                                                      : AppColor.textColor1,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "₹${productWeight?.discountedPrice ?? ''}",
                                              style: GoogleFonts.getFont(
                                                "Poppins",
                                                textStyle: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: weight == productWeight?.weight?.name
                                                      ? AppColor.whiteColor
                                                      : AppColor.textColor1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Quantity controls
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (amount > 1) {
                                    setState(() {
                                      amount--;
                                      // Update price calculation
                                      if (weightPrice == null) {
                                        String priceWithoutDecimals = intPrice.split('.').first;
                                        int initPrice = int.parse(priceWithoutDecimals);
                                        discountedPrice = "${amount * initPrice}";
                                      } else {
                                        String priceWithoutDecimals = intweight.split('.').first;
                                        int initPrice = int.parse(priceWithoutDecimals);
                                        weightPrice = "${amount * initPrice}";
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColor.iconColor),
                                    color: AppColor.whiteColor,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  amount.toString(),
                                  style: GoogleFonts.getFont(
                                    "Poppins",
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.textColor1,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    amount++;
                                    // Update price calculation
                                    if (weightPrice == null) {
                                      String priceWithoutDecimals = intPrice.split('.').first;
                                      int initPrice = int.parse(priceWithoutDecimals);
                                      discountedPrice = "${amount * initPrice}";
                                    } else {
                                      String priceWithoutDecimals = intweight.split('.').first;
                                      int initPrice = int.parse(priceWithoutDecimals);
                                      weightPrice = "${amount * initPrice}";
                                    }
                                  });
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColor.iconColor),
                                    color: AppColor.whiteColor,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const VerticalSpeacing(25),

                      // Product Details Section
                      Text(
                        "Product Details",
                        style: GoogleFonts.getFont(
                          "Poppins",
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textColor1,
                          ),
                        ),
                      ),
                      const VerticalSpeacing(8),
                      Text(
                        parseHtmlString(detail.description ?? ''),
                        style: GoogleFonts.getFont(
                          "Poppins",
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColor.iconColor,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const VerticalSpeacing(20),
                      const Divider(color: AppColor.dividerColor),
                      const VerticalSpeacing(15),

                      // Reviews Section
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => TotalRatingScreen(
                                fiveStar: detail?.fiveStar ?? 0,
                                oneStar: detail.oneStar ?? 0,
                                fourStar: detail.fourStar ?? 0,
                                threeStar: detail.threeStar ?? 0,
                                twoStar: detail.twoStar ?? 0,
                                reviews: detail.productReview ?? [],
                                averageReview: detail.averageReview.toString(),
                                totalReviews: detail.totalReviews.toString(),
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Review",
                              style: GoogleFonts.getFont(
                                "Poppins",
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.textColor1,
                                ),
                              ),
                            ),
                            RatingView(rating: detail.averageReview ?? 0.0),
                          ],
                        ),
                      ),
                      const VerticalSpeacing(15),
                      const Divider(color: AppColor.dividerColor),
                      const VerticalSpeacing(25),

                      // Action Buttons
                      Row(
                        children: [
                          // Add to Cart Button
                          Container(
                            height: 55,
                            width: 55,
                            margin: const EdgeInsets.only(right: 15),
                            child: InkWell(
                              onTap: () async {
                                final userModel = await userPreferences.getUser();
                                final token = userModel.key;
                                proRepoProvider.saveCartProducts(
                                    detail.id.toString(),
                                    detail.title ?? '',
                                    weightid ?? "null",
                                    discountedPrice,
                                    amount,
                                    token,
                                    context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColor.primaryColor, width: 2),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Image.asset(
                                    "images/ds.png",
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Buy Now Button
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final userModel = await userPreferences.getUser();
                                final token = userModel.key;
                                proRepoProvider.saveCartProducts(
                                    detail.id.toString(),
                                    detail.title ?? '',
                                    weightid ?? "null",
                                    discountedPrice,
                                    amount,
                                    token,
                                    context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                      return CheckOutScreen(
                                        totalPrice: detail.price.toString(),
                                      );
                                    }));
                              },
                              child: Container(
                                height: 55.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: AppColor.primaryColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]),
                                child: Center(
                                  child: Text(
                                    "Buy Now",
                                    style: GoogleFonts.getFont(
                                      "Poppins",
                                      color: AppColor.whiteColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const VerticalSpeacing(30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}