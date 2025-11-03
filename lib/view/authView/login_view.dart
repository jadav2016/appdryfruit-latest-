// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/res/components/colors.dart';
import 'package:rjfruits/res/components/custom_text_field.dart';
import 'package:rjfruits/res/components/loading_manager.dart';
import 'package:rjfruits/view/authView/Social_Auth/google_auth.dart';
//import 'package:rjfruits/view/authView/Social_Auth/auth_service.dart';
import 'package:rjfruits/view/authView/Social_Auth/apple_sign_in.dart';
//import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:rjfruits/res/components/rounded_button.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:rjfruits/utils/routes/routes_name.dart';
import '../../utils/fcm.dart';
import '../../utils/routes/utils.dart';
import '../../view_model/auth_view_model.dart';
import 'package:rjfruits/res/components/cart_button.dart';
import 'package:rjfruits/view/shopView/shop_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: AppColor.whiteColor,
            image: DecorationImage(
                image: AssetImage("images/bgimg.png"), fit: BoxFit.cover),
          ),
          child: LoadingManager(
            isLoading: _isLoading,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const VerticalSpeacing(10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "images/dry_fruit_logo_new.png",
                          // "images/logo.png",
                          height: 38,
                          width: 107,
                        ),
                      ],
                    ),
                    const VerticalSpeacing(30),
                    Text(
                      "Hello!",
                      style: GoogleFonts.getFont(
                        "Poppins",
                        textStyle: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                    Text(
                      "Insert your credientls to login",
                      style: GoogleFonts.getFont(
                        "Poppins",
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColor.textColor1,
                        ),
                      ),
                    ),
                    const VerticalSpeacing(36),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // TextFieldCustom(
                          //   controller: nameController,
                          //   preIcon: Icons.person,
                          //   maxLines: 2,
                          //   text: "sfsdadf",
                          //   hintText: "name",
                          //   preColor: AppColor.primaryColor,
                          //   keyboardType: TextInputType.emailAddress,
                          // ),
                          const VerticalSpeacing(30),
                          TextFieldCustom(
                            controller: emailController,
                            preIcon: Icons.email,
                            maxLines: 2,
                            text: "",
                            hintText: "Enter e-mail",
                            preColor: AppColor.primaryColor,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const VerticalSpeacing(30),
                          TextFieldCustom(
                            controller: passwordController,
                            preIcon: Icons.lock_outline_rounded,
                            maxLines: 2,
                            text: "",
                            hintText: "Enter password",
                            preColor: AppColor.textColor1,
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                          ),
                          const VerticalSpeacing(8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.forget,
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: GoogleFonts.getFont(
                                    "Poppins",
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const VerticalSpeacing(30),
                          RoundedButton(
                            title: "Login",
                            onpress: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });

                                String email = emailController.text.trim();
                                String password =
                                    passwordController.text.trim();

                                if (email.isEmpty) {
                                  Utils.flushBarErrorMessage(
                                      'Please enter your email', context);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                } else if (password.isEmpty) {
                                  Utils.flushBarErrorMessage(
                                      'Please enter your password', context);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                } else if (password.length < 4) {
                                  Utils.flushBarErrorMessage(
                                      'Password must be at least 4 characters',
                                      context);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                } else {
                                  String fcmToken = await NotificationServices().getDeviceToken();
                                  try {
                                    Map<String, String> data = {
                                      'email': email,
                                      'password': password,
                                    };
                                    Map<String, String> data2 = {
                                      'registration_id': fcmToken,
                                      'application_id': 'my_fcm_app',
                                    };
                                    await authViewModel.loginApi(data, context).then((v) async{
                                      await authViewModel.registerDevice(data2, context);
                                    });

                                  } catch (e) {
                                    setState(() {
                                      _isLoading = false;
                                    });

                                    Utils.flushBarErrorMessage('$e', context);
                                    debugPrint('Login View Error: $e');
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const VerticalSpeacing(20),
                    Platform.isIOS
                        ? SizedBox(
                      height: 46,
                      width: double.infinity,
                      child: AppleSignInButton(
                        viewModel: authViewModel,
                      ),
                    )
                        : const SizedBox.shrink(),
                    const VerticalSpeacing(10),
                     SizedBox(
                        height: 46,
                        width: double.infinity,
                        child: GoogleAuthButton(
                          viewModel: authViewModel,
                        )),
                    const VerticalSpeacing(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: GoogleFonts.getFont(
                            "Poppins",
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColor.textColor1,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RoutesName.register,
                            );
                          },
                          child: Text(
                            "Register",
                            style: GoogleFonts.getFont(
                              "Poppins",
                              textStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    /*Positioned(
                      bottom: 0,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 30.0, bottom: 30.0),
                        child: CartButton(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (c) => ShopView()),
                              );
                            },
                            text: 'Order Now'),
                      ),
                    ),*/
                    const VerticalSpeacing(35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 55.0,
                              height: 55.0,
                              decoration: const BoxDecoration(
                                color:
                                    AppColor.primaryColor, // Background color
                                shape: BoxShape.circle, // Circular shape
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0,
                                        0.25), // Shadow color (black with 25% opacity)
                                    blurRadius: 8.1, // Blur radius
                                    offset:
                                        Offset(0, 4), // Offset (Y direction)
                                  ),
                                ],
                              ),
                              child: FloatingActionButton(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onPressed: () {
                                  // onItemClick(5);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => const ShopView(
                                            limited: "limited",
                                          )));
                                  // Navigator.pushNamed(context, RoutesName.cartView);
                                },
                                backgroundColor: Colors
                                    .transparent, // Transparent background for inner FloatingActionButton
                                elevation: 0, // No shadow
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Image.asset(
                                      'images/shop.png',
                                      fit: BoxFit.contain,
                                      color: AppColor.whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Shop",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
