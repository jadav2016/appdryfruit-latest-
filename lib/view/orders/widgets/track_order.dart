import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:order_tracker/order_tracker.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/model/order_detailed_model.dart';
import 'package:rjfruits/utils/routes/utils.dart';
import 'package:rjfruits/view/checkOut/widgets/invoice_screen.dart';
import 'package:rjfruits/view/orders/myorders.dart';
import 'package:rjfruits/view/orders/widgets/prod_detail_widget.dart';
import 'package:rjfruits/view_model/service/track_order_view_model.dart';
import 'package:rjfruits/view_model/user_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../res/components/colors.dart';
import '../../../res/components/vertical_spacing.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class TrackOrder extends StatefulWidget {
  final OrderDetailedModel orderDetailModel;
  final String? shipRocketId;
  final String customShipId;
  const TrackOrder(
      {super.key,
        required this.orderDetailModel,
        required this.shipRocketId,
        required this.customShipId});

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  bool isLoading = true;  // Flag to track loading state

  Status mapOrderStatusToEnum(String orderStatus) {
    switch (orderStatus.toLowerCase()) {
      case 'approved':
        return Status.shipped;
      case 'delivery':
        return Status.outOfDelivery;
      case 'completed':
        return Status.delivered;
      case 'pending':
      case 'cancelled':
      default:
        return Status.order;
    }
  }
  List<TextDto> orderList = [];

  final bool isTrue = true;

  void _openWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/8141066633");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> cancelOrder(String orderId) async {
    print('CancelOrder called with orderId: $orderId');  // <-- Debug print here

    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    final userModel = await userPreferences.getUser();
    final token = userModel.key;
    const csrfToken = 'b9pqcOKunanYdHklY0l2p337ishh9W0fFsuq6Ir8j5ecI1jiw1WLjH3leZH5nQ6P';

    final url = Uri.parse('https://rajasthandryfruitshouse.com/api/order/$orderId/cancel');
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Token $token',
      'X-CSRFToken': csrfToken
    };

    try {
      setState(() {
        isLoading = true;  // Show loading while cancelling
      });

      final response = await http.post(url, headers: headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        Utils.toastMessage("Order cancelled successfully.");
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        Utils.toastMessage("Failed to cancel order: ${response.statusCode}");

      }
    } catch (e) {
      Utils.toastMessage("Error cancelling order: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;  // Hide loading when done
        });
      }
    }
  }


  Future<void> _downloadInvoice(String orderId) async {
    final url = Uri.parse(
        'https://rajasthandryfruitshouse.com/api/order/$orderId/invoice/');

    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    final userModel = await userPreferences.getUser();
    final token = userModel.key;

    try {
      print('Fetching invoice for order ID: $orderId');
      print('Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'X-CSRFTOKEN': '5qY7IxpAe9zqdk0bNJNYScdbLnTBSRmud0Xq7w7yeaJF0YNPXK8NKgBU1MkT6bLZ',
          'authorization': "Token $token",
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Content-Type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/invoice_$orderId.pdf';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print('Invoice saved to: $filePath');

        // Open the file using native "Open With" dialog
        final result = await OpenFile.open(filePath);
        print('OpenFile result: ${result.message}');
      } else {
        print('Failed to download invoice. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error downloading invoice: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _getUserData() async {
    try {
      // Fetch the user preferences without listening to changes
      final userPreferences = Provider.of<UserViewModel>(context, listen: false);
      final userModel = await userPreferences.getUser();
      final token = userModel.key;

      // Ensure widget.shipRocketId is handled correctly as a String
      final shipRocketId = widget.shipRocketId;
      final customShipId = widget.customShipId.toString();

      // Debug print the IDs to verify their values
      debugPrint('customShipId: $customShipId');
      debugPrint('shipRocketId: $shipRocketId (${shipRocketId.runtimeType})');
      Provider.of<TrackOrderRepositoryProvider>(context, listen: false).clearData();

      // Determine which API call to make based on the presence of shipRocketId
      if (shipRocketId == null || shipRocketId.isEmpty || shipRocketId == 'null') {
        debugPrint('Calling customShip with customShipId: $customShipId');
        await Provider.of<TrackOrderRepositoryProvider>(context, listen: false)
            .customShip(customShipId, token);
      } else {
        debugPrint('Calling fetchShipData with shipRocketId: $shipRocketId');
        await Provider.of<TrackOrderRepositoryProvider>(context, listen: false)
            .fetchShipData(shipRocketId!, token);
      }

      // Set loading to false after fetching data
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      setState(() {
        isLoading = false;  // Ensure loading is stopped even in case of error
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserData();
    });
    super.initState();
  }

  @override
  void dispose() {
    // Clear the provider data when the page is disposed
    Provider.of<TrackOrderRepositoryProvider>(context, listen: false).clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackOrder = context.watch<TrackOrderRepositoryProvider>();

    debugPrint("this is track order: ${trackOrder.trackOrderRepositoryProvider.shippedList.map((item) => item.toString()).join(', ')}");
    debugPrint("this is ship id${widget.shipRocketId}");

    DateTime now = widget.orderDetailModel.createdOn;
    String formattedDate = DateFormat("E, d'th' MMM ''yy - hh:mma").format(now);
    orderList.clear();
    orderList.insert(
      0,
      TextDto("Your order has been placed", formattedDate),
    );
    Status orderStatusEnum = mapOrderStatusToEnum(widget.orderDetailModel.orderStatus);

    String addEllipsis(String text, int maxLength) {
      if (text.length <= maxLength) {
        return text;
      } else {
        return '${text.substring(0, maxLength)}...';
      }
    }

    debugPrint('order status ${widget.orderDetailModel.orderStatus}');
    debugPrint('order items: ${jsonEncode(widget.orderDetailModel)}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: const Text(
          'My Order Details ',
          style: TextStyle(
            fontFamily: 'CenturyGothic',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: AppColor.blackColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyOrders()),
              );
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColor.blackColor,
            )),
      ),
      body: isLoading  // Check loading state
          ? Center(
        child: CircularProgressIndicator(),  // Show loading spinner
      )
          : Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          image: DecorationImage(
              image: AssetImage("images/bgimg.png"), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VerticalSpeacing(20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      addEllipsis(
                        widget.orderDetailModel.orderItems[0].product.id
                            .toString(),
                        20, // Maximum length before adding ellipsis
                      ),
                      style: const TextStyle(
                        fontFamily: 'CenturyGothic',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.blackColor,
                      ),
                    ),
                  ],
                ),
                OrderTracker(
                  status: orderStatusEnum,
                  activeColor: AppColor.primaryColor,
                  inActiveColor: Colors.grey[300],
                  orderTitleAndDateList: orderList,
                  subDateTextStyle: const TextStyle(
                    color: AppColor.textColor1,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                  ),
                  shippedTitleAndDateList:
                  trackOrder.trackOrderRepositoryProvider.shippedList,
                  outOfDeliveryTitleAndDateList:
                  trackOrder.trackOrderRepositoryProvider.outOfDeliveryList,
                  deliveredTitleAndDateList:
                  trackOrder.trackOrderRepositoryProvider.deliveredList,
                  headingDateTextStyle:
                  const TextStyle(color: Colors.transparent),
                ),
                const VerticalSpeacing(30.0),
                const Text(
                  'Delivery Details',
                  style: TextStyle(
                    fontFamily: 'CenturyGothic',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColor.blackColor,
                  ),
                ),
                const VerticalSpeacing(12.0),

                GestureDetector(
                  onTap: () async {
                    final url = trackOrder.trackOrderRepositoryProvider.trackingUrl;
                    if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    'Track URL: ${trackOrder.trackOrderRepositoryProvider.trackingUrl.isEmpty ? 'Not Available Yet' : trackOrder.trackOrderRepositoryProvider.trackingUrl}',
                    style: const TextStyle(
                      color: AppColor.textColor1,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.0,
                      decoration: TextDecoration.underline, // looks like a link
                    ),
                  ),
                ),
                const VerticalSpeacing(12.0),

                Text(
                  'Courier Name: ${trackOrder.trackOrderRepositoryProvider.deliveryCompany.isEmpty ? 'Not Available Yet' : trackOrder.trackOrderRepositoryProvider.deliveryCompany}',
                  style: const TextStyle(
                    color: AppColor.textColor1,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                  ),
                ),
                const VerticalSpeacing(12.0),

                Text(
                  'Destination: ${trackOrder.trackOrderRepositoryProvider.destination.isEmpty ? 'Not Available Yet' : trackOrder.trackOrderRepositoryProvider.destination}',
                  style: const TextStyle(
                    color: AppColor.textColor1,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TrackingId: ${addEllipsis(
                        trackOrder.trackOrderRepositoryProvider.trackingId.toString(),
                        30, // Maximum length before adding ellipsis
                      )}',
                      style: const TextStyle(
                        color: AppColor.textColor1,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.0,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text: trackOrder
                                  .trackOrderRepositoryProvider.trackingId));
                          Utils.toastMessage("Text copied to clipboard");
                        },
                        icon: const Icon(
                          Icons.copy,
                          size: 18,
                        ))
                  ],
                ),


                const VerticalSpeacing(20.0),
                widget.orderDetailModel.orderStatus.toLowerCase() == 'cancelled'
                    ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Order Canceled',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancel Order'),
                        content:
                        const Text('Are you sure you want to cancel this order?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await cancelOrder(widget.orderDetailModel.id.toString());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 48), // full width, fixed height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Cancel Order',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),

                const VerticalSpeacing(20.0),

                Text(
                  'Note:After cancel order share screenshot to whatsapp for refund',
                  style: const TextStyle(
                    color: AppColor.textColor1,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                  ),
                ),
                const VerticalSpeacing(20.0),
                GestureDetector(
                  onTap: _openWhatsApp,
                  child: Container(
                    height: 50,
                    width: 400,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/whatsapp.png'),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
                const VerticalSpeacing(20.0),

                InkWell(
                  onTap: () {
                    _downloadInvoice(widget.orderDetailModel.id);
                  },
                  child: Container(
                    height: 56,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border:
                      Border.all(color: AppColor.primaryColor, width: 2),
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
                    child: const Center(
                      child: Text(
                        "Download Invoice",
                        style: TextStyle(
                          fontFamily: 'CenturyGothic',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalSpeacing(30.0),
                const Text(
                  'Product Details',
                  style: TextStyle(
                    fontFamily: 'CenturyGothic',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColor.blackColor,
                  ),
                ),
                const VerticalSpeacing(20.0),

                // Fixed product list - removed fixed height and NeverScrollableScrollPhysics
                ListView.separated(
                  shrinkWrap: true, // Important - makes ListView take only the space it needs
                  physics: const NeverScrollableScrollPhysics(), // Keep this, but allow parent ScrollView to scroll
                  itemCount: widget.orderDetailModel.orderItems.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 16); // Space between items
                  },
                  itemBuilder: (context, index) {
                    final data = widget.orderDetailModel.orderItems[index].product;
                    final weight = widget.orderDetailModel.orderItems[index]
                        .productWeight?.weight.name ??
                        "1kg";
                    return ProductDetailsWidget(
                      img: data.thumbnailImage,
                      title: addEllipsis(
                        data.title.toString(),
                        12, // Maximum length before adding ellipsis
                      ),
                      price: weight.toString(),
                      productPrice: '₹${data.price.toString()}',
                      procustAverate:
                      '${widget.orderDetailModel.orderItems[index].qty}X',
                      id: '',
                      productId: '',
                    );
                  },
                ),
                const VerticalSpeacing(20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}