import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/model/product_detail_model.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:rjfruits/res/const/response_handler.dart';
import 'package:rjfruits/view_model/cart_view_model.dart';
import 'package:rjfruits/view_model/product_detail_view_model.dart';
import 'package:rjfruits/view_model/user_view_model.dart';
import 'package:http/http.dart' as http;
import '../../../res/components/cart_button.dart';
import '../../../res/components/colors.dart';
import '../product_detail_view.dart';
import 'package:custom_image_view/custom_image_view.dart';
import 'package:rjfruits/utils/routes/routes_name.dart';

class HomeCard extends StatefulWidget {
  const HomeCard({
    super.key,
    required this.isdiscount,
    this.image,
    this.price,
    this.discount,
    this.title,
    this.proId,
    this.weight,
    required this.averageReview,
    this.disPercantage,
    this.timer,
    this.limited,
  });

  final bool isdiscount;
  final String? image;
  final String? price;
  final String? discount;
  final String? title;
  final String? proId;
  final List<dynamic>? weight;
  final String averageReview;
  final String? disPercantage;
  final String? timer;
  final String? limited;

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> with WidgetsBindingObserver {
  int amount = 1; // Default amount for new items
  bool isInCart = false;
  bool _isLoadingProduct = false;
  bool _isAddingToCart = false;
  bool _isCheckingCart = false;
  bool _isUpdatingQuantity = false;
  ProductDetail? productDetail;
  String selectedWeightUnit = 'KG'; // Default unit
  String selectedWeightId = '';
  String? userToken;
  int? cartItemId; // Store the cart item ID for quantity updates

  @override
  void initState() {
    super.initState();
    // Add observer to detect when app comes to foreground
    WidgetsBinding.instance.addObserver(this);

    // Initialize user token and then check product status
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeCartData();
    });

