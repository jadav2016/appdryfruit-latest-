// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:custom_image_view/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/model/home_model.dart';
import 'package:rjfruits/repository/home_ui_repository.dart';
import 'package:rjfruits/res/components/cart_button.dart';
import 'package:rjfruits/res/components/enums.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:rjfruits/utils/routes/routes_name.dart';
import 'package:rjfruits/view/HomeView/category_products.dart';
import 'package:rjfruits/view/HomeView/default_section.dart';
import 'package:rjfruits/view/HomeView/filter_products.dart';
import 'package:rjfruits/view/HomeView/search_section.dart';
import 'package:rjfruits/view/shopView/shop_view.dart';
import 'package:rjfruits/view_model/home_view_model.dart';
import '../../model/offer_modal.dart';
import '../../model/shop_model.dart' as shop;
import '../../res/app_url.dart';
import '../../res/components/categorycard.dart';
import '../../res/components/colors.dart';
import 'package:shimmer/shimmer.dart';

import '../../res/const/response_handler.dart';
import '../../utils/fcm.dart';
import '../../view_model/auth_view_model.dart';
import '../../view_model/user_view_model.dart';
import '../dashBoard/dashboard.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController searchController = TextEditingController();
  bool isLoadingCategories = false;
  Map userData = {};
  List selectedCategory = [];

  List<OfferModal> offerList = <OfferModal>[
    OfferModal(img: 'images/banner.png'),
    OfferModal(img: 'images/diwali_sale.jpg'),
    OfferModal(img: 'images/shopping_sale.jpg'),
    OfferModal(img: 'images/megha_sale.jpg'),
  ];

  String token = "";
  int count = 0;

  Future<void> _getUserData() async {
    try {
      final userPreferences =
          Provider.of<UserViewModel>(context, listen: false);
      final userModel = await userPreferences.getUser();
      await userPreferences.getAppData();
      // Await the Future<UserModel> result
      token = userModel.key;
      final userData =
          await Provider.of<HomeRepositoryProvider>(context, listen: false)
              .getUserData(token);
      setState(() {
        this.userData = userData;
      });
      debugPrint("this is the cliecnt details:$userData");
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future setFcmToken()async{
    String fcmToken = await NotificationServices().getDeviceToken();
    Map<String, String> data2 = {
      'registration_id': fcmToken,
      'application_id': 'my_fcm_ap',
    };
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    await authViewModel.registerDevice(data2, context);

  }

  Future<int> getCount() async{
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    count = await userPreferences.getCount();

    return count;
  }

  @override
  void initState() {
    // setFcmToken();
    _getUserData();
    getCount();
    Provider.of<HomeRepositoryProvider>(context, listen: false)
        .getShopProd(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserViewModel>(context);
    final userData = userProvider.userData;
    final fullName = '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : (userData['email'] ?? 'User');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          image: DecorationImage(
              image: AssetImage("images/bgimg.png"), fit: BoxFit.cover),
        ),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VerticalSpeacing(40.0),
                ListTile(
                  leading: CircleAvatar(
                    radius: 25.0,
                    backgroundImage: (userProvider.userData['profile_image'] !=
                                null &&
                            userProvider.userData['profile_image'].isNotEmpty)
                        ? NetworkImage(userProvider.userData['profile_image'])
                        : const NetworkImage(
                            'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/271deea8-e28c-41a3-aaf5-2913f5f48be6/de7834s-6515bd40-8b2c-4dc6-a843-5ac1a95a8b55.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzI3MWRlZWE4LWUyOGMtNDFhMy1hYWY1LTI5MTNmNWY0OGJlNlwvZGU3ODM0cy02NTE1YmQ0MC04YjJjLTRkYzYtYTg0My01YWMxYTk1YThiNTUuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.BopkDn1ptIwbmcKHdAOlYHyAOOACXW0Zfgbs0-6BY-E',
                          ),
                    backgroundColor: Colors
                        .grey.shade300, // Adds a fallback background color
                  ),

                  // CircleAvatar(
                  //   radius: 25.0,
                  //   backgroundImage: userData['image'] != null && profileImage.isNotEmpty ? NetworkImage(
                  //     'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/271deea8-e28c-41a3-aaf5-2913f5f48be6/de7834s-6515bd40-8b2c-4dc6-a843-5ac1a95a8b55.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzI3MWRlZWE4LWUyOGMtNDFhMy1hYWY1LTI5MTNmNWY0OGJlNlwvZGU3ODM0cy02NTE1YmQ0MC04YjJjLTRkYzYtYTg0My01YWMxYTk1YThiNTUuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.BopkDn1ptIwbmcKHdAOlYHyAOOACXW0Zfgbs0-6BY-E',
                  //   ),
                  // ),

                  // CircleAvatar(
                  //   radius: 35,
                  //   backgroundImage: profileImage != null && profileImage.isNotEmpty
                  //       ? NetworkImage(profileImage)
                  //       : const NetworkImage(
                  //       'https://t4.ftcdn.net/jpg/03/64/21/11/360_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg'),
                  // ),
                  title: Text(
                    'Welcome',
                    style: GoogleFonts.getFont(
                      "Roboto",
                      color: AppColor.textColor2,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  subtitle: displayName.isNotEmpty
                      ? Text(
                    displayName,
                    style: GoogleFonts.getFont(
                      "Roboto",
                      color: AppColor.textColor1,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                      : Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Text(
                      'Loading...',
                      style: GoogleFonts.getFont(
                        "Roboto",
                        color: AppColor.textColor1,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  trailing: SizedBox(
                    height: 60,
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, RoutesName.notificationView);
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 7),
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.0),
                              color: AppColor.boxColor,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications,
                                color: AppColor.textColor1,
                                size: 18,
                              ),
                            ),
                          ),
                        ),


                        Consumer<UserViewModel>(
                          builder: (context, userViewModel, child) {
                            return FutureBuilder<int>(
                              future: userViewModel.getCount(),
                              builder: (context, snapshot) {
                                // Handle loading/error states
                                if (!snapshot.hasData) return const SizedBox.shrink();

                                final count = snapshot.data!;
                                if (count <= 0) return const SizedBox.shrink();

                                return Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      (count) > 99 ? '100+' : (count ).toString(),
                                      style: GoogleFonts.roboto(
                                        color: AppColor.whiteColor,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
                const VerticalSpeacing(16.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: SearchBar(
                    searchController: searchController,
                    onTapFilter: () {
                      Navigator.pushNamed(
                        context,
                        RoutesName.filter,
                      ).then((v) {
                        selectedCategory.clear();

                        setState(() {});
                      });
                    },
                  ),
                ),

                const VerticalSpeacing(16.0),

                Consumer<HomeRepositoryProvider>(
                    builder: (context, homeRepo, child) {
                  return homeRepo.homeRepository.sliderList != []
                      ? CarouselSlider(
                          options: CarouselOptions(
                            height: 200.0,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            aspectRatio: 16 / 9,
                            viewportFraction: 1,
                            autoPlayInterval: const Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                          ),
                          items: homeRepo.homeRepository.sliderList.map((item) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CustomImageView(
                                        fit: BoxFit.cover,
                                        height: 200.0,
                                        width: double.infinity,
                                        url: item.image ?? ''),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30.0, bottom: 30.0),
                                      child: CartButton(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (c) =>
                                                    ShopView()),
                                            );
                                          },
                                          text: 'Order Now'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      : const SizedBox();
                }),

                // Padding(
                //   padding: const EdgeInsets.only(left: 20.0, right: 20),
                //   child: Container(
                //     height: 159.0,
                //     width: double.infinity,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(12.0),
                //       boxShadow: [
                //         BoxShadow(
                //           color: const Color(0xff000000)
                //               .withOpacity(0.25), // color of the shadow
                //           spreadRadius: 0, // spread radius
                //           blurRadius: 4, // blur radius
                //           offset: const Offset(0, 4),
                //         ),
                //       ],
                //       image: const DecorationImage(
                //         image: AssetImage('images/banner.png'),
                //         fit: BoxFit.cover,
                //       ),
                //     ),
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Padding(
                //           padding:
                //               const EdgeInsets.only(left: 30.0, bottom: 30.0),
                //           child: CartButton(onTap: () {}, text: 'Order Now'),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // const VerticalSpeacing(16.0),
                //
                // Padding(
                //   padding: const EdgeInsets.only(left: 15.0, right: 2),
                //   child: SizedBox(
                //     height: 165,
                //     width: double.infinity *0.9,
                //     child: ListView.builder(
                //       shrinkWrap: true,
                //       scrollDirection: Axis.horizontal,
                //       itemBuilder: (context,index){
                //         return Padding(
                //           padding: const EdgeInsets.only(left: 5.0, right: 2),
                //           child: Container(
                //             height: 159.0,
                //             width: 350,
                //
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(12.0),
                //               boxShadow: [
                //                 BoxShadow(
                //                   color: const Color(0xff000000)
                //                       .withOpacity(0.1), // color of the shadow
                //                   spreadRadius: 0, // spread radius
                //                   blurRadius: 4, // blur radius
                //                   offset: const Offset(0, 0),
                //                 ),
                //               ],
                //               image: const DecorationImage(
                //                 image: AssetImage('images/banner.png'),
                //                 fit: BoxFit.cover,
                //               ),
                //             ),
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.end,
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Padding(
                //                   padding:
                //                   const EdgeInsets.only(left: 30.0, bottom: 30.0),
                //                   child: CartButton(onTap: () {}, text: 'Order Now'),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         );
                //       },
                //     ),
                //   ),
                // ),
                const VerticalSpeacing(14.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: Text(
                    'Categories',
                    style: GoogleFonts.getFont(
                      "Roboto",
                      color: AppColor.textColor1,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const VerticalSpeacing(9.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 0),
                  child: SizedBox(
                    height: 70,
                    child: Consumer<HomeRepositoryProvider>(
                      builder: (context, homeRepo, child) {
                        if (homeRepo.homeRepository.productCategories.isEmpty) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 10,
                            itemExtent: MediaQuery.of(context).size.width / 3.6,
                            itemBuilder: (BuildContext context, int index) {
                              // Category category = homeRepo
                              //     .homeRepository.productCategories[index];

                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: CategoryCart(
                                  selectedCategory: '',
                                  onCategorySelected: (v) {},
                                  text: "category.name",
                                ),
                              );
                            },
                          );
                        } else {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: homeRepo
                                .homeRepository.productCategories.length,
                            // itemExtent: MediaQuery.of(context).size.width / 3.6,
                            itemBuilder: (BuildContext context, int index) {
                              Category category = homeRepo
                                  .homeRepository.productCategories[index];

                              return CategoryCart(
                                selectedCategory: selectedCategory.isNotEmpty
                                    ? selectedCategory.first
                                    : '',
                                onCategorySelected: (v) {
                                  Provider.of<HomeUiSwithchRepository>(context,
                                          listen: false)
                                      .loading(true);
                                  print(
                                      'isLoadingCategories$isLoadingCategories');
                                  setState(() {});
                                  Provider.of<HomeUiSwithchRepository>(context,
                                          listen: false)
                                      .switchToType(
                                    UIType.CategoriesSection,
                                  );
                                  Provider.of<HomeRepositoryProvider>(context,
                                          listen: false)
                                      .categoryFilter(
                                    category.name,
                                  )
                                      .then((v) {
                                    Future.delayed(const Duration(seconds: 2))
                                        .then((v) {
                                      Provider.of<HomeUiSwithchRepository>(
                                              context,
                                              listen: false)
                                          .loading(false);
                                    });
                                  });

                                  if (selectedCategory.isNotEmpty) {
                                    selectedCategory.clear();
                                  }
                                  selectedCategory.add(category.name);

                                  // log('selectedCategories==>${selectedCategory.length}');

                                  setState(() {});
                                },
                                text: category.name,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
                Consumer<HomeUiSwithchRepository>(
                  builder: (context, uiState, _) {
                    Widget selectedWidget;

                    switch (uiState.selectedType) {
                      case UIType.SearchSection:
                        selectedWidget = SearchSection(
                          onTapClear: () {
                            searchController.clear();
                            Provider.of<HomeUiSwithchRepository>(context,
                                    listen: false)
                                .switchToDefaultSection();
                            setState(() {});
                          },
                        );
                        break;
                      case UIType.FilterSection:
                        selectedWidget = FilterProducts(
                          onTapClear: () {
                            selectedCategory.clear();
                            // log('selectedCategories==>${selectedCategory.length}');
                            Provider.of<HomeUiSwithchRepository>(context,
                                    listen: false)
                                .switchToDefaultSection();
                            setState(() {});
                          },
                        );
                        break;
                      case UIType.CategoriesSection:
                        print('uiState.isLoading${uiState.isLoading}');
                        selectedWidget = uiState.isLoading == true
                            ? SizedBox(
                                width: MediaQuery.sizeOf(context).width,
                                height: MediaQuery.sizeOf(context).height * 0.3,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                              )
                            : CategoriesSection(
                                onTapClear: () {
                                  selectedCategory.clear();
                                  // log('selectedCategories==>${selectedCategory.length}');
                                  Provider.of<HomeUiSwithchRepository>(context,
                                          listen: false)
                                      .switchToDefaultSection();
                                  setState(() {});
                                },
                              );
                        break;
                      case UIType.DefaultSection:
                        selectedWidget = const DefaultSection();
                        break;
                    }

                    return selectedWidget;
                  },
                ),
                const VerticalSpeacing(40.0)
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar(
      {super.key, required this.searchController, this.onTapFilter});
  final TextEditingController searchController;
  final VoidCallback? onTapFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 46,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColor.boxColor,
        ),
        child: Consumer<HomeRepositoryProvider>(
          builder: (context, viewModel, _) {
            return TextField(
              controller: searchController,
              onChanged: (value) {

                var provider = Provider.of<HomeUiSwithchRepository>(context, listen: false);
                print('Entered UIType: ${provider.selectedType}');

                if (provider.selectedType == UIType.CategoriesSection) {
                  debugPrint('start search categories product');
                  viewModel.searchCategoriesProduct(value.toLowerCase());

                  provider.switchToType(UIType.CategoriesSection);

                } else {
                  if (searchController.text.isNotEmpty) {
                    viewModel.search(
                      searchController.text,
                      viewModel.homeRepository.productsTopRated,
                      viewModel.homeRepository.productsTopOrder,
                      viewModel.homeRepository.productsTopDiscount,
                    );
                    provider.switchToType(UIType.SearchSection);
                  } else {
                    provider.switchToType(UIType.DefaultSection);
                  }
                }

              },
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColor.textColor1,
                ),
                suffixIcon: Container(
                  height: 46.0,
                  width: 46.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: AppColor.primaryColor),
                  child: Center(
                    child: IconButton(
                      onPressed: onTapFilter,
                      //     () {
                      //   Navigator.pushNamed(
                      //     context,
                      //     RoutesName.filter,
                      //   );
                      // },
                      icon: const ImageIcon(
                        AssetImage("images/filter.png"),
                        color: AppColor.whiteColor,
                      ),
                    ),
                  ),
                ),
                hintStyle: GoogleFonts.getFont(
                  "Roboto",
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColor.textColor2,
                  ),
                ),
                border: InputBorder.none,
              ),
            );
          },
        ));
  }
}
