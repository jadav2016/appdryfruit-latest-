import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:rjfruits/res/app_url.dart';
import 'package:provider/provider.dart';
import '../../../utils/fcm.dart';
import '../../../view_model/auth_view_model.dart';
import '../../../view_model/user_view_model.dart';
import '../../../model/user_model.dart';

import 'dart:convert';
import 'dart:developer';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../../res/components/colors.dart';
import '../../../utils/routes/routes_name.dart';
import '../../../utils/routes/utils.dart';

import 'package:rjfruits/view/authView/Social_Auth/continue_with_apple_button.dart';

class AppleSignInButton extends StatefulWidget {
  final AuthViewModel viewModel;
  const AppleSignInButton({super.key,required this. viewModel});

  @override
  State<AppleSignInButton> createState() => _AppleAuthButtonState();
}

class _AppleAuthButtonState extends State<AppleSignInButton> {
  bool _isLoading = false;

  Future<void> handleAppleLoginServer(BuildContext context,
      String identityToken, String authorizationCode) async {
    //Map data = {'code': authorizationCode, 'id_token': identityToken};
    //Map data = {'code': authorizationCode};
    Map data = {'access_token': authorizationCode, 'id_token': identityToken};

    debugPrint("apple login data:${data}");

    _isLoading = true;
    try {
      final dio = Dio();

      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await dio.post(
        AppUrl.appleLoginEndPoint,
        options: Options(headers: headers),
        data: data,
      );

      debugPrint("Response status code: ${response.statusCode}");
      debugPrint("Response body: ${response.data}");
      debugPrint("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = response.data;
        String key = responseBody['key'].toString();
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
    } catch (error) {
      Utils.flushBarErrorMessage(error.toString(), context);
      debugPrint('error mesg: $error');
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContinueWithAppleButton(
      style: ContinueWithAppleButtonStyle.whiteOutlined,
      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      //text: 'Continue with Apple',
      onPressed: () async {





        try {
          final result = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            webAuthenticationOptions: WebAuthenticationOptions(
              clientId: 'com.rjfruits',
              //clientId: '34BU5328NQ',
              //redirectUri: Uri.parse('https://rajasthandryfruitshouse.com/api/accounts/auth/apple/callback'),
              //clientId: 'com.rjfruits.signin',
              //redirectUri: Uri.parse(AppUrl.appleLoginEndPoint),
              redirectUri: Uri.parse(
                  'https://rajasthandryfruitshouse.com/accounts/apple/login/callback/'),
              //redirectUri: Uri.parse(AppUrl.baseUrl),
            ),
          );

          /*final userPrefrences =
              Provider.of<UserViewModel>(context, listen: false);
          userPrefrences.saveUser(UserModel(key: result.authorizationCode));*/

          //print(result.authorizationCode);
          //print(result);

          final String identityToken = result.identityToken ?? '';
          final String authorizationCode = result.authorizationCode ?? '';

          // You can use the result to authenticate the user with your server.
          handleAppleLoginServer(context, identityToken, authorizationCode).then((v)async{
            String fcmToken = await NotificationServices().getDeviceToken();
            Map<String, String> data2 = {
              'registration_id': fcmToken,
              'application_id': 'my_fcm_app',
            };

            await widget.viewModel.registerDevice(data2, context);
          });
        } catch (error) {
          print(error.toString());
        }
      },
    );
  }
}
