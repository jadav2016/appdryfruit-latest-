import 'package:flutter/material.dart';
import '../../../model/notification_response_modal.dart';
import '../../../res/components/colors.dart';
import '../../../res/components/date_format.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationItem data;

  const NotificationWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.primaryColor, width: 1),
        color: const Color.fromRGBO(255, 255, 255, 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(6.0),
        leading: Container(
          height: 50,
          width: 50,
          decoration: const BoxDecoration(
            color: AppColor.primaryColor,
            shape: BoxShape.rectangle,
          ),
          child: const Center(
            child: ImageIcon(
              AssetImage('images/notification.png'),
              color: AppColor.whiteColor,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data.verb ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.cardTxColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if ((data.description ?? '').isNotEmpty)
              Text(
                data.description!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColor.cardTxColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 2),
            Text(
              formatDateTime(data.timestamp.toString()),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColor.cardTxColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
