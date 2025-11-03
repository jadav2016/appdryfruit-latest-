import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/res/components/colors.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:rjfruits/view/HomeView/widgets/homeCard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rjfruits/view_model/home_view_model.dart';
import 'package:shimmer/shimmer.dart';

class BestWeeks extends StatefulWidget {
  const BestWeeks({super.key});

  @override
  State<BestWeeks> createState() => _BestWeeksState();
}

class _BestWeeksState extends State<BestWeeks> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Add a slight delay to show loading state
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          image: DecorationImage(
              image: AssetImage("images/bgimg.png"), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const VerticalSpeacing(30.0),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColor.appBarTxColor,
                        ),
                      ),
                      const SizedBox(width: 40.0),
                      Text(
                        'Best Deals of The Week!',
                        style: GoogleFonts.getFont(
                          "Poppins",
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColor.appBarTxColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const VerticalSpeacing(20.0),
                  Consumer<HomeRepositoryProvider>(
                      builder: (context, homeRepo, child) {
                        // Check for our local loading state first
                        if (_isLoading) {
                          return GridView.count(
                            padding: const EdgeInsets.all(5.0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: (180 / 270),
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            children: List.generate(
                              2,
                                  (index) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: const HomeCard(
                                  isdiscount: true,
                                  averageReview: "4",
                                ),
                              ),
                            ),
                          );
                        } else if (homeRepo.homeRepository.productsBestWeek.isEmpty) {
                          // Handle empty list case (after loading is complete)
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.6, // adjust height for visual center
                            alignment: Alignment.center,
                            child: const Text(
                              'No deals available this week',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          );
                        } else {
                          // Show data when available
                          return GridView.count(
                            padding: const EdgeInsets.all(5.0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: (180 / 270),
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            children: List.generate(
                              homeRepo.homeRepository.productsBestWeek.length,
                                  (index) => HomeCard(
                                isdiscount: false,
                                image: homeRepo.homeRepository
                                    .productsBestWeek[index].thumbnailImage,
                                discount: homeRepo.homeRepository
                                    .productsBestWeek[index].discountedPrice
                                    .toString(),
                                title: homeRepo
                                    .homeRepository.productsBestWeek[index].title,
                                price: homeRepo
                                    .homeRepository.productsBestWeek[index].price
                                    .toString(),
                                proId: homeRepo
                                    .homeRepository.productsBestWeek[index].id
                                    .toString(),
                                averageReview: homeRepo.homeRepository
                                    .productsBestWeek[index].averageReview
                                    .toString(),
                              ),
                            ),
                          );
                        }
                      })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}