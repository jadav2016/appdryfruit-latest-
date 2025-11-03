// // ignore_for_file: file_names, library_private_types_in_public_api
//
// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:rjfruits/repository/home_ui_repository.dart';
// import 'package:rjfruits/res/components/colors.dart';
// import 'package:rjfruits/res/components/enums.dart';
// import 'package:rjfruits/view_model/home_view_model.dart';
//
// class CategoryCart extends StatefulWidget {
//   const CategoryCart({
//     super.key,
//     required this.text,
//   });
//
//   final String text;
//
//   @override
//   _CategoryCartState createState() => _CategoryCartState();
// }
//
// class _CategoryCartState extends State<CategoryCart> {
//   // Color _backgroundColor = AppColor.boxColor;
//   // Color _textColor = AppColor.textColor1;
//   List selectedCategories = [];
//   void checkUiType() {}
//
//   @override
//   void initState() {
//     // ignore: unrelated_type_equality_checks
//     checkUiType();
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUIType =
//         Provider.of<HomeUiSwithchRepository>(context, listen: false)
//             .selectedType;
//
//     log('currentUIType===>${currentUIType}');
//
//     // if (currentUIType == UIType.DefaultSection) {
//     //   setState(() {
//     //     _backgroundColor = AppColor.boxColor;
//     //     _textColor = AppColor.textColor1;
//     //   });
//     // }
//
//     return GestureDetector(
//       onTap: () {
//         // Provider.of<HomeRepositoryProvider>(context, listen: false)
//         //     .categoryFilter(
//         //   widget.text,
//         // );
//         // Provider.of<HomeUiSwithchRepository>(context, listen: false)
//         //     .switchToType(
//         //   UIType.CategoriesSection,
//         // );
//
//          if(selectedCategories.isNotEmpty){
//            selectedCategories.clear();
//
//          }
//          selectedCategories.add(widget.text);
//
//           // Update UI based on selection
//           // _backgroundColor = AppColor.primaryColor;
//           // _textColor = AppColor.whiteColor;
//
//         // setState(() {
//         //   _backgroundColor = selectedCategories.any((v)=>v == widget.text)
//         //       ? AppColor.primaryColor
//         //       : AppColor.boxColor;
//         //   _textColor =selectedCategories.any((v)=>v == widget.text)
//         //       ? AppColor.whiteColor:AppColor.textColor1;
//         //   // : AppColor.whiteColor;
//         // });
//
//         log('selectedCategories==>${selectedCategories.length}');
//         log('selectedCategories==>${widget.text}');
//
//         // setState(() {
//         //
//         //    selectedCategories.clear();
//         //     selectedCategories.add(widget.text);
//         //
//         // });
//         //
//          setState(() {
//
//          });
//
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             IntrinsicWidth(
//               child: Container(
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: selectedCategories.any((v)=>v.toString().toLowerCase() == widget.text.toString().toLowerCase())
//                       ? AppColor.primaryColor
//                       : AppColor.boxColor,
//                   borderRadius: BorderRadius.circular(30.0),
//                 ),
//                 child: Center(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Text(
//                       widget.text,
//                       style: GoogleFonts.getFont(
//                         "Poppins",
//                         color: selectedCategories.any((v)=>v.toString().toLowerCase() == widget.text.toString().toLowerCase())
//                             ? AppColor.whiteColor:AppColor.textColor1,
//                         fontSize: 16.0,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       // maxLines: 1,
//                       // overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: file_names, library_private_types_in_public_api

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rjfruits/repository/home_ui_repository.dart';
import 'package:rjfruits/res/components/colors.dart';
import 'package:rjfruits/res/components/enums.dart';
import 'package:rjfruits/view_model/home_view_model.dart';

class CategoryCart extends StatefulWidget {
  const CategoryCart({
    super.key,
    required this.text,
    required this.selectedCategory, // Pass the selected category from parent
    required this.onCategorySelected, // Callback for selection
  });

  final String text;
  final String? selectedCategory; // Currently selected category
  final Function(String) onCategorySelected; // Function to update selection

  @override
  _CategoryCartState createState() => _CategoryCartState();
}

class _CategoryCartState extends State<CategoryCart> {
  @override
  Widget build(BuildContext context) {
    final currentUIType =
        Provider.of<HomeUiSwithchRepository>(context, listen: false)
            .selectedType;

    log('currentUIType===>${currentUIType}');

    final bool isSelected = widget.selectedCategory == widget.text;

    return GestureDetector(
      onTap: () {
        widget.onCategorySelected(widget.text); // Notify parent of selection
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            IntrinsicWidth(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.primaryColor
                      : AppColor.boxColor,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.text,
                      style: GoogleFonts.getFont(
                        "Poppins",
                        color: isSelected
                            ? AppColor.whiteColor
                            : AppColor.textColor1,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

