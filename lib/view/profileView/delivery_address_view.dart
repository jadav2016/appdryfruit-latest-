import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/res/components/colors.dart';
import 'package:rjfruits/res/components/loading_manager.dart';
import 'package:rjfruits/res/components/rounded_button.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:rjfruits/view/profileView/edit_address.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../utils/routes/utils.dart';
import '../../view_model/user_view_model.dart';
import '../checkOut/widgets/address_container.dart';
import 'package:rjfruits/res/components/extension.dart';
import 'package:rjfruits/view/checkOut/check_out_view.dart';
import 'package:rjfruits/view/checkOut/widgets/Payment_field.dart';
import 'package:rjfruits/view/profileView/add_address_view.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> with RouteAware {
  bool _isLoading = false;
  List<Map<String, dynamic>> addresses = [];
  Map<String, dynamic>? selectedAddress;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to defer the call until after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAddresses(context);
    });
  }

  // Method 1: Using didPopNext to refetch when returning from other screens
  @override
  void didPopNext() {
    super.didPopNext();
    // Use WidgetsBinding to defer the call until after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAddresses(context);
    });
  }

  // Method 2: Using didChangeDependencies to refetch when screen becomes active
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only call once and defer until after build
    if (!_hasInitialized && ModalRoute.of(context)?.isCurrent == true) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchAddresses(context);
      });
    }
  }

  Future<void> fetchAddresses(BuildContext context) async {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      _isLoading = true;
    });

    try {
      final userPreferences = Provider.of<UserViewModel>(context, listen: false);
      await userPreferences.fetchAddresses(context);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        Utils.toastMessage('Error occurred while fetching addresses');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAddress(int id) async {
    final userPreferences = Provider.of<UserViewModel>(context, listen: false);
    final userModel = await userPreferences.getUser();
    final token = userModel.key;
    final url = Uri.parse('https://rajasthandryfruitshouse.com/api/address/$id/');
    final response = await http.delete(
      url,
      headers: {
        'accept': 'application/json',
        'X-CSRFToken':
        'SlSrUKA34Wtxgek0vbx9jfpCcTylfy7BjN8KqtVw38sdWYy7MS5IQdW1nKzKAOLj',
        'authorization': 'Token $token',
      },
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      Utils.toastMessage('Successfully deleted Address');
      // Refetch addresses after deletion
      Provider.of<UserViewModel>(context, listen: false).fetchAddresses(context);
    } else {
      print('Failed to delete the address');
    }
  }

  // Method 3: Function to handle navigation with callback
  Future<void> _navigateAndRefresh(Widget destination) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );

    // Refetch addresses when returning from the destination screen
    if ((result == null || result == true) && mounted) {
      // Use WidgetsBinding to defer the call until after the build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          fetchAddresses(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.west,
            color: AppColor.textColor1,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Delivery Address",
          style: GoogleFonts.getFont(
            "Poppins",
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: AppColor.textColor1,
            ),
          ),
        ),
      ),
      body: LoadingManager(
        isLoading: userProvider.isLoading,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: userProvider.addresses.isEmpty
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No Address Found',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.textColor1,
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              RoundedButton(
                title: "Add New Address",
                onpress: () {
                  // Using Method 3: Navigate with callback
                  _navigateAndRefresh(AddAddress());
                },
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // Using Method 3: Navigate with callback
                    _navigateAndRefresh(AddAddresScreen());
                  },
                  child: Text(
                    "Add New",
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
              ),
              const SizedBox(height: 10),
              // Add refresh indicator for pull to refresh
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => fetchAddresses(context),
                  child: ListView.builder(
                    itemCount: userProvider.addresses.length,
                    itemBuilder: (context, index) {
                      final address = userProvider.addresses[index];
                      return Column(
                        children: [
                          AddressCheckOutWidget(
                            bgColor: AppColor.whiteColor,
                            borderColor: AppColor.primaryColor,
                            titleColor: AppColor.primaryColor,
                            title: address['full_name'] ?? '',
                            phNo: address['contact'] ?? '',
                            address:
                            '${address['address'] ?? ''}, ${address['city'] ?? ''} ${address['state'] ?? ''} ${address['postal_code'] ?? ''}',
                            onpress: () async {
                              SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                              prefs.setString('selectedAddress',
                                  jsonEncode(address));
                              setState(() {
                                selectedAddress = address;
                              });
                            },
                            onpressEdit: () {
                              // Using Method 3: Navigate with callback
                              _navigateAndRefresh(
                                EditAddress(address, address['id'], true),
                              );
                            },
                            onpresDelete: () {
                              _deleteAddress(address['id']);
                            },
                          ),
                          const VerticalSpeacing(20),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Updated AddAddress class to return a result when popping
class AddAddress extends StatefulWidget {
  AddAddress({super.key});

  @override
  State<AddAddress> createState() => _AddAddresScreenState();
}

class _AddAddresScreenState extends State<AddAddress> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  String? _errorphone;
  String? _errorAddress;
  String? _errorZipcode;
  bool phoneValid = false;
  bool addressValid = false;
  bool zipValid = false;
  String? _btn2SelectedVal;
  String? _btn3SelectedVal;

  static const menuItems = <String>[
    'andhra_pradesh',
    'arunachal_pradesh',
    "assam",
    'bihar',
    "chhattisgarh",
    "goa",
    "gujarat",
    "haryana",
    "himachal_pradesh",
    "jharkhand",
    "karnataka",
    "kerala",
    "madhya_pradesh",
    "maharashtra",
    "manipur",
    "meghalaya",
    "mizoram",
    "nagaland",
    "odisha",
    "punjab",
    "rajasthan",
    "sikkim",
    "tamil_nadu",
    "telangana",
    "tripura",
    "uttar_pradesh",
    "uttarakhand",
    "west_bengal",
    "andaman_and_nicobar_islands",
    "chandigarh",
    "dadra_and_nagar_haveli_and_daman_and_diu",
    "lakshadweep",
    "delhi",
    "puducherry",
    "ladakh",
    "jammu_and_kashmir ",
  ];

  final List<DropdownMenuItem<String>> _dropDownMenuItems = menuItems
      .map(
        (String value) => DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    ),
  )
      .toList();

  static const menuCountry = <String>[
    'USA',
    'Canada',
    "india",
  ];

  void validateFields() {
    if (_phoneController.text.length != 10 ||
        !['9', '8', '7', '6'].contains(_phoneController.text[0])) {
      setState(() {
        _errorphone = 'Use an Indian phone number';
        phoneValid = true;
        addressValid = false;
        zipValid = false;
      });
    } else if (_addressController.text.length < 10) {
      setState(() {
        _errorAddress = 'Address must be at least 10 characters long';
        addressValid = true;
        phoneValid = false;
        zipValid = false;
      });
    } else if (_zipCodeController.text.length < 6) {
      setState(() {
        _errorZipcode = 'Zip code must be at least 6 characters long';
        zipValid = true;
        addressValid = false;
        phoneValid = false;
      });
    } else {
      zipValid = false;
      addressValid = false;
      phoneValid = false;
      _saveAddress();
    }
  }

  Future<void> _saveAddress() async {
    String fullName = _fullNameController.text;
    String phone = _phoneController.text;
    String address = _addressController.text;
    String city = _cityController.text.capitalizeFirst();
    String state = _btn2SelectedVal ?? '';
    String zipCode = _zipCodeController.text;
    String gstIn = _gstController.text;
    String country = _btn3SelectedVal ?? '';

    Map<String, dynamic> addressMap = {
      'full_name': fullName,
      'contact': phone,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': int.parse(zipCode),
      'gst_in': gstIn,
      'country': country,
    };

    String jsonBody = json.encode(addressMap);

    try {
      final userPreferences = Provider.of<UserViewModel>(context, listen: false);
      final userModel = await userPreferences.getUser();
      final token = userModel.key;
      final response = await http.post(
        Uri.parse('https://rajasthandryfruitshouse.com/api/address/'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRFToken':
          'SlSrUKA34Wtxgek0vbx9jfpCcTylfy7BjN8KqtVw38sdWYy7MS5IQdW1nKzKAOLj',
          'authorization': 'Token $token',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.toastMessage('Address added successfully');
        print('Address added successfully');

        // Update the provider and return true to indicate success
        Provider.of<UserViewModel>(context, listen: false).fetchAddresses(context);
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        print('Failed to add address: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  List<DropdownMenuItem<String>> _dropDownMenuCountry = [];

  @override
  void initState() {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    print(userProvider.countries.length);

    // Use WidgetsBinding to defer state changes until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<UserViewModel>(context, listen: false).clearStates();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserViewModel>(context);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          image: DecorationImage(
              image: AssetImage("images/bgimg.png"), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const VerticalSpeacing(20),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.west,
                        color: AppColor.textColor1,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 6,
                    ),
                    Text(
                      "New Address",
                      style: GoogleFonts.getFont(
                        "Poppins",
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: AppColor.textColor1,
                        ),
                      ),
                    ),
                  ],
                ),
                const VerticalSpeacing(20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor.primaryColor, width: 2),
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
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    child: Column(
                      children: [
                        const VerticalSpeacing(30),
                        PaymentField(
                          controller: _fullNameController,
                          maxLines: 2,
                          text: "Full Name",
                          hintText: "Enter your full Name",
                        ),
                        // Phone field implementation...
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phone Number',
                                style: GoogleFonts.getFont(
                                  "Poppins",
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColor.dashboardIconColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xffEEEEEE),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '+91',
                                        style: GoogleFonts.getFont(
                                          "Roboto",
                                          textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: AppColor.textColor1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        maxLength: 10,
                                        keyboardType: TextInputType.phone,
                                        style: const TextStyle(fontSize: 15),
                                        controller: _phoneController,
                                        decoration: InputDecoration(
                                          counterText: '',
                                          hintStyle: GoogleFonts.getFont(
                                            "Roboto",
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.textColor1,
                                            ),
                                          ),
                                          hintText: 'Enter phone number',
                                          filled: true,
                                          fillColor: const Color(0xffEEEEEE),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: phoneValid
                                                  ? Colors.red.withOpacity(1)
                                                  : Colors.transparent,
                                            ),
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xfff1f1f1)),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _errorphone.toString(),
                                style: TextStyle(
                                  color: phoneValid ? Colors.red : Colors.transparent,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Country dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Country",
                              style: GoogleFonts.getFont(
                                "Poppins",
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.dashboardIconColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: const Color(0xffEEEEEE),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: DropdownButton<String>(
                                  dropdownColor: AppColor.whiteColor,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  value: _btn3SelectedVal,
                                  hint: const Text("Select Country"),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      _btn2SelectedVal = null;
                                      final int countryId = userProvider.countries.firstWhere(
                                            (country) => country['name'] == newValue,
                                      )['id'];
                                      userProvider.fetchStates(countryId);
                                      setState(() {
                                        _btn3SelectedVal = newValue;
                                      });
                                      print("Selected Country ID: $newValue");
                                    }
                                  },
                                  items: userProvider.countries.map(
                                        (country) {
                                      return DropdownMenuItem<String>(
                                        value: country['name'].toString(),
                                        child: Text(country['name']),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // State dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              "State",
                              style: GoogleFonts.getFont(
                                "Poppins",
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.dashboardIconColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                if (userProvider.states.isEmpty) {
                                  Utils.flushBarErrorMessage('Please select county', context);
                                }
                              },
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: const Color(0xffEEEEEE),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                                  child: DropdownButton(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    dropdownColor: AppColor.whiteColor,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    value: _btn2SelectedVal,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _btn2SelectedVal = newValue;
                                        });
                                      }
                                    },
                                    items: userProvider.states.map(
                                          (country) {
                                        return DropdownMenuItem<String>(
                                          value: country['name'].toString(),
                                          child: Text(country['name']),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        PaymentField(
                          controller: _cityController,
                          maxLines: 2,
                          text: "City",
                          hintText: "Enter your city",
                        ),
                        PaymentField(
                          errorText: addressValid ? _errorAddress : null,
                          controller: _addressController,
                          maxLines: 2,
                          text: "Address",
                          hintText: "Enter your address",
                        ),
                        PaymentField(
                          controller: _gstController,
                          maxLines: 2,
                          text: "GST-IN",
                          hintText: "Enter GST-IN",
                        ),
                        const SizedBox(height: 12),
                        PaymentField(
                          maxLength: 6,
                          keyboardType: TextInputType.phone,
                          errorText: zipValid ? _errorZipcode : null,
                          controller: _zipCodeController,
                          maxLines: 2,
                          text: "Zip Code",
                          hintText: "Enter six digit zip code",
                        ),
                        const VerticalSpeacing(38),
                        RoundedButton(
                          title: "Save Address",
                          onpress: () {
                            validateFields();
                          },
                        ),
                        const VerticalSpeacing(38),
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