    if (widget.proId != null && widget.proId!.isNotEmpty) {
      fetchProductDetails(context, widget.proId!);
    }
  }

  @override
  void dispose() {
    // Remove observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called when app lifecycle changes (e.g., returning from background)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came to foreground, refresh cart data
      _refreshCartData();
    }
  }

  // Called when the route is pushed/popped (screen focus changes)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called every time the screen is accessed or returned to
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCartData();
    });
  }

  // Initialize cart data on first load
  Future<void> _initializeCartData() async {
    await _getUserToken();
    await _refreshCartData();
  }

  // Refresh all cart-related data
  Future<void> _refreshCartData() async {
    if (userToken != null && userToken!.isNotEmpty) {
      // Refresh cart data from server
      final cartProvider = Provider.of<CartRepositoryProvider>(context, listen: false);
      try {
        await cartProvider.getCachedProducts(context, userToken!);
        await checkTheProduct();
      } catch (e) {
        log('Error refreshing cart data: $e');
      }
    }
  }

  void increment() async {
    if (_isUpdatingQuantity || userToken == null) return;

    if (isInCart && cartItemId != null) {
      // Update quantity in cart via API
      setState(() {
        _isUpdatingQuantity = true;
      });

      try {
        final cartProvider = Provider.of<CartRepositoryProvider>(context, listen: false);
        await cartProvider.addQuantity(
          cartItemId!,
          widget.proId!,
          getCurrentCartQuantity(), // Get current quantity from cart
          context,
          userToken!,
        );
        // Refresh cart data after update
        await _refreshCartData();
      } catch (e) {
        log('Error incrementing quantity: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating quantity: $e')),
        );
      } finally {
        setState(() {
          _isUpdatingQuantity = false;
        });
      }
    } else {
      // Local increment for items not in cart
      setState(() {
        amount++;
      });
    }
  }

  void decrement() async {
    if (_isUpdatingQuantity || userToken == null) return;

    if (isInCart && cartItemId != null) {
      // Update quantity in cart via API
      setState(() {
        _isUpdatingQuantity = true;
      });

      try {
        final cartProvider = Provider.of<CartRepositoryProvider>(context, listen: false);
        int currentQty = getCurrentCartQuantity();

        if (currentQty > 1) {
          await cartProvider.removeQuantity(
            cartItemId!,
            widget.proId!,
            currentQty,
            context,
            userToken!,
          );
        } else {
          // If quantity becomes 0, remove from cart
          await cartProvider.deleteProduct(cartItemId!, context, userToken!);
          setState(() {
            isInCart = false;
            cartItemId = null;
          });
        }
        // Refresh cart data after update
        await _refreshCartData();
      } catch (e) {
        log('Error decrementing quantity: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating quantity: $e')),
        );
      } finally {
        setState(() {
          _isUpdatingQuantity = false;
        });
      }
    } else {
      // Local decrement for items not in cart
      if (amount > 1) {
        setState(() {
          amount--;
        });
      }
    }
  }

  // Get current quantity from cart data
  int getCurrentCartQuantity() {
    if (widget.proId == null) return amount;

    final cartProvider = Provider.of<CartRepositoryProvider>(context, listen: false);
    final cartItems = cartProvider.cartRepositoryProvider.cartItems;

    for (var item in cartItems) {
      if (item.product.id.toString() == widget.proId) {
        return item.quantity;
      }
    }
    return amount; // Fallback to local amount
  }

  // Get cart item ID for this product
  int? getCartItemId() {
    if (widget.proId == null) return null;

    final cartProvider = Provider.of<CartRepositoryProvider>(context, listen: false);
    final cartItems = cartProvider.cartRepositoryProvider.cartItems;

    for (var item in cartItems) {
      if (item.product.id.toString() == widget.proId) {
        return item.id;
      }
    }
    return null;
  }

  Future<void> _getUserToken() async {
    try {
      final userPreferences = Provider.of<UserViewModel>(context, listen: false);
      final userModel = await userPreferences.getUser();
      setState(() {
        userToken = userModel.key;
      });
    } catch (e) {
      log('Error getting user token: $e');
    }
  }

  Future<void> checkTheProduct() async {
    if (widget.proId != null && userToken != null && userToken!.isNotEmpty) {
      setState(() {
        _isCheckingCart = true;
      });

      try {
        ProductRepositoryProvider productRepoProvider =
        Provider.of<ProductRepositoryProvider>(context, listen: false);

        bool productInCart = await productRepoProvider.isProductInCart(
            widget.proId!,
            userToken!,
            context
        );

        if (mounted) {
          setState(() {
            isInCart = productInCart;
            cartItemId = getCartItemId(); // Update cart item ID
            _isCheckingCart = false;
          });
        }
      } catch (e) {
        log('Error checking product in cart: $e');
        if (mounted) {
          setState(() {
            _isCheckingCart = false;
          });
        }
      }
    } else {
      setState(() {
        isInCart = false;
        cartItemId = null;
        _isCheckingCart = false;
      });
    }
  }

  // Function to extract weight unit from weight name
  String extractWeightUnit(String weightName) {
    if (weightName.toUpperCase().contains('KG')) {
      return 'KG';
    } else if (weightName.toUpperCase().contains('GM') || weightName.toUpperCase().contains('G')) {
      return 'GM';
    } else if (weightName.toUpperCase().contains('LB') || weightName.toUpperCase().contains('POUND')) {
      return 'LB';
    } else if (weightName.toUpperCase().contains('OZ') || weightName.toUpperCase().contains('OUNCE')) {
      return 'OZ';
    } else {
      return 'UNIT'; // Default fallback
    }
  }

  // Function to set the default weight (lowest weight)
  void setDefaultWeight() {
    if (productDetail?.productWeight != null && productDetail!.productWeight!.isNotEmpty) {
      double parseWeightToGrams(String name) {
        if (name.toUpperCase().contains('KG')) {
          return (double.tryParse(name.toUpperCase().replaceAll('KG', '').trim()) ?? 0) * 1000;
        } else if (name.toUpperCase().contains('GM')) {
          return double.tryParse(name.toUpperCase().replaceAll('GM', '').trim()) ?? 0;
        } else {
          return 0;
        }
      }

      final weights = List.from(productDetail!.productWeight!);
      weights.sort((a, b) {
        final aGrams = parseWeightToGrams(a.weight.name);
        final bGrams = parseWeightToGrams(b.weight.name);
        return aGrams.compareTo(bGrams);
      });

      final lowestWeight = weights.first;
      setState(() {
        selectedWeightUnit = extractWeightUnit(lowestWeight.weight.name);
        selectedWeightId = lowestWeight.id.toString();
      });
    }
  }

  Future<void> fetchProductDetails(BuildContext context, String id) async {
    if (id.isEmpty) return;

    setState(() {
      _isLoadingProduct = true;
    });

    try {
      ProductRepositoryProvider productRepoProvider =
      Provider.of<ProductRepositoryProvider>(context, listen: false);

      ProductDetail detail = await productRepoProvider.fetchProductDetails(context, id);

      if (mounted) {
        setState(() {
          productDetail = detail;
          _isLoadingProduct = false;
        });
        // Set default weight after product details are loaded
        setDefaultWeight();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProduct = false;
        });
      }
      log('Error fetching product details: $e');
    }
  }

  Future<void> _navigateToProductDetail() async {
    if (userToken == null || userToken!.isEmpty) {
      debugPrint("token user $userToken");
      Navigator.pushNamed(context, RoutesName.login);
      return;
    }

    if (productDetail != null) {
      // Navigate and refresh data when returning
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(
            productId: widget.proId ?? '0',
          ),
        ),
      );

      // Refresh cart data when returning from product detail
      await _refreshCartData();
    }
  }

  Future<void> _toggleCartStatus() async {
    if (_isLoadingProduct || productDetail == null || _isAddingToCart || _isCheckingCart) {
      if (_isLoadingProduct || productDetail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please wait while product details load...'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    if (userToken == null || userToken!.isEmpty) {
      debugPrint("token user $userToken");
      Navigator.pushNamed(context, RoutesName.login);
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final productProvider = Provider.of<ProductRepositoryProvider>(context, listen: false);
      final cartProvider = Provider.of<CartRepositoryProvider>(context, listen: false);

      String formattedPrice = widget.discount ?? '0';
      formattedPrice = formatPrice(formattedPrice);

      if (!isInCart) {
        await productProvider.saveCartProducts(
          widget.proId!,
          widget.title ?? 'Product',
          selectedWeightId.isNotEmpty ? selectedWeightId : 'null',
          formattedPrice,
          amount,
          userToken!,
          context,
        );

        // Refresh cart data to update the badge counter
        await cartProvider.getCachedProducts(context, userToken!);

        await checkTheProduct();
      }
    } catch (e) {
      log('Error toggling cart status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  String formatPrice(String price) {
    final dotIndex = price.indexOf('.');
    if (dotIndex != -1) {
      return price.substring(0, dotIndex);
    }
    return price;
  }

  String truncateTitle(String? title, int charLimit) {
    if (title == null) return 'Dried Figs';
    if (title.length > charLimit) {
      return '${title.substring(0, charLimit)}...';
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    String formattedPrice = widget.discount ?? '0';
    formattedPrice = formatPrice(formattedPrice);

    String totalPrice = widget.price ?? '0';
    totalPrice = formatPrice(totalPrice);

    String truncatedTitle = truncateTitle(widget.title, 16);

    var imageWidth = MediaQuery.of(context).size.width / 2;
    var imageHeight = MediaQuery.of(context).size.width / 4;

    // Listen to both ProductRepositoryProvider and CartRepositoryProvider for real-time updates
    return Consumer2<ProductRepositoryProvider, CartRepositoryProvider>(
      builder: (context, productProvider, cartProvider, child) {
        // Update cart status and item ID based on current cart data
        final currentCartItemId = getCartItemId();
        final currentIsInCart = currentCartItemId != null;

        // Update local state if cart status changed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (currentIsInCart != isInCart || currentCartItemId != cartItemId) {
            setState(() {
              isInCart = currentIsInCart;
              cartItemId = currentCartItemId;
            });
          }
        });

        // Get the current quantity from cart (if in cart) or use local amount
        int displayQuantity = isInCart ? getCurrentCartQuantity() : amount;

        return Container(
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
          child: Padding(
            padding: const EdgeInsets.only(left: 8,right: 8,top: 8),
            child: Column(
              children: [
                // Top row with discount badge only
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.isdiscount && widget.disPercantage != '0'
                        ? Container(
                      height: MediaQuery.of(context).size.height / 26,
                      width: MediaQuery.of(context).size.width / 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.cartDiscountColor,
                      ),
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            text: '${widget.disPercantage}%\n',
                            style: const TextStyle(
                                fontSize: 9.0,
                                color: AppColor.whiteColor,
                                fontWeight: FontWeight.w600),
                            children: const [
                              TextSpan(
                                text: 'Off',
                                style: TextStyle(
                                    fontSize: 9.0,
                                    color: AppColor.whiteColor,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                        : Container(),
                    const SizedBox(),
                  ],
                ),

                // Image section
                widget.image == null
                    ? GestureDetector(
                  onTap: _navigateToProductDetail,
                  child: Image.asset('images/ds.png', fit: BoxFit.contain),
                )
                    : Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15), // Add rounded corners
                    child: widget.image == null
                        ? GestureDetector(
                      onTap: _navigateToProductDetail,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.33, // Increased size
                        height: MediaQuery.of(context).size.width * 0.33, // 1:1 aspect ratio
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey[100], // Background color for placeholder
                        ),
                        child: Image.asset(
                          'images/ds.png',
                          fit: BoxFit.cover, // Changed to cover for better appearance
                        ),
                      ),
                    )
                        : GestureDetector(
                      onTap: _navigateToProductDetail,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.33, // Increased size
                        height: MediaQuery.of(context).size.width * 0.33, // 1:1 aspect ratio
                        child: CachedNetworkImage(
                          imageUrl: widget.image!,
                          fit: BoxFit.cover, // Changed to cover for 1:1 ratio
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[100],
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColor.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[100],
                            ),
                            child: Image.asset(
                              'images/ds.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Title and rating section
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          truncatedTitle,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.getFont(
                            "Roboto",
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColor.cardTxColor,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColor.primaryColor,
                            size: 16,
                          ),
                          Text(
                            widget.averageReview,
                            style: GoogleFonts.getFont(
                              "Roboto",
                              textStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price section
                Row(
                  children: [
                    Visibility(
                      visible: widget.isdiscount,
                      child: Text(
                        widget.price == null
                            ? '₹50 '
                            : '₹${double.parse(totalPrice)}',
                        style: GoogleFonts.getFont(
                          "Roboto",
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColor.cardTxColor,
                          ),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                    Text(
                      "₹${widget.discount ?? ''}",
                      style: GoogleFonts.getFont(
                        "Roboto",
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textColor1,
                        ),
                      ),
                      overflow: TextOverflow.fade,
                    ),
                  ],
                ),

                // Timer section (if exists)
                if (widget.timer != null) ...[
                  const VerticalSpeacing(6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.timer!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],

                const VerticalSpeacing(6),

                // Cart button and View button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center, // Ensures vertical alignment
                  children: [
                    // Cart button
                    InkWell(
                      onTap: _toggleCartStatus,
                      child: Container(
                        // padding: EdgeInsets.all(4),
                        height: MediaQuery.sizeOf(context).height*0.04,
                        width: 32,  // Make it square for better alignment
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isInCart ? Colors.green : AppColor.primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 0, 0, 0)
                                  .withOpacity(0.25),
                              blurRadius: 8.1,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: (_isLoadingProduct || _isAddingToCart || _isCheckingCart)
                              ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                              : Icon(
                            isInCart ? Icons.check : Icons.shopping_cart,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                    // Quantity controls (only show if not limited)
                    if (widget.limited == null)
                      Container(
                        // padding: EdgeInsets.all(4),
                        height: MediaQuery.sizeOf(context).height*0.04,
                        width: MediaQuery.of(context).size.width * 0.25, // Adjust width as needed
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColor.primaryColor,
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: _isUpdatingQuantity ? null : decrement,
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isUpdatingQuantity
                                        ? AppColor.whiteColor.withOpacity(0.7)
                                        : AppColor.whiteColor,
                                  ),
                                  child: Center(
                                    child: _isUpdatingQuantity
                                        ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColor.iconColor,
                                        ),
                                      ),
                                    )
                                        : const Icon(
                                      Icons.remove,
                                      size: 14,
                                      color: AppColor.iconColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  displayQuantity.toString(), // Use display quantity
                                  style: const TextStyle(
                                    color: AppColor.whiteColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: _isUpdatingQuantity ? null : increment,
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isUpdatingQuantity
                                        ? AppColor.whiteColor.withOpacity(0.7)
                                        : AppColor.whiteColor,
                                  ),
                                  child: Center(
                                    child: _isUpdatingQuantity
                                        ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColor.iconColor,
                                        ),
                                      ),
                                    )
                                        : const Icon(
                                      Icons.add,
                                      size: 14,
                                      color: AppColor.iconColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const VerticalSpeacing(3),

              ],
            ),
          ),
        );
      },
    );
  }
}