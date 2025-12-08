// ignore_for_file: use_build_context_synchronously

import 'dart:async';
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

class GoogleAuthButton extends StatefulWidget {
  final AuthViewModel viewModel;
  const GoogleAuthButton({super.key, required this.viewModel});

  @override
  State<GoogleAuthButton> createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends State<GoogleAuthButton> {
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  // GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    // #docregion Setup
    unawaited(
      _googleSignIn
          .initialize(
              serverClientId:
                  '6073014342-83hpeui69frg5hoc8a1pkes90lvlb7r7.apps.googleusercontent.com')
          .then((
        _,
      ) {
        // _googleSignIn.authenticationEvents
        //     .listen(_handleAuthenticationEvent)
        //     .onError(_handleAuthenticationError);

        /// This example always uses the stream-based approach to determining
        /// which UI state to show, rather than using the future returned here,
        /// if any, to conditionally skip directly to the signed-in state.
        // _googleSignIn.attemptLightweightAuthentication();
      }),
    );
  }

  /// The scopes required by this application.
// #docregion CheckAuthorization
  List<String> scopes = <String>[
    'email',
    'profile',
  ];

  Future<void> _handleAuthenticationEvent(
      // GoogleSignInAuthenticationEvent event,
      ) async {
    setState(() => _isLoading = true);

    try {
      // #docregion CheckAuthorization
      // final GoogleSignInAccount? user = // ...
      // #enddocregion CheckAuthorization
      //     switch (event) {
      //   GoogleSignInAuthenticationEventSignIn() => event.user,
      //   GoogleSignInAuthenticationEventSignOut() => null,
      // };

      final GoogleSignInAccount user = await _googleSignIn.authenticate();

      // Check for existing authorization.
      // #docregion CheckAuthorization
      final GoogleSignInClientAuthorization? authorization =
          await user.authorizationClient.authorizationForScopes(scopes);
      // #enddocregion CheckAuthorization

      debugPrint("Google Access Token: ${authorization?.accessToken}");

      String accessToken = authorization?.accessToken ?? "";
      String idToken = '';
      String? authCode = '';

      // Now you can send token to server
      await handleGoogleLoginServer(
        context,
        accessToken,
        idToken,
        authCode,
      );

      setState(() {
        // _currentUser = user;
      });
    } catch (e) {
      await _handleAuthenticationError(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    setState(() {
      // _currentUser = null;
      _isLoading = false;

      log(_errorMessageFromSignInException(e as GoogleSignInException));

      Utils.flushBarErrorMessage(
        _errorMessageFromSignInException(e),
        context,
      );
    });
  }

  String _errorMessageFromSignInException(GoogleSignInException e) {
    // In practice, an application should likely have specific handling for most
    // or all of the, but for simplicity this just handles cancel, and reports
    // the rest as generic errors.
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign in canceled',
      _ => 'GoogleSignInException ${e.code}: ${e.description}',
    };
  }

  // final GoogleSignIn _googleSignIn = (Platform.isIOS || Platform.isMacOS)
  //     ? GoogleSignIn(
  //         // clientId:
  //         //     '176072233182-iqia1q2csceasnrhlnbj132u6387j4al.apps.googleusercontent.com',
  //         // serverClientId:
  //         //     '176072233182-e1e7vo2gv1nq03m2v4tvjq1e6kon9gco.apps.googleusercontent.com',
  //         serverClientId:
  //             '6073014342-83hpeui69frg5hoc8a1pkes90lvlb7r7.apps.googleusercontent.com',
  //         scopes: [
  //           'email',
  //           'profile',
  //           'openid',
  //         ],
  //       )
  //     : GoogleSignIn(
  //         serverClientId:
  //             '6073014342-83hpeui69frg5hoc8a1pkes90lvlb7r7.apps.googleusercontent.com',
  // scopes: [
  //   'email',
  //   'profile',
  //   'openid',
  // ],
  //       );

  Future<void> handleSignOut() => _googleSignIn.disconnect();

  // Future<void> handleGoogleSignIn(BuildContext context) async {
  //   setState(() => _isLoading = true);

  //   try {
  //     // Always disconnect previous sessions
  //     await handleSignOut();

  //     debugPrint("Starting Google Sign-In...");

  //     final GoogleSignInAccount? account = await _googleSignIn.signIn();

  //     // ❌ User cancelled
  //     if (account == null) {
  //       debugPrint("Google Sign-In cancelled by user");
  //       Utils.flushBarErrorMessage("Sign-In cancelled", context);
  //       setState(() => _isLoading = false);
  //       return;
  //     }

  //     debugPrint("Google account selected: ${account.email}");

  //     // Fetch tokens
  //     final GoogleSignInAuthentication auth = await account.authentication;

  //     final String? accessToken = auth.accessToken;
  //     final String? idToken = auth.idToken;
  //     final String? authCode = account.serverAuthCode;

  //     // ❌ Missing tokens → Happens in PlayStore if SHA mismatch
  //     if (accessToken == null || idToken == null) {
  //       Utils.flushBarErrorMessage(
  //         "Google Sign-In failed. Token missing.\nCheck SHA keys in Firebase.",
  //         context,
  //       );
  //       debugPrint("Token error: accessToken=$accessToken idToken=$idToken");
  //       setState(() => _isLoading = false);
  //       return;
  //     }

  //     debugPrint("Google Access Token: $accessToken");

  //     // Now you can send token to server
  //     await handleGoogleLoginServer(
  //       context,
  //       accessToken,
  //       idToken,
  //       authCode ?? "",
  //     );
  //   }

  //   // -----------------
  //   // ERROR HANDLING
  //   // -----------------

  //   // ❌ Common Google Sign-In exceptions
  //   on PlatformException catch (e) {
  //     debugPrint("PlatformException: ${e.code} - ${e.message}");

  //     switch (e.code) {
  //       case 'network_error':
  //         Utils.flushBarErrorMessage(
  //             "Network error. Please try again.", context);
  //         break;

  //       case 'sign_in_failed':
  //         Utils.flushBarErrorMessage("Google Sign-In failed.", context);
  //         break;

  //       case 'sign_in_canceled':
  //         Utils.flushBarErrorMessage("Sign-In cancelled.", context);
  //         break;

  //       case 'developer_error':
  //         //wrong SHA, wrong client ID, incorrect package name
  //         Utils.flushBarErrorMessage(
  //           "Developer error. Fix SHA-1 / SHA-256 in Firebase.",
  //           context,
  //         );
  //         break;

  //       default:
  //         Utils.flushBarErrorMessage(
  //           "Google Sign-In error: ${e.message}",
  //           context,
  //         );
  //     }
  //   }

  //   // ❌ General exceptions
  //   catch (e, stack) {
  //     debugPrint("Google Sign-In UNKNOWN ERROR → $e\n$stack");

  //     Utils.flushBarErrorMessage(
  //       "Something went wrong during Sign-In. Please try again.",
  //       context,
  //     );
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // Future<void> handleGoogleSignIn(BuildContext context) async {
  //   handleSignOut();
  //   debugPrint('process google sign in');
  //   try {
  //     debugPrint("processing google");
  //     final GoogleSignInAccount? googleSignInAccount =
  //         await _googleSignIn.signIn();

  //     if (googleSignInAccount == null) {
  //       // User cancelled the sign-in
  //       log('Google Sign-In cancelled by user');
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       return;
  //     }

  //     // if (googleSignInAccount != null) {
  //     final GoogleSignInAuthentication googleSignInAuthentication =
  //         await googleSignInAccount.authentication;

  //     final String accessToken = googleSignInAuthentication.accessToken ?? '';

  //     final String idToken = googleSignInAuthentication.idToken ?? '';
  //     final String serverAuthCode = googleSignInAccount.serverAuthCode ?? '';

  //     debugPrint('accessToken:$accessToken');
  //     // debugPrint('serverAuthCode:$serverAuthCode');

  //     handleGoogleLoginServer(context, accessToken, idToken, serverAuthCode);
  //     // }
  //   } catch (error) {
  //     log('error.toString()${error.toString()}');
  //     Utils.flushBarErrorMessage(
  //         'Sign in Failed, ${error.toString()}', context);
  //     debugPrint('error mesg: $error');
  //   }
  // }

  Future<void> handleGoogleLoginServer(BuildContext context, String accessToken,
      String idToken, String serverAuthCode) async {
    Map data = {
      'access_token': accessToken,
      // 'code': '',
      // 'id_token': idToken,
    };

    log("google login data:KK: $data");

    setState(() => _isLoading = true);
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
      } else {
        Utils.flushBarErrorMessage('Login Failed', context);
      }
    } on DioException catch (error) {
      Utils.flushBarErrorMessage(error.toString(), context);
      log('error handleGoogleLoginServer: ${error.response!.statusCode}');
      log('error handleGoogleLoginServer: ${error.response!.data}');
      log('error handleGoogleLoginServer: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return
        // InkWell(
        //   onTap: () async {
        //     debugPrint('click google sign in');
        //     if (_googleSignIn.supportsAuthenticate()) {
        //       debugPrint('Google Sign-In supported on this platform.');
        //       try {
        //         await _googleSignIn.authenticate();
        //       } catch (e) {
        //         // #enddocregion ExplicitSignIn
        //         log('Error during Google Sign-In authentication: $e');
        //         // #docregion ExplicitSignIn
        //       }
        //     } else {
        //       debugPrint('Google Sign-In NOT supported on this platform.');
        //     }
        //     // await handleGoogleSignIn(context);
        //   },
        //   child:
        _isLoading
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
                      debugPrint('click google sign in');
                      if (_googleSignIn.supportsAuthenticate()) {
                        debugPrint(
                            'Google Sign-In supported on this platform.');
                        try {
                          await _handleAuthenticationEvent()
                              .then((value) async {
                            String fcmToken =
                                await NotificationServices().getDeviceToken();
                            Map<String, String> data2 = {
                              'registration_id': fcmToken,
                              'application_id': 'my_fcm_app',
                            };

                            await widget.viewModel
                                .registerDevice(data2, context);
                          });
                        } catch (e) {
                          // #enddocregion ExplicitSignIn
                          log('Error during Google Sign-In authentication: $e');
                          // #docregion ExplicitSignIn
                        }
                      } else {
                        debugPrint(
                            'Google Sign-In NOT supported on this platform.');
                      }
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
              ); /*Container(
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
    // );
  }
}
