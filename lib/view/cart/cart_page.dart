import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/model/cart_model.dart';
import 'package:rjfruits/utils/routes/utils.dart';
import 'package:rjfruits/view/cart/widgets/cart_widget.dart';
import 'package:rjfruits/view/checkOut/check_out_view.dart';
import 'package:rjfruits/view_model/cart_view_model.dart';
import 'package:rjfruits/view_model/user_view_model.dart';
import '../../res/components/colors.dart';
import '../../res/components/vertical_spacing.dart';
import 'package:http/http.dart' as http;

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  bool _isLoading = true;

  gettingAllRequiredData() async {
    debugPrint('gettingAllRequiredData called');

    setState(() {
      _isLoading = true;
    });

    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    final userModel = await userPreferences.getUser();
    final token = userModel.key;
    Provider.of<CartRepositoryProvider>(context, listen: false)
        .getCachedProducts(context, token);
    await getCachedProducts(context, token);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint('initState called');
    gettingAllRequiredData();
  }

  void refreshCartData() {
    debugPrint('refreshCartData called');
    if (mounted) {
      gettingAllRequiredData();
    }
  }

  List<ProductCategory> productCategories = [];
  List<Product> addedCartProducts = [];
  List<CartItem> addedCartItems = [];
  double totalPrice = 0;
  double discountPrice = 0;
  double shipRocketCharges = 0;
  double customShippingCharges = 0;

  double subTotal = 0;
  Future<void> addQuantity(int itemId, String product, int quantity,
      BuildContext context, String token) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use provider method
      await Provider.of<CartRepositoryProvider>(context, listen: false)
          .addQuantity(itemId, product, quantity, context, token);

      // Refresh local data
      await getCachedProducts(context, token);

    } catch (e) {
      Utils.flushBarErrorMessage("problem in updating product", context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> removeQuantity(int itemId, String product, int quantity,
      BuildContext context, String token) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use provider method
      await Provider.of<CartRepositoryProvider>(context, listen: false)
          .removeQuantity(itemId, product, quantity, context, token);

      // Refresh local data
      await getCachedProducts(context, token);

    } catch (e) {
      Utils.flushBarErrorMessage("Check your internet connection", context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> getCachedProducts(BuildContext context, String token) async {
    debugPrint("get cart items");
    var url = Uri.parse('https://rajasthandryfruitshouse.com/api/cart/items/');
    var headers = {
      'accept': 'application/json',
      'authorization': "Token $token",
      'X-CSRFToken':
      '8ztwmgXx792DE5T8vL5kBl7KKbXArImwNBhNwMfcPKA8I7gRjM58PY0oy538Q9aM'
    };

    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print('Get product res -== ${jsonResponse}');
        var cartItemsJson = jsonResponse['cart_items'] as List<dynamic>;

        productCategories = cartItemsJson
            .map((item) => ProductCategory.fromJson(item['product']['category']))
            .toList();
        addedCartProducts = cartItemsJson
            .map((item) => Product.fromJson(item['product']))
            .toList();
        addedCartItems = cartItemsJson.map((item) => CartItem.fromJson(item)).toList();

        totalPrice = jsonResponse['total_price'].toDouble();
        discountPrice = jsonResponse['discount_price'].toDouble();
        shipRocketCharges =
            jsonResponse['shiprocket_shipping_charges'].toDouble();
        subTotal = jsonResponse['sub_total'].toDouble();
        customShippingCharges =
            jsonResponse['custom_shipping_charges'].toDouble();

        if (mounted) {
          setState(() {});
        }
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      Utils.flushBarErrorMessage("Failed to load cart items. Please try again.", context);
    }
  }

  final TextEditingController _couponController = TextEditingController();

  Future<void> _applyCoupon() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    final userModel = await userPreferences.getUser();
    final token = userModel.key;
    String couponCode = _couponController.text;

    try {
      final response = await http.post(
        Uri.parse('https://rajasthandryfruitshouse.com/api/apply-coupon/'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRFToken':
          'EPfbegDrcoMcKsg8rk5bx1bMotQv2GCk5hvuKZYUbALSqcufI1DK4ZIbzkRUnWg2',
          'authorization': 'Token $token',
        },
        body: jsonEncode({'code': couponCode}),
      );

      debugPrint(response.body);
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        Utils.toastMessage('Coupon applied successfully');
        await gettingAllRequiredData();
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Something went wrong';
        Utils.flushBarErrorMessage(errorMessage, context);
      }
    } catch (e) {
      Utils.flushBarErrorMessage("Failed to apply coupon. Please try again.", context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> deleteProduct(int productId, BuildContext context, String token) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the provider method instead of making direct API call
      await Provider.of<CartRepositoryProvider>(context, listen: false)
          .deleteProduct(productId, context, token);

      // Update local state after successful deletion
      addedCartItems.removeWhere((item) => item.id == productId);

      // Refresh the cart data to ensure consistency
      await getCachedProducts(context, token);

    } catch (e) {
      Utils.flushBarErrorMessage("Problem in removing product", context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          image: DecorationImage(
              image: AssetImage("images/bgimg.png"), fit: BoxFit.cover),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Cart Page',
                          style: GoogleFonts.getFont(
                            "Poppins",
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColor.appBarTxColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15,),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.44,
                    width: double.infinity,
                    child: _isLoading
                        ? _buildLoadingIndicator()
                        : _buildCartItems(userPreferences),
                  ),
                  const VerticalSpeacing(10.0),
                  Container(
                    height: 360,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border:
                      Border.all(color: AppColor.primaryColor, width: 1),
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Coupon",
                                style: TextStyle(
                                  fontFamily: 'CenturyGothic',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.blackColor,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width:
                                    MediaQuery.of(context).size.width / 1.8,
                                    child: TextFormField(
                                      controller: _couponController,
                                      decoration: const InputDecoration(
                                        hintText: "Enter coupon code",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _isLoading ? null : _applyCoupon,
                                child: Container(
                                  height: 40,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: _isLoading ? AppColor.primaryColor.withOpacity(0.5) : AppColor.primaryColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColor.whiteColor,
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : Text(
                                      "Apply",
                                      style: GoogleFonts.getFont(
                                        "Poppins",
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColor.whiteColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const VerticalSpeacing(12.0),
                          _buildOrderSummary(),
                        ],
                      ),
                    ),
                  ),
                  const VerticalSpeacing(60.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColor.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            "Loading cart items...",
            style: GoogleFonts.getFont(
              "Poppins",
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColor.appBarTxColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(UserViewModel userPreferences) {
    if (addedCartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: AppColor.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              "Your cart is empty",
              style: GoogleFonts.getFont(
                "Poppins",
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColor.appBarTxColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add some products to get started",
              style: GoogleFonts.getFont(
                "Poppins",
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColor.appBarTxColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: addedCartItems.length,
      itemBuilder: (context, index) {
        final cartItem = addedCartItems[index];
        final product = cartItem.product;
        final productWeight = cartItem.productWeight;

        debugPrint("product cart");
        debugPrint(jsonEncode(product.toJson()));

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: CartWidget(
            onTapRemove: () async {
              final userModel = await userPreferences.getUser();
              final token = userModel.key;
              removeQuantity(
                  cartItem.id,
                  product.id.toString(),
                  cartItem.quantity,
                  context,
                  token);
            },
            onTapAdd: () async {
              final userModel = await userPreferences.getUser();
              final token = userModel.key;
              await addQuantity(
                  cartItem.id,
                  product.id.toString(),
                  cartItem.quantity,
                  context,
                  token);
            },
            onpress: () async {
              final userModel = await userPreferences.getUser();
              final token = userModel.key;
              deleteProduct(cartItem.id, context, token);
            },
            productId: product.id.toString(),
            name: product.title,
            img: product.thumbnailImage,
            price: product.price.toString(),
            guantity: cartItem.quantity,
            individualPrice: product.price.toString(),
            id: cartItem.id,
            productWeight: productWeight, // Adding the productWeight
            rating: product.totalReviews.toString(),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "SUMMARY",
              style: TextStyle(
                fontFamily: 'CenturyGothic',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: AppColor.blackColor,
              ),
            ),
          ],
        ),
        const VerticalSpeacing(16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Discount",
              style: TextStyle(
                fontFamily: 'CenturyGothic',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColor.blackColor,
              ),
            ),
            Text(
              '₹${discountPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: 'CenturyGothic',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColor.blackColor,
              ),
            ),
          ],
        ),
        const Divider(),
        const VerticalSpeacing(16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TOTAL",
              style: TextStyle(
                fontFamily: 'CenturyGothic',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColor.blackColor,
              ),
            ),
            Text(
              "₹${(subTotal).toStringAsFixed(2)}",
              style: const TextStyle(
                fontFamily: 'CenturyGothic',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColor.blackColor,
              ),
            ),
          ],
        ),
        const VerticalSpeacing(20.0),
        SizedBox(
          height: 55.0,
          width: double.infinity,
          child: InkWell(
            onTap: _isLoading ? null : () {
              if(addedCartItems.isEmpty && addedCartProducts.isEmpty){
                Utils.flushBarErrorMessage('Please add product to checkout', context);
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return CheckOutScreen(
                        totalPrice: (subTotal).toStringAsFixed(2),
                      );
                    })).then((_) {
                  // This will be called when returning from CheckOutScreen
                  gettingAllRequiredData();
                });
              }
            },
            child: Container(
              height: 56,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: _isLoading ? AppColor.primaryColor.withOpacity(0.5) : AppColor.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 0, 0, 0)
                          .withOpacity(0.25),
                      blurRadius: 8.1,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
              ),
              child: Center(
                child: _isLoading
                    ? CircularProgressIndicator(
                  color: AppColor.whiteColor,
                  strokeWidth: 2,
                )
                    : Text(
                  "Proceed to CheckOut",
                  style: GoogleFonts.getFont(
                    "Poppins",
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}