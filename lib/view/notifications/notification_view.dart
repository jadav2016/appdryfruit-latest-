import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/view/notifications/Widgets/notification_widget.dart';
import '../../model/notification_response_modal.dart';
import '../../res/components/colors.dart';
import '../../res/components/vertical_spacing.dart';
import '../../res/const/response_handler.dart';
import 'package:http/http.dart' as http;

import '../../view_model/user_view_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> allNotificationList = <NotificationItem>[];
  bool isLoading = false;

  Future getNotifications() async {
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    final userModel = await userPreferences.getUser();
    final token = userModel.key;
    isLoading = true;
    setState(() {});
    const String url = 'https://rajasthandryfruitshouse.com/c/notifications/';
    // 'https://rajasthandryfruitshouse.com/inbox/notifications/api/all_list/';
    final Map<String, String> headers = {
      'accept': 'application/json',
      'authorization': 'Token $token',
      'X-CSRFToken':
          'kRWqrSSxl1EedHHJNQuWBmGofniQ1XU0uwnaLZbEf3RnSEO6y7nKl4NuQADOpUgw',
      // 'nj894MH3DSYYTqMCddseRqdyQifXPRGgv5BU8lebgolcNfg3ssuTZy1pZYnwlxuI',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      debugPrint("this is the response product details: ${response.body}");
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        debugPrint('detail works');
        List<NotificationItem> fetchedOrders = jsonResponse
            .map((item) => NotificationItem.fromJson(item))
            .toList();
        allNotificationList = fetchedOrders;
      } else {
        throw Exception('Failed to load product detail');
      }
    } catch (e) {
      debugPrint("this is the error:$e");
      handleApiError(e, context);
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  Future readNotifications() async {
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    final userModel = await userPreferences.getUser();
    final token = userModel.key;
    isLoading = true;
    setState(() {});
    const String url = 'https://rajasthandryfruitshouse.com/c/notifications/';
    // 'https://rajasthandryfruitshouse.com/inbox/notifications/api/all_list/';
    final Map<String, String> headers = {
      'accept': 'application/json',
      'authorization': 'Token $token',
      'X-CSRFToken':
          'kRWqrSSxl1EedHHJNQuWBmGofniQ1XU0uwnaLZbEf3RnSEO6y7nKl4NuQADOpUgw',
      // 'nj894MH3DSYYTqMCddseRqdyQifXPRGgv5BU8lebgolcNfg3ssuTZy1pZYnwlxuI',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      debugPrint("this is the response product details: ${response.body}");
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        debugPrint('detail works');
        List<NotificationItem> fetchedOrders = jsonResponse
            .map((item) => NotificationItem.fromJson(item))
            .toList();
        allNotificationList = fetchedOrders;
      } else {
        throw Exception('Failed to load product detail');
      }
    } catch (e) {
      debugPrint("this is the error:$e");
      handleApiError(e, context);
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  Future resetCount() async{
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    await userPreferences.resetCount();
  }

  @override
  void initState() {
    super.initState();
    resetCount();
    getNotifications();
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
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const VerticalSpeacing(20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.west,
                          color: AppColor.appBarTxColor,
                        ),
                      ),
                      Text(
                        'Notifications',
                        style: GoogleFonts.getFont(
                          "Poppins",
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColor.appBarTxColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 50.0),
                    ],
                  ),
                  isLoading == true
                      ? SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.8,
                          width: MediaQuery.sizeOf(context).width,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColor.primaryColor,
                            ),
                          ),
                        )
                      :

                      // allNotificationList.isEmpty ?
                      //     SizedBox(
                      //       height: MediaQuery.sizeOf(context).height*0.75,
                      //       child: const Center(
                      //         child: Text('No notifications',style: TextStyle(
                      //           fontWeight: FontWeight.w500,
                      //           color: AppColor.blackColor,
                      //           fontSize: 18.0,
                      //         ),),
                      //       ),
                      //     )
                      //     :

                      ListView.builder(
                          itemCount: allNotificationList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10.0), // Spacing between rows
                              child: SizedBox(
                                height: 120.0,
                                width: MediaQuery.of(context).size.width,
                                child: NotificationWidget(
                                  data: allNotificationList[index],
                                ),
                              ),
                            );
                          },
                        )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
