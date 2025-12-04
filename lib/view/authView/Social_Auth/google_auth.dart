// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/res/app_url.dart';
import '../../../model/user_model.dart';
import '../../../res/components/colors.dart';
import '../../../utils/fcm.dart';
import '../../../utils/routes/routes_name.dart';
import '../../../utils/routes/utils.dart';
import '../../../view_model/auth_view_model.dart';
import '../../../view_model/user_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class GoogleAuthButton extends StatefulWidget {
  final AuthViewModel viewModel;
  const GoogleAuthButton({super.key, required this.viewModel});

  @override
  State<GoogleAuthButton> createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends State<GoogleAuthButton> {
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = (Platform.isIOS || Platform.isMacOS)
      ? GoogleSignIn(
          // clientId:
          //     '176072233182-iqia1q2csceasnrhlnbj132u6387j4al.apps.googleusercontent.com',
          // serverClientId:
          //     '176072233182-e1e7vo2gv1nq03m2v4tvjq1e6kon9gco.apps.googleusercontent.com',
          serverClientId:
              '6073014342-83hpeui69frg5hoc8a1pkes90lvlb7r7.apps.googleusercontent.com',
          scopes: [
            'email',
            'profile',
            'openid',
          ],
        )
      : GoogleSignIn(
          serverClientId:
              '6073014342-83hpeui69frg5hoc8a1pkes90lvlb7r7.apps.googleusercontent.com',
          scopes: [
            'email',
            'profile',
            'openid',
          ],
        );

  Future<void> handleSignOut() => _googleSignIn.disconnect();

  Future<void> handleGoogleSignIn(BuildContext context) async {
    handleSignOut();
    debugPrint('process google sign in');
    try {
      debugPrint("processing google");
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      // if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final String accessToken = googleSignInAuthentication.accessToken ?? '';

      final String idToken = googleSignInAuthentication.idToken ?? '';
      final String serverAuthCode = googleSignInAccount.serverAuthCode ?? '';

      debugPrint('accessToken:$accessToken');
      // debugPrint('serverAuthCode:$serverAuthCode');

      handleGoogleLoginServer(context, accessToken, idToken, serverAuthCode);
      // }
    } catch (error) {
      log('error.toString()${error.toString()}');
      // Utils.flushBarErrorMessage(error.toString(), context);
      debugPrint('error mesg: $error');
    }
  }

  Future<void> handleGoogleLoginServer(BuildContext context, String accessToken,
      String idToken, String serverAuthCode) async {
    Map data = {
      'access_token': accessToken,
      // 'code': '',
      // 'id_token': idToken,
    };

    log("google login data:KK: $data");

    _isLoading = true;
    try {
      final dio = Dio();

      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await dio.post(
        AppUrl.googleLoginEndPoint,
        options: Options(headers: headers),
        data: data,
      );

      log("Response status code: ${response.statusCode}");
      log("Response body: ${response.data}");
      log("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = response.data;
        String key = responseBody['key'].toString();

        ///
        final userPrefrences =
            Provider.of<UserViewModel>(context, listen: false);
        userPrefrences.saveUser(UserModel(key: key));
        Utils.toastMessage('SuccessFully SignIn');
        Navigator.pushReplacementNamed(context, RoutesName.dashboard);

        _isLoading = false;
      } else {
        _isLoading = false;
        Utils.flushBarErrorMessage('Login Failed', context);
      }
    } on DioException catch (error) {
      Utils.flushBarErrorMessage(error.toString(), context);
      log('error handleGoogleLoginServer: ${error.response!.statusCode}');
      log('error handleGoogleLoginServer: ${error.response!.data}');
      log('error handleGoogleLoginServer: $error');
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        debugPrint('click google sign in');
        await handleGoogleSignIn(context);
      },
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SizedBox(
              height: 48,
              child: SizedBox.expand(
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(10),
                  padding: EdgeInsets.zero,
                  //color: Color.t,
                  onPressed: () async {
                    debugPrint('click google sign in');
                    await handleGoogleSignIn(context).then((v) async {
                      String fcmToken =
                          await NotificationServices().getDeviceToken();
                      Map<String, String> data2 = {
                        'registration_id': fcmToken,
                        'application_id': 'my_fcm_app',
                      };

                      await widget.viewModel.registerDevice(data2, context);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          10), //BorderRadius.circular(12),
                      border: Border.all(
                          width: 1,
                          color: Colors
                              .black), //Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "images/google.png",
                          height: 28,
                          width: 28,
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          "Continue with Google",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.getFont(
                            "Poppins",
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColor.textColor1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ), /*Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(10), //BorderRadius.circular(12),
                border: Border.all(
                    width: 1,
                    color: Colors
                        .black), //Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ), //const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "images/google.png",
                      height: 28,
                      width: 28,
                    ),
                    const SizedBox(width: 5.0),
                    Text(
                      "Continue with Google",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont(
                        "Poppins",
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColor.textColor1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),*/
    );
  }
}
