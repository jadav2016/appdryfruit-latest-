import 'package:custom_image_view/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/res/components/cart_button.dart';
import 'package:rjfruits/res/components/colors.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:rjfruits/utils/routes/routes_name.dart';
import 'package:rjfruits/view/HomeView/product_detail_view.dart';
import 'package:rjfruits/view/HomeView/widgets/homeCard.dart';
import 'package:rjfruits/view_model/home_view_model.dart';
import 'package:intl/intl.dart';
import '../../view_model/product_detail_view_model.dart';

class DefaultSection extends StatefulWidget {
  const DefaultSection({super.key});

  @override
  State<DefaultSection> createState() => _DefaultSectionState();
}

class _DefaultSectionState extends State<DefaultSection> {
  @override
  void initState() {
    Provider.of<HomeRepositoryProvider>(context, listen: false).getHomeProd(
      context,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // const VerticalSpeacing(5.0),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Container(
            padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0),
            width: MediaQuery.sizeOf(context).width,
            // decoration: BoxDecoration(
            //     color: AppColor.primaryColor.withValues(alpha: 0.8)
            // ),
            child: Text(
              'Offers',
              style: GoogleFonts.getFont(
                "Roboto",
                color: AppColor.blackColor,
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const VerticalSpeacing(4.0),
        Consumer<HomeRepositoryProvider>(
            builder: (context, homeRepo, child) {
              return SizedBox(
                height: 300,
                child: ListView.builder(
                    padding: const EdgeInsets.only(right: 15, left: 15),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: homeRepo.homeRepository.offerProducts.length,
                    itemBuilder: (context, index) {
                      var data = homeRepo.homeRepository.offerProducts[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 10, left: 10),
                        child: Stack(
                          children: [
                            CustomImageView(
                              height: 300,
                              width: MediaQuery.sizeOf(context).width * 0.8,
                              url: data.thumbnailImage,
                              fit: BoxFit.contain,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                      color:
                                      Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,


                                      offset: const Offset(0, 0))
                                ]),
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          data.title ?? '',
                                          style: GoogleFonts.getFont(
                                            "Roboto",
                                            color: AppColor.textColor1,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: AppColor.primaryColor,
                                              size: 18,
                                            ),
                                            Text(
                                              data.averageReview
                                                  ?.toStringAsFixed(1) ??
                                                  '',
                                              style: GoogleFonts.getFont(
                                                "Roboto",
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '₹${data.price?.toStringAsFixed(2)}',
                                          style: GoogleFonts.getFont(
                                            "Roboto",
                                            textStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.cardTxColor,
                                            ),
                                            decoration:
                                            TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '₹${data.discountedPrice?.toStringAsFixed(2)}',
                                          style: GoogleFonts.getFont(
                                            "Roboto",
                                            color: AppColor.textColor1,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () {


                                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ProductDetailScreen(productId:data.id.toString() )));
                                            // final productDetailsProvider = Provider
                                            //     .of<ProductRepositoryProvider>(
                                            //     context,
                                            //     listen: false);
                                            // productDetailsProvider
                                            //     .fetchProductDetails(
                                            //   context,
                                            //   data.id.toString(),
                                            // );
                                          },
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height /
                                                30,
                                            width: 70.0,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(30.0),
                                                color: AppColor.primaryColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color.fromARGB(
                                                        255, 0, 0, 0)
                                                        .withOpacity(
                                                        0.25), // Shadow color
                                                    blurRadius:
                                                    8.1, // Blur radius
                                                    spreadRadius:
                                                    0, // Spread radius
                                                    offset: const Offset(
                                                        0, 4), // Offset
                                                  ),
                                                ]),
                                            child: Center(
                                              child: Text(
                                                'View',
                                                style: GoogleFonts.getFont(
                                                  "Roboto",
                                                  color: AppColor.whiteColor,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  // height: 40,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration:
                                  const BoxDecoration(color: Colors.red),
                                  child: Text(
                                    '${data.discount?.toStringAsFixed(0)}% Off',
                                    style: GoogleFonts.getFont(
                                      "Roboto",
                                      color: AppColor.whiteColor,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      );
                    }),
              );
            }),
        // const VerticalSpeacing(12.0),

        ///          =========       ////

        const VerticalSpeacing(6.0),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Container(
            padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0),
            width: MediaQuery.sizeOf(context).width,
            // decoration: BoxDecoration(
            //     color: AppColor.primaryColor.withValues(alpha: 0.8)),
            child: Text(
              'Festival special',
              style: GoogleFonts.getFont(
                "Roboto",
                color: AppColor.blackColor,
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const VerticalSpeacing(4.0),
        Consumer<HomeRepositoryProvider>(
            builder: (context, homeRepo, child) {
              return SizedBox(
                height: 300,
                child: ListView.builder(
                    padding: const EdgeInsets.only(right: 13, left: 13),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: homeRepo.homeRepository.festivalSpecial.length,
                    itemBuilder: (context, index) {
                      var data = homeRepo.homeRepository.festivalSpecial[index];
                      return Container(
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        margin: const EdgeInsets.only(right: 10, left: 10),
                        child: Stack(
                          children: [
                            CustomImageView(
                              height: 330,
                              width: MediaQuery.sizeOf(context).width ,
                              url: data.thumbnailImage,
                              fit: BoxFit.contain,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                // margin: const EdgeInsets.only(right: 5, left: 5),
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                      color:
                                      Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,


                                      offset: const Offset(0, 0))
                                ]),
                                padding:
                                const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          data.title ?? '',
                                          style: GoogleFonts.getFont(
                                            "Roboto",
                                            color: AppColor.textColor1,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: AppColor.primaryColor,
                                              size: 18,
                                            ),
                                            Text(
                                              data.averageReview
                                                  ?.toStringAsFixed(1) ??
                                                  '',
                                              style: GoogleFonts.getFont(
                                                "Roboto",
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '₹${data.price?.toStringAsFixed(2)}',
                                          style: GoogleFonts.getFont(
                                            "Roboto",
                                            textStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.cardTxColor,
                                            ),
                                            decoration:
                                            TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '₹${data.discountedPrice?.toStringAsFixed(2)}',
                                          style: GoogleFonts.getFont(
                                            "Roboto",
                                            color: AppColor.textColor1,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ProductDetailScreen(productId:data.id.toString() )));

                                            // final productDetailsProvider = Provider
                                            //     .of<ProductRepositoryProvider>(
                                            //     context,
                                            //     listen: false);
                                            // productDetailsProvider
                                            //     .fetchProductDetails(
                                            //   context,
                                            //   data.id.toString(),
                                            // );
                                          },
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height /
                                                28,
                                            width: 70.0,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(30.0),
                                                color: AppColor.primaryColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color.fromARGB(
                                                        255, 0, 0, 0)
                                                        .withOpacity(
                                                        0.25), // Shadow color
                                                    blurRadius:
                                                    8.1, // Blur radius
                                                    spreadRadius:
                                                    0, // Spread radius
                                                    offset: const Offset(
                                                        0, 4), // Offset
                                                  ),
                                                ]),
                                            child: Center(
                                              child: Text(
                                                'View',
                                                style: GoogleFonts.getFont(
                                                  "Roboto",
                                                  color: AppColor.whiteColor,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  // height: 40,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration:
                                  const BoxDecoration(color: Colors.red),
                                  child: Text(
                                    '${data.discount?.toStringAsFixed(0)}% Off',
                                    style: GoogleFonts.getFont(
                                      "Roboto",
                                      color: AppColor.whiteColor,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      );
                    }),
              );
            }),
        const VerticalSpeacing(10.0),

        ///          =========       ////

        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Categories',
                style: GoogleFonts.getFont(
                  "Roboto",
                  color: AppColor.textColor1,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              CartButton(
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.popularItems);
                  },
                  text: 'View All'),
            ],
          ),
        ),

        const VerticalSpeacing(12.0),
        Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Consumer<HomeRepositoryProvider>(
                builder: (context, homeRepo, child) {
              if (homeRepo.homeRepository.productsTopOrder.isEmpty) {
                return GridView.count(
                  padding: const EdgeInsets.all(5.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: (180 / 280),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  children: List.generate(
                    2,
                    (index) => Center(
                      child: Text(
                        'No Products to show',
                        style: GoogleFonts.getFont(
                          "Roboto",
                          color: AppColor.textColor1,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return GridView.count(
                  padding: const EdgeInsets.all(5.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: (180 / 290),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  children: List.generate(
                    // Limit to only two items
                    homeRepo.homeRepository.productsTopOrder.length > 2
                        ? 2
                        : homeRepo.homeRepository.productsTopOrder.length,
                    (index) => HomeCard(
                      isdiscount: false,
                      image: homeRepo.homeRepository.productsTopOrder[index]
                          .thumbnailImage,
                      discount: homeRepo.homeRepository.productsTopOrder[index]
                          .discountedPrice
                          .toString(),
                      title:
                          homeRepo.homeRepository.productsTopOrder[index].title,
                      price: homeRepo
                          .homeRepository.productsTopOrder[index].price
                          .toString(),
                      proId: homeRepo.homeRepository.productsTopOrder[index].id
                          .toString(),
                      averageReview: homeRepo
                          .homeRepository.productsTopOrder[index].averageReview
                          .toString(),
                    ),
                  ),
                );
              }
            })),
        // const VerticalSpeacing(12.0),
        // Padding(
        //     padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        //     child: Consumer<HomeRepositoryProvider>(
        //         builder: (context, homeRepo, child) {
        //      return
        //     })),
        const VerticalSpeacing(16.0),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Best Sellers',
                style: GoogleFonts.getFont(
                  "Roboto",
                  color: AppColor.textColor1,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              CartButton(
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.bestSellers);
                  },
                  text: 'View All'),
            ],
          ),
        ),
        const VerticalSpeacing(12.0),
        Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Consumer<HomeRepositoryProvider>(
                builder: (context, homeRepo, child) {
              if (homeRepo.homeRepository.productsTopRated.isEmpty) {
                return GridView.count(
                  padding: const EdgeInsets.all(5.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: (180 / 290),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  children: List.generate(
                    2,
                    (index) => Center(
                      child: Text(
                        'No Products to show',
                        style: GoogleFonts.getFont(
                          "Roboto",
                          color: AppColor.textColor1,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return GridView.count(
                  padding: const EdgeInsets.all(5.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: (180 / 290),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  children: List.generate(
                    // Limit to only two items
                    homeRepo.homeRepository.productsTopRated.length > 2
                        ? 2
                        : homeRepo.homeRepository.productsTopRated.length,
                    (index) => HomeCard(
                      isdiscount: false,
                      image: homeRepo.homeRepository.productsTopRated[index]
                          .thumbnailImage,
                      discount: homeRepo.homeRepository.productsTopRated[index]
                          .discountedPrice
                          .toString(),
                      title:
                          homeRepo.homeRepository.productsTopRated[index].title,
                      price: homeRepo
                          .homeRepository.productsTopRated[index].price
                          .toString(),
                      proId: homeRepo.homeRepository.productsTopRated[index].id
                          .toString(),
                      averageReview: homeRepo
                          .homeRepository.productsTopOrder[index].averageReview
                          .toString(),
                    ),
                  ),
                );
              }
            })),
        const VerticalSpeacing(12.0),
        // const VerticalSpeacing(16.0),
        // //DisCount Cart
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Most Sales',
                style: GoogleFonts.getFont(
                  "Roboto",
                  color: AppColor.textColor1,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              CartButton(
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.discountProd);
                  },
                  text: 'View All'),
            ],
          ),
        ),
        const VerticalSpeacing(12.0),
        Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Consumer<HomeRepositoryProvider>(
                builder: (context, homeRepo, child) {
              if (homeRepo.homeRepository.productsTopDiscount.isEmpty) {
                return GridView.count(
                  padding: const EdgeInsets.all(5.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: (180 / 260),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  children: List.generate(
                    2,
                    (index) => Center(
                      child: Text(
                        'No Products to show',
                        style: GoogleFonts.getFont(
                          "Roboto",
                          color: AppColor.textColor1,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return GridView.count(
                  padding: const EdgeInsets.all(5.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: (180 / 320),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  children: List.generate(
                    // Limit to only two items
                    homeRepo.homeRepository.productsTopDiscount.length > 2
                        ? 2
                        : homeRepo.homeRepository.productsTopDiscount.length,
                    (index) => HomeCard(
                      disPercantage: homeRepo
                          .homeRepository.productsTopDiscount[index].discount
                          .toString(),
                      isdiscount: true,
                      image: homeRepo.homeRepository.productsTopDiscount[index]
                          .thumbnailImage,
                      discount: homeRepo.homeRepository
                          .productsTopDiscount[index].discountedPrice
                          .toString(),
                      title: homeRepo
                          .homeRepository.productsTopDiscount[index].title,
                      price: homeRepo
                          .homeRepository.productsTopDiscount[index].price
                          .toString(),
                      proId: homeRepo
                          .homeRepository.productsTopDiscount[index].id
                          .toString(),
                      averageReview: homeRepo
                          .homeRepository.productsTopOrder[index].averageReview
                          .toString(),
                    ),
                  ),
                );
              }
            })),
        const VerticalSpeacing(16.0),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Best Deals of The Week!',
                style: GoogleFonts.getFont(
                  "Roboto",
                  color: AppColor.textColor1,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              CartButton(
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.bestWeeks);
                  },
                  text: 'View All'),
            ],
          ),
        ),
        const VerticalSpeacing(12.0),
        Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Consumer<HomeRepositoryProvider>(
                builder: (context, homeRepo, child) {
                  if (homeRepo.homeRepository.productsBestWeek.isEmpty) {
                    return GridView.count(
                      padding: const EdgeInsets.all(5.0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: (180 / 280),
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      children: List.generate(
                        2,
                            (index) => Center(
                          child: Text(
                            'No Products to show',
                            style: GoogleFonts.getFont(
                              "Roboto",
                              color: AppColor.textColor1,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
                        homeRepo.homeRepository.productsBestWeek.length > 2
                            ? 2
                            : homeRepo.homeRepository.productsBestWeek.length,
                            (index) => HomeCard(
                          isdiscount: false,
                          image: homeRepo.homeRepository.productsBestWeek[index]
                              .thumbnailImage,
                          discount: homeRepo.homeRepository.productsBestWeek[index]
                              .discountedPrice
                              .toString(),
                          title:
                          homeRepo.homeRepository.productsBestWeek[index].title,
                          price: homeRepo
                              .homeRepository.productsBestWeek[index].price
                              .toString(),
                          proId: homeRepo.homeRepository.productsBestWeek[index].id
                              .toString(),
                          averageReview: homeRepo
                              .homeRepository.productsBestWeek[index].averageReview
                              .toString(),
                          timer: DateFormat('d MMMM, y, h:mm a').format(DateTime.parse(homeRepo.homeRepository.productsBestWeek[index].productDealExpireAt.toString()).toLocal()),

                        ),
                      ),
                    );
                  }
                })),
      ],
    );
  }
}
