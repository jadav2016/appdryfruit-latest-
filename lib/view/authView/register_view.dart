// ignore_for_file: use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/res/components/colors.dart';
import 'package:rjfruits/res/components/custom_text_field.dart';
import 'package:rjfruits/view/authView/Social_Auth/google_auth.dart';
import 'package:rjfruits/view/authView/Social_Auth/apple_sign_in.dart';
import 'package:rjfruits/res/components/rounded_button.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:rjfruits/utils/routes/routes_name.dart';
import 'package:rjfruits/utils/routes/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../res/components/loading_manager.dart';
import '../../utils/fcm.dart';
import '../../view_model/auth_view_model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();
  bool _isLoading = false;
  bool isChecked = false;
  void _openTermsAndCondition() async {
    final Uri url =
        Uri.parse("https://rajasthandryfruitshouse.com/terms-and-conditions/");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openPrivacyPolicy() async {
    final Uri url =
        Uri.parse("https://rajasthandryfruitshouse.com/privacy-policy/");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    emailController.dispose();
    nameController.dispose();
    passwordController2.dispose();
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
                          height: 38,
                          width: 107,
                        ),
                      ],
                    ),
                    const VerticalSpeacing(30),
                    Text(
                      "Register",
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
                      "Register to countinue",
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
                          TextFieldCustom(
                            controller: nameController,
                            preIcon: Icons.person,
                            maxLines: 2,
                            text: "sfsdadf",
                            hintText: "enter your name",
                            preColor: AppColor.primaryColor,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter userName";
                              } else {
                                return null;
                              }
                            },
                          ),
                          const VerticalSpeacing(30),
                          TextFieldCustom(
                            controller: emailController,
                            preIcon: Icons.email,
                            maxLines: 2,
                            text: "",
                            hintText: "Enter e-mail",
                            preColor: AppColor.primaryColor,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty || !value.contains("@")) {
                                return "Please enter a valid Email adress";
                              } else {
                                return null;
                              }
                            },
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
                            validator: (value) {
                              if (value!.isEmpty || value.length < 4) {
                                return "Please enter a valid password";
                              } else {
                                return null;
                              }
                            },
                          ),
                          const VerticalSpeacing(30),
                          TextFieldCustom(
                            controller: passwordController2,
                            preIcon: Icons.lock_outline_rounded,
                            maxLines: 2,
                            text: "",
                            hintText: "Confirm password",
                            preColor: const Color(0xff8894A7),
                            obscureText: false,
                            keyboardType: TextInputType.visiblePassword,
                            validator: (value) {
                              if (value!.isEmpty || value.length < 4) {
                                return "Please enter a valid password";
                              } else {
                                return null;
                              }
                            },
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isChecked = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'I agree to the ',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms and Conditions',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap =
                                              () => _openTermsAndCondition(),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => _openPrivacyPolicy(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const VerticalSpeacing(30),
                          RoundedButton(
                            title: "Register",
                            onpress: () async {
                              if (_formKey.currentState!.validate()) {
                                if (isChecked == false) {
                                  Utils.flushBarErrorMessage(
                                      'Please accept the Terms and Conditions and Privacy Policy to register.',
                                      context);
                                  return;
                                }

                                setState(() {
                                  _isLoading = true; // Show loading indicator
                                });
                                if (emailController.text.isEmpty) {
                                  Utils.flushBarErrorMessage(
                                      'please enter your email', context);
                                } else if (passwordController.text.isEmpty) {
                                  Utils.flushBarErrorMessage(
                                      'please enter your password', context);
                                } else if (passwordController2.text.length <
                                    4) {
                                  Utils.flushBarErrorMessage(
                                      'please enter more than four digits',
                                      context);
                                } else {
                                  try {
                                    Map<String, String> data = {
                                      // Ensure type safety
                                      "username":
                                          emailController.text.toString(),
                                      "email": emailController.text.toString(),
                                      "password1":
                                          passwordController.text.toString(),
                                      "password2":
                                          passwordController2.text.toString(),
                                    };

                                    await authViewModel
                                        .signUpApi(data, context)
                                        .then((v) async {
                                      String fcmToken =
                                          await NotificationServices()
                                              .getDeviceToken();
                                      Map<String, String> data2 = {
                                        'registration_id': fcmToken,
                                        'application_id': 'my_fcm_app',
                                      };

                                      await authViewModel.registerDevice(
                                          data2, context);
                                    });

                                  } catch (e) {
                                    Utils.flushBarErrorMessage('$e', context);
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
                    const VerticalSpeacing(20),
                    SizedBox(
                        height: 46,
                        width: double.infinity,
                        child: AppleSignInButton(
                          viewModel: authViewModel,
                        )),
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
                          "Already have an account?",
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
                              RoutesName.login,
                            );
                          },
                          child: Text(
                            "Login",
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
