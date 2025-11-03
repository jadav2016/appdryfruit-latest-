import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/res/components/colors.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:rjfruits/utils/routes/routes_name.dart';
import 'package:rjfruits/view/HomeView/widgets/homeCard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rjfruits/view_model/shop_view_model.dart';

import '../../repository/search_section_ui.dart';
import '../../res/components/search_enums.dart';
import '../HomeView/filter_view.dart';
import '../search/default_search_section.dart';
import '../search/filter_search_section.dart';
import '../search/search_Section.dart';

class ShopView extends StatefulWidget {
  final String? limited;

  const ShopView({super.key, this.limited});

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool isLoadingPage = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    SearchUiSwithchRepository type =
        Provider.of<SearchUiSwithchRepository>(context, listen: false);
    type.selectedNewType = SearchUIType.DeaultSearchSection;

    Provider.of<ShopRepositoryProvider>(context, listen: false)
        .getShopProd(context)
        .then((v) {
      setState(() {});
    });
  }

  void _scrollListener() {
    log('Reached Bottom');
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent) {
      log('Reached Bottom');
      updateListData();
    }
  }

  void updateListData() {
    final shopProvider =
        Provider.of<ShopRepositoryProvider>(context, listen: false);

    if (shopProvider.shopRepository.tempShopProducts.isNotEmpty) {
      isLoadingPage = true;
      log('isLoadingPage===>${isLoadingPage}');
      setState(() {});
      Future.delayed(const Duration(seconds: 1)).then((v) {
        // Take 20 or remaining items
        int takeCount =
            shopProvider.shopRepository.tempShopProducts.length >= 20
                ? 20
                : shopProvider.shopRepository.tempShopProducts.length;

        // Add to shopProducts and remove from tempShopProducts
        shopProvider.shopRepository.shopProducts.addAll(
            shopProvider.shopRepository.tempShopProducts.take(takeCount));

        shopProvider.shopRepository.tempShopProducts.removeRange(0, takeCount);
        log(' shopProvider.shopRepository.shopProducts${shopProvider.shopRepository.shopProducts.length}');
        isLoadingPage = false;

        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopRepositoryProvider =
        Provider.of<ShopRepositoryProvider>(context, listen: false);

    String? limited = widget.limited;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          image: DecorationImage(
              image: AssetImage("images/bgimg.png"), fit: BoxFit.cover),
        ),
        child: shopRepositoryProvider.shopRepository.isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                color: AppColor.primaryColor,
              ))
            : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const VerticalSpeacing(30.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                            ),
                            InkWell(
                              child: Text(
                                'Shop',
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
                            const SizedBox(
                              width: 60,
                            )
                            // InkWell(
                            //   onTap: () {
                            //     Navigator.pushNamed(
                            //         context, RoutesName.searchView);
                            //   },
                            //   child: Container(
                            //     height: 31,
                            //     width: 35,
                            //     decoration: BoxDecoration(
                            //       color: AppColor.boxColor,
                            //       borderRadius: BorderRadius.circular(
                            //         4,
                            //       ),
                            //     ),
                            //     child: const Center(
                            //       child: Icon(
                            //         Icons.search,
                            //         color: AppColor.textColor1,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        const VerticalSpeacing(20.0),
                        Consumer<ShopRepositoryProvider>(
                          builder: (context, searchModel, _) {
                            return Row(
                              children: [
                                Container(
                                  height: 46,
                                  width:
                                      MediaQuery.of(context).size.width * 0.88,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: AppColor.boxColor,
                                  ),
                                  child: TextField(
                                    onTapOutside: (v) {
                                      FocusScope.of(context).unfocus();
                                    },
                                    controller: searchController,
                                    // onSubmitted: (value){
                                    //   isLoading = true;
                                    //   setState(() {
                                    //
                                    //   });
                                    //   if (searchController
                                    //       .text.isNotEmpty) {
                                    //     searchModel.search(
                                    //       value,
                                    //     );
                                    //     Provider.of<SearchUiSwithchRepository>(
                                    //         context,
                                    //         listen: false)
                                    //         .switchToType(SearchUIType
                                    //         .SearchSectionUi);
                                    //   } else {
                                    //     Provider.of<SearchUiSwithchRepository>(
                                    //         context,
                                    //         listen: false)
                                    //         .switchToType(SearchUIType
                                    //         .DeaultSearchSection);
                                    //   }
                                    //   Future.delayed(const Duration(seconds: 2)).then((v){
                                    //     isLoading = false;
                                    //     setState(() {
                                    //
                                    //     });
                                    //   });
                                    // },
                                    onChanged: (value) {
                                      isLoading = true;
                                      setState(() {});
                                      if (searchController.text.isNotEmpty) {
                                        searchModel.search(
                                          value,
                                        );
                                        Provider.of<SearchUiSwithchRepository>(
                                                context,
                                                listen: false)
                                            .switchToType(
                                                SearchUIType.SearchSectionUi);
                                      } else {
                                        Provider.of<SearchUiSwithchRepository>(
                                                context,
                                                listen: false)
                                            .switchToType(SearchUIType
                                                .DeaultSearchSection);
                                      }
                                      Future.delayed(const Duration(seconds: 2))
                                          .then((v) {
                                        isLoading = false;
                                        setState(() {});
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search',
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: AppColor.primaryColor,
                                      ),
                                      suffixIcon: Container(
                                        height: 47.0,
                                        width: 47.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            color: AppColor.primaryColor),
                                        child: Center(
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const FilterScreen(
                                                            isComingShop: true,
                                                          )));
                                            },
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
                                  ),
                                ),
                                // SizedBox(
                                //   width: MediaQuery.of(context).size.width / 18,
                                // ),
                                // InkWell(
                                //   onTap: () {
                                //     Navigator.of(context).pop();
                                //     Provider.of<SearchUiSwithchRepository>(context,
                                //         listen: false)
                                //         .switchToType(
                                //         SearchUIType.DeaultSearchSection);
                                //   },
                                //   child: Text(
                                //     'Cancel',
                                //     style: GoogleFonts.getFont(
                                //       "Poppins",
                                //       textStyle: const TextStyle(
                                //         fontSize: 16,
                                //         fontWeight: FontWeight.w800,
                                //         color: AppColor.blackColor,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            );
                          },
                        ),

                        const VerticalSpeacing(10.0),
                        Expanded(
                          child: isLoading == true
                              ? SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.7,
                                  width: MediaQuery.sizeOf(context).width,
                                  child: const Center(
                                      child: CircularProgressIndicator(
                                    color: AppColor.primaryColor,
                                  )))
                              : SingleChildScrollView(
                                  controller: scrollController,
                                  child: Column(
                                    children: [
                                      const VerticalSpeacing(10.0),
                                      Consumer<SearchUiSwithchRepository>(
                                        builder: (BuildContext context,
                                            shopUiRepositoryProvider,
                                            Widget? child) {
                                          return shopUiRepositoryProvider
                                                      .selectedType ==
                                                  SearchUIType
                                                      .DeaultSearchSection
                                              ? Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                            width: 10.0),
                                                        Text.rich(
                                                          textAlign:
                                                              TextAlign.start,
                                                          TextSpan(
                                                            text:
                                                                '${shopRepositoryProvider.shopRepository.productLength} Found Items ',
                                                            // '${shopRepositoryProvider.shopRepository.shopProducts.length} Fund Items ',
                                                            style: const TextStyle(
                                                                fontSize: 14.0,
                                                                color: AppColor
                                                                    .cardTxColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                            children: const [
                                                              TextSpan(
                                                                text:
                                                                    'Fresh Fruit Dry Fruit',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14.0,
                                                                    color: AppColor
                                                                        .primaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              : SizedBox();
                                        },
                                      ),
                                      Consumer<SearchUiSwithchRepository>(
                                        builder: (context, uiState, _) {
                                          log('SearchUIType==>${uiState.selectedType}');
                                          Widget selectedWidget;

                                          switch (uiState.selectedType) {
                                            case SearchUIType.SearchSectionUi:
                                              selectedWidget = SearchSectionUi(
                                                limited: limited,
                                              );
                                              break;
                                            case SearchUIType
                                                  .FilterSearchSection:
                                              selectedWidget =
                                                  FilterSearchSection(
                                                limited: limited,
                                                onTapClear: () {
                                                  Provider.of<SearchUiSwithchRepository>(
                                                          context,
                                                          listen: false)
                                                      .switchToDefaultSection();
                                                  setState(() {});
                                                },
                                              );
                                              break;

                                            case SearchUIType
                                                  .DeaultSearchSection:
                                              selectedWidget =
                                                  DeaultSearchSection(
                                                limited: limited,
                                                shopProducts:
                                                    shopRepositoryProvider
                                                        .shopRepository
                                                        .shopProducts,
                                              );
                                              break;
                                          }

                                          return selectedWidget;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                        )

                        // Padding(
                        //   padding: const EdgeInsets.only(bottom: 60),
                        //   child: Consumer<ShopRepositoryProvider>(
                        //     builder: (context, shopRepositoryProvider, _) {
                        //       return GridView.count(
                        //         padding: const EdgeInsets.only(
                        //             left: 5,
                        //             right: 5,
                        //           bottom: 20
                        //            ), // Add padding around the grid
                        //         shrinkWrap: true,
                        //         physics: const NeverScrollableScrollPhysics(),
                        //         crossAxisCount: 2,
                        //         childAspectRatio: (180 / 255),
                        //         mainAxisSpacing: 10.0, // Spacing between rows
                        //         crossAxisSpacing: 10.0, // Spacing between columns
                        //         children: List.generate(
                        //           shopRepositoryProvider
                        //               .shopRepository.shopProducts.length,
                        //           (index) => HomeCard(
                        //             isdiscount: false,
                        //             title: shopRepositoryProvider
                        //                 .shopRepository.shopProducts[index].title,
                        //             image: shopRepositoryProvider.shopRepository
                        //                 .shopProducts[index].thumbnailImage,
                        //             discount: shopRepositoryProvider
                        //                 .shopRepository
                        //                 .shopProducts[index]
                        //                 .discountedPrice
                        //                 .toString(),
                        //             proId: shopRepositoryProvider
                        //                 .shopRepository.shopProducts[index].id
                        //                 .toString(),
                        //             price: shopRepositoryProvider.shopRepository
                        //                 .shopProducts[index].priceWithTax
                        //                 .toStringAsFixed(0),
                        //             averageReview: shopRepositoryProvider
                        //                 .shopRepository
                        //                 .shopProducts[index]
                        //                 .averageReview
                        //                 .toString(),
                        //             // Pass other data properties here
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: isLoadingPage == true
                        ? Container(
                            color: Colors.white,
                            height: 60,
                            width: 20,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColor.primaryColor,
                              ),
                            ))
                        : SizedBox(),
                  )
                ],
              ),
      ),
    );
  }
}
