// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:rjfruits/model/product_detail_model.dart';
import 'package:rjfruits/view/total_review/widgets/review_card.dart';

import '../../res/components/colors.dart';
import '../../res/components/vertical_spacing.dart';

class TotalRatingScreen extends StatefulWidget {
  final List<ProductReview> reviews;
  final String averageReview;
  final String totalReviews;
  final int oneStar;
  final int twoStar;
  final int threeStar;
  final int fourStar;
  final int fiveStar;
  const TotalRatingScreen({
    super.key,
    required this.reviews,
    required this.averageReview,
    required this.totalReviews,
    required this.oneStar,
    required this.twoStar,
    required this.threeStar,
    required this.fourStar,
    required this.fiveStar,
  });
  @override
  State<TotalRatingScreen> createState() => _TotalRatingScreenState();
}

class _TotalRatingScreenState extends State<TotalRatingScreen> {
  int totalRating = 0;

  @override
  void initState() {
    super.initState();
    totalRating = widget.oneStar + widget.twoStar + widget.threeStar + widget.fourStar + widget.fiveStar;
  }

  double calculatePercent(int count) {
    return (totalRating > 0) ? (count / totalRating).clamp(0.0, 1.0) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.west,
              color: AppColor.textColor1,
            )),
        title: const Text(
          "Reviews",
          style: TextStyle(
            fontFamily: 'CenturyGothic',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: AppColor.textColor1,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          image: DecorationImage(
              image: AssetImage("images/bgimg.png"), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    color: AppColor.primaryColor,
                    child: Center(
                      child: Text(
                        widget.averageReview,
                        style: const TextStyle(
                          fontFamily: 'CenturyGothic',
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: AppColor.whiteColor,
                        ),
                      ),
                    ),
                  ),
                  const VerticalSpeacing(10),
                  Text(
                    "${widget.averageReview} reviews",
                    style: const TextStyle(
                      fontFamily: 'CenturyGothic',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColor.textColor1,
                    ),
                  ),
                  const VerticalSpeacing(20.0),
                  Column(
                    children: [
                      ratingRow("5 stars", widget.fiveStar),
                      ratingRow("4 stars", widget.fourStar),
                      ratingRow("3 stars", widget.threeStar),
                      ratingRow("2 stars", widget.twoStar),
                      ratingRow("1 star", widget.oneStar),
                    ],
                  ),
                ],
              ),
              const Divider(),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.5,
                child: ListView.separated(
                  itemCount: widget.reviews.length,
                  itemBuilder: (context, index) {
                    final review = widget.reviews[index];
                    return ReviewCard(
                      profilePic: review.client.profileImage ??
                          'https://t4.ftcdn.net/jpg/03/64/21/11/360_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg',
                      name: review.client.username,
                      rating: review.rate.toString(),
                      time: review.createdOn,
                      comment: review.comment,
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget ratingRow(String label, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'CenturyGothic',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.cardTxColor,
          ),
        ),
        LinearPercentIndicator(
          animation: true,
          animationDuration: 1000,
          width: MediaQuery.of(context).size.width / 1.5,
          percent: calculatePercent(count),
          progressColor: AppColor.primaryColor,
          backgroundColor: Colors.grey.shade300,
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            fontFamily: 'CenturyGothic',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.cardTxColor,
          ),
        ),
      ],
    );
  }
}
