import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../res/components/colors.dart';
import '../../res/components/vertical_spacing.dart';
import '../../view_model/service/auth_services.dart';
import '../../view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  void sendEmail() async {
    final Uri url = Uri.parse(
        'mailto:delete@rajasrhandryfruithouse.com?subject=Request for Account Deletion.' // Regular spaces
        );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void confirmDeletion() async {
    final AuthService authService = AuthService();
    await authService.deleteAccount(context);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserViewModel>(context);
    return Scaffold(
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          image: const DecorationImage(
              image: AssetImage("images/bgimg.png"), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            const VerticalSpeacing(50.0),
            Row(
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
                const SizedBox(width: 80.0),
                Text(
                  'Delete Account',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.getFont(
                    "Poppins",
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColor.appBarTxColor,
                    ),
                  ),
                  children: [
                    TextSpan(
                      text:
                          'If you wish to delete your account from our platform, please send an email from ',
                    ),
                    TextSpan(
                      text: userProvider.userData['email'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Email in blue color
                        decoration: TextDecoration.underline, // Underline email
                      ),
                    ),
                    TextSpan(
                      text: ' (your registered email address) to ',
                    ),
                    TextSpan(
                      text: 'delete@rajasrhandryfruithouse.com',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Email in blue color
                        decoration: TextDecoration.underline, // Underline email
                      ),
                    ),
                    TextSpan(
                      text:
                          ' with the subject "Request for Account Deletion." In your email, kindly include your registered email ID or username and mention that you would like your account and associated data to be permanently deleted. Our support team will process your request as per our privacy policy and confirm once the deletion is complete. If you have any questions or need further assistance, feel free to contact us.',
                    ),
                  ],
                ),
              ),
            ),
            const VerticalSpeacing(20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.getFont(
                    "Poppins",
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColor.appBarTxColor,
                    ),
                  ),
                  children: const [
                    TextSpan(
                      text:
                          'Or tap on the button below (WARNING: there will be no confirmation).',
                    ),
                  ],
                ),
              ),
            ),
            const VerticalSpeacing(30.0),

            /*InkWell(
              onTap: (){
                sendEmail();
              },
              child: Container(
                alignment: Alignment.center,
                width: 160,
                height: 40,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: AppColor.primaryColor),
                child:   Text(
                  'Send Mail',
                  style: GoogleFonts.getFont(
                    "Poppins",
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
              ),
            )*/

            InkWell(
              onTap: () {
                confirmDeletion();
              },
              child: Container(
                alignment: Alignment.center,
                width: 160,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: AppColor.primaryColor),
                child: Text(
                  'Request Deletion',
                  style: GoogleFonts.getFont(
                    "Poppins",
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
