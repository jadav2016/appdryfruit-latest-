// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:rjfruits/res/components/rounded_button.dart';
import 'package:rjfruits/utils/routes/utils.dart';
import 'package:rjfruits/view/checkOut/widgets/Payment_field.dart';
import 'package:rjfruits/view_model/home_view_model.dart';
import 'package:rjfruits/view_model/user_view_model.dart';

import '../../res/components/colors.dart';
import '../../res/components/vertical_spacing.dart';

class EditProfile extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;
  final String gender;
  final String? profileImage;

  const EditProfile({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    this.profileImage,
  });
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  String selectedGender = 'Male';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      Utils.flushBarErrorMessage("Error picking image: $e", context);
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  void updateData() async {
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    final userModel = await userPreferences.getUser();
    final token = userModel.key;

    if (lastNameController.text.isNotEmpty &&
        firstNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&    phoneController.text != 'null'&&
        dobController.text.isNotEmpty && dobController.text != 'null') {
      Provider.of<HomeRepositoryProvider>(context, listen: false).updateUserData(
        firstNameController.text,
        lastNameController.text,
        token,
        context,
        phoneNumber: phoneController.text,
        dateOfBirth: dobController.text,
        gender: selectedGender,
        profileImage: _imageFile,
      );
    } else {
      Utils.flushBarErrorMessage("Please fill all the required fields", context);
    }
  }

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController(text: widget.firstName);
    lastNameController = TextEditingController(text: widget.lastName);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phoneNumber);
    dobController = TextEditingController(text: widget.dateOfBirth);
    selectedGender = widget.gender;  // Set default gender
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
                const SizedBox(width: 40), // To balance the AppBar
              ],
            ),
            const VerticalSpeacing(30.0),
            // Profile Image Section with Upload Button
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _imageFile != null
                            ? Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        )
                            :widget.profileImage != 'null'&& widget.profileImage != null ?
                        Image.network(
                          widget.profileImage!,
                          fit: BoxFit.cover,
                        ):
                        const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                    if (_imageFile != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_imageFile == null
                      ? 'Upload Profile Picture'
                      : 'Change Picture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
            const VerticalSpeacing(20.0),
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
              )],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaymentField(
                    controller: firstNameController,
                    maxLines: 2,
                    text: 'First Name',
                    hintText: 'First name',
                  ),
                  PaymentField(
                    controller: lastNameController,
                    maxLines: 2,
                    text: 'Last Name',
                    hintText: 'Last name',
                  ),
                  PaymentField(
                    controller: emailController,
                    maxLines: 2,
                    text: 'Email',
                    hintText: 'Enter email',
                  ),
                  PaymentField(
                    controller: phoneController,
                    maxLines: 2,
                    text: 'Phone Number',
                    hintText: 'Mobile number',
                    keyboardType: TextInputType.phone,
                  ),
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: PaymentField(
                        controller: dobController,
                        maxLines: 2,
                        text: 'Date of Birth',
                        hintText: 'YYYY-MM-DD',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gender',
                          style: GoogleFonts.getFont(
                            "Poppins",
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColor.appBarTxColor,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Male',
                              groupValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value!;
                                });
                              },
                            ),
                            const Text('Male'),
                            Radio<String>(
                              value: 'Female',
                              groupValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value!;
                                });
                              },
                            ),
                            const Text('Female'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const VerticalSpeacing(40.0),
                  RoundedButton(
                    title: 'Save',
                    onpress: () {
                      updateData();
                    },
                  ),
                  const VerticalSpeacing(20.0),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    ),
    ),
    );
  }
}