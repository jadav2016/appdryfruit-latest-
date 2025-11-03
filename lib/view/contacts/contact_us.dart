import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rjfruits/res/components/rounded_button.dart';
import 'package:rjfruits/view/checkOut/widgets/Payment_field.dart';
import '../../res/components/colors.dart';
import '../../res/components/vertical_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  void _openWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/8141066633");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
  void _openMap() async {
    final Uri url = Uri.parse("https://maps.app.goo.gl/WpadzKszhv7LRc8T6");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          image: DecorationImage(
              image: AssetImage("images/bgimg.png"), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
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
                      'Contact Us',
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
                // const VerticalSpeacing(30.0),
                // Container(
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10),
                //     border: Border.all(color: AppColor.primaryColor, width: 1),
                //     color: const Color.fromRGBO(255, 255, 255, 0.2),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.white.withOpacity(0.5),
                //         blurRadius: 2,
                //         spreadRadius: 0,
                //         offset: const Offset(0, 0),
                //       ),
                //     ],
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.all(20.0),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         PaymentField(maxLines: 2, text: 'Name'),
                //         PaymentField(maxLines: 2, text: 'Email'),
                //         PaymentField(maxLines: 2, text: 'Mobile Number'),
                //         PaymentField(maxLines: 2, text: 'Address'),
                //         const VerticalSpeacing(20.0),
                //         RoundedButton(title: 'Submit', onpress: () {}),
                //       ],
                //     ),
                //   ),
                // ),
                const VerticalSpeacing(10.0),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor.primaryColor, width: 1),
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
                        ListTile(
                          leading: Container(
                            height: 50,
                            width: 50,
                            color: AppColor.primaryColor,
                            child: const Center(
                              child: Icon(
                                Icons.location_on_outlined,
                                color: AppColor.whiteColor,
                              ),
                            ),
                          ),
                          title: const Text(
                            'Shop No. 8, Campus Corner 2 Complex, beside sales india AUDA Garden, ',
                            style: TextStyle(
                                fontSize: 14, color: AppColor.cardTxColor),
                          ),
                          subtitle: const Text(
                            'nr. Flamingo circle, Prahlad Nagar, Ahmedabad, Gujarat 380015, India',
                            style: TextStyle(
                                fontSize: 14, color: AppColor.cardTxColor),
                          ),
                        ),
                        const VerticalSpeacing(15.0),
                        InkWell(
                          onTap: (){
                            _openMap();
                          },
                          child: Container(
                            height: 250,
                            width: 320,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('images/location3.png'),
                                    fit: BoxFit.contain)),
                          ),
                        ),
                  GestureDetector(
                    onTap: _openWhatsApp,
                    child: Container(
                      height: 120,
                      width: 150,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/whatsapp.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                      ],
                    ),
                  ),
                ),
                const VerticalSpeacing(30.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
