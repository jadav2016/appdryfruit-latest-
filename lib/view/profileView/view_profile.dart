import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rjfruits/view/profileView/edit_profile.dart';
import '../../res/components/colors.dart';
import '../../res/components/vertical_spacing.dart';

class ViewProfile extends StatelessWidget {
  final String? firstname;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? profileImage;

  const ViewProfile({
    super.key,
    this.firstname,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          //height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: AppColor.whiteColor,
            image: DecorationImage(
              image: AssetImage("images/bgimg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const VerticalSpeacing(30.0),
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
                        'Profile',
                        style: GoogleFonts.getFont(
                          "Poppins",
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColor.appBarTxColor,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => EditProfile(
                                firstName: firstname ?? '',
                                lastName: lastName ?? '',
                                email: email ?? '',
                                phoneNumber: phoneNumber ?? '',
                                dateOfBirth: dateOfBirth ?? '',
                                gender: gender ?? 'Male',
                                profileImage: profileImage,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Edit Profile',
                          style: GoogleFonts.getFont(
                            "Poppins",
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const VerticalSpeacing(30.0),

                  // Profile Image
                  InkWell(
                    onTap: () {
                      log('profileImage==>${profileImage}');
                    },
                    child: Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            profileImage != 'null' && profileImage != null
                                ? NetworkImage(profileImage!)
                                : const NetworkImage(
                                    'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/271deea8-e28c-41a3-aaf5-2913f5f48be6/de7834s-6515bd40-8b2c-4dc6-a843-5ac1a95a8b55.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzI3MWRlZWE4LWUyOGMtNDFhMy1hYWY1LTI5MTNmNWY0OGJlNlwvZGU3ODM0cy02NTE1YmQ0MC04YjJjLTRkYzYtYTg0My01YWMxYTk1YThiNTUuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.BopkDn1ptIwbmcKHdAOlYHyAOOACXW0Zfgbs0-6BY-E',
                                  ),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),

                  const VerticalSpeacing(20.0),

                  // Profile Details
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColor.primaryColor, width: 1),
                      color: const Color.fromRGBO(255, 255, 255, 0.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _profileText('First Name', firstname ?? ''),
                        _profileText('Last Name', lastName ?? ''),
                        _profileText('Email', email ?? ''),
                        _profileText('Phone Number', phoneNumber ?? ''),
                        _profileText('Date of Birth', dateOfBirth ?? ''),
                        _profileText('Gender', gender ?? ''),
                        const VerticalSpeacing(50.0),
                      ],
                    ),
                  ),

                  const VerticalSpeacing(50.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileText(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text.rich(
        TextSpan(
          text: '$label\n\n',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.cardTxColor,
          ),
          children: [
            TextSpan(
              text: value != 'null' ? value : 'Not Provided',
              style: const TextStyle(
                color: AppColor.textColor1,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
