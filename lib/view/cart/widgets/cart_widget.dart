// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/model/cart_model.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:rjfruits/view_model/cart_view_model.dart';
import 'package:rjfruits/view_model/user_view_model.dart';
import '../../../res/components/colors.dart';

class CartWidget extends StatefulWidget {
  const CartWidget({
    super.key,
    required this.name,
    required this.price,
    required this.productId,
    required this.guantity,
    required this.img,
    required this.onpress,
    required this.onTapAdd,
    required this.onTapRemove,
    this.individualPrice,
    required this.id,
    this.productWeight,
    this.rating,
  });
  final String name;
  final String price;
  final String productId;
  final int guantity;
  final String img;
  final VoidCallback onpress;
  final VoidCallback onTapAdd;
  final VoidCallback onTapRemove;
  final String? individualPrice;
  final int id;
  final ProductWeight? productWeight;
  final String? rating;
  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  int? addPrice;

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    // Calculate price based on product weight if available
    int finalPrice;
    if (widget.productWeight != null) {
      // Use the price from productWeight
      finalPrice = widget.productWeight!.priceInt;
    } else if (widget.price.contains(".")) {
      // Price contains decimals, extract the whole number part
      finalPrice = int.parse(widget.price.split(".")[0]);
    } else {
      // No decimals, parse as usual
      finalPrice = int.parse(widget.price);
    }
    addPrice = finalPrice * widget.guantity;

    debugPrint("this is the widget cart $widget");

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.primaryColor, width: 1),
        color: const Color.fromRGBO(
            255, 255, 255, 0.2), // Background color with opacity
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5), // Shadow color
            blurRadius: 2, // Blur radius
            spreadRadius: 0, // Spread radius
            offset: const Offset(0, 0), // Offset
          ),
        ],
      ),
      // Adjusted height for better layout
      height: widget.productWeight != null ? 140 : 130,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            Container(
              height: 70.0,
              width: 75.0,
              margin: const EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(width: 1, color: AppColor.primaryColor),
                image: DecorationImage(
                    image: NetworkImage(widget.img),
                    fit: BoxFit.contain),
              ),
            ),

            // Middle section - product details and quantity controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Product name and rating
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontFamily: 'CenturyGothic',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColor.cardTxColor,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '⭐ ${widget.rating ?? 'N/A'}',
                    style: const TextStyle(
                      color: AppColor.primaryColor,
                      fontSize: 14.0,
                    ),
                  ),
                  // Display product weight if available
                  if (widget.productWeight != null)
                    Text(
                        'Weight: ${widget.productWeight!.weight.name}',
                        style: const TextStyle(
                        fontSize: 12,
                        color: AppColor.textColor1,
                      ),
                    ),
                  const SizedBox(height: 4.0),

                  // Quantity controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: widget.onTapRemove,
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColor.textColor1,
                              ),
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: AppColor.primaryColor,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.guantity.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textColor1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: widget.onTapAdd,
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColor.textColor1,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColor.primaryColor,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right section - delete button and price
            SizedBox(
              width: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Delete button
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: IconButton(
                      onPressed: widget.onpress,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColor.appBarTxColor,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),

                  // Price section - align with quantity buttons
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Price:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColor.textColor1,
                            ),
                          ),
                          Text(
                            addPrice == null
                                ? '₹${widget.price}'
                                : '₹${addPrice.toString()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textColor1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}