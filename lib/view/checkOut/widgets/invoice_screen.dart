// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rjfruits/model/checkout_return_model.dart';
import 'package:rjfruits/res/components/colors.dart';
import 'package:rjfruits/res/components/vertical_spacing.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({
    super.key,
    required this.checkoutdetail,
  });

  final CheckoutreturnModel checkoutdetail;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> captureAndSave(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Build PDF content matching UI structure
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Company Header
                pw.Center(
                  child: pw.Text("RAJASTHAN DRY FRUIT HOUSE",
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),

                // Billed From & To Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Billed From
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Billed By:",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text("RAJASTHAN DRY FRUIT HOUSE",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                              "Address: GF-8, CAMPUS CORNER-2, OPP AUDA GARDEN 100 FT ROAD,PRAHALAD NAGAR, AHMEDABAD, Ahmedabad, Gujarat, 380015"),
                          pw.Text("GSTIN: 24ABEFR0010J1ZQ"),
                          pw.Text("MO.NO : 8141066633"),
                          pw.Text("Email: rajasthandryfruits21@gmail.com"),
                        ],
                      ),
                    ),

                    // Billed To
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Invoice Number:",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(widget.checkoutdetail.data.orderInvoiceNumber),
                          pw.Text("Billed To:",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(widget.checkoutdetail.data.fullName,
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text("Address: ${widget.checkoutdetail.data.address}"),
                          pw.Text("Phone: ${widget.checkoutdetail.data.contact}"),
                          pw.Text("GSTIN: ********"),
                          pw.Text(widget.checkoutdetail.data.createdOn.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Order Items Header
                pw.Text("Order Items:",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),

                // Order Items List
                ...widget.checkoutdetail.data.orderItems.map((item) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Product Name: ${item.product.title}"),
                    pw.Text("Price: ${item.product.price}"),
                    pw.Text("Quantity: ${item.qty}"),
                    pw.Text("DISC(%): ${item.totalDiscount}"),
                    pw.Text("TAX(%): ${item.taxDiscountPercentage}"),
                    pw.SizedBox(height: 10),
                  ],
                )),

                // Totals Section
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Amount Before Tax",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.checkoutdetail.data.total.toString()),
                    ]),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Coupon Discount",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.checkoutdetail.data.couponDiscount.toString()),
                    ]),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Shipment Charges",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                          widget.checkoutdetail.data.shippingCharges.toString()),
                    ]),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                          widget.checkoutdetail.data.state.toLowerCase() == 'gujarat'
                              ? "Tax(SGST/CGST)"
                              : "Tax(IGST)",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.checkoutdetail.data.tax.toStringAsFixed(0)),
                    ]),
                pw.Divider(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Sub-Total",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.checkoutdetail.data.subTotal.toString()),
                    ]),
              ],
            );
          },
        ),
      );

      String uuid = const Uuid().v1();
      if (await _requestPermissions()) {
        final directory = Platform.isAndroid
            ? Directory('/storage/emulated/0/Download')
            : await getApplicationDocumentsDirectory();

        final file = File('${directory.path}/invoice_$uuid.pdf');
        await file.writeAsBytes(await pdf.save());

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Here is your invoice PDF',
          subject: 'Invoice from Rajasthan Dry Fruit House',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to ${file.path}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      debugPrint("Error in captureAndSave: $e");
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final checkoutDetail = widget.checkoutdetail.data;
    final orderItems = checkoutDetail.orderItems;
    final billedBy = checkoutDetail.fullName;
    debugPrint('Checkout Details: ${widget.checkoutdetail.data.fullName}');
    debugPrint('Checkout Details: ${widget.checkoutdetail.data.state}');

    String taxLabel =
        widget.checkoutdetail.data.state.trim().toLowerCase() == 'gujarat'
            ? "Tax (sgst + cgst)"
            : "Tax (igst)";
    debugPrint('Tax Label: $taxLabel');
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          image: DecorationImage(
              image: AssetImage("images/bgimg.png"), fit: BoxFit.cover),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
                child: Row(
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
                      'Invoice',
                      style: GoogleFonts.getFont(
                        "Poppins",
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColor.appBarTxColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        captureAndSave(context);
                      },
                      icon: const Icon(
                        Icons.download_outlined,
                        color: AppColor.appBarTxColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(builder: (BuildContext context) {
                  return RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppColor.primaryColor, width: 2),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 2,
                            spreadRadius: 0,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              "images/dry_fruit_logo_new.png",
                              height: 100,
                              width: 100,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Billed By:",
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    Text("RAJASTHAN DRY FRUIT HOUSE",
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        "Address :GF-8, CAMPUS CORNER-2, OPP AUDA GARDEN 100 FT ROAD,PRAHALAD NAGAR, AHMEDABAD, Ahmedabad, Gujarat, 380015",
                                        style:
                                            GoogleFonts.poppins(fontSize: 14)),
                                    Text(
                                      "GSTIN:24ABEFR0010J1ZQ",
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    Text(
                                      "MO.NO : 8141066633",
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    Text(
                                      "Email:  rajasthandryfruits21@gmail.com",
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Invoice Number:",
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        widget.checkoutdetail.data
                                            .orderInvoiceNumber,
                                        style:
                                            GoogleFonts.poppins(fontSize: 14)),
                                    Text("Billed To:",
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    Text(billedBy,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    Text(widget.checkoutdetail.data.address,
                                        style:
                                            GoogleFonts.poppins(fontSize: 14)),
                                    Text(
                                      widget.checkoutdetail.data.contact,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    Text(
                                      "********",
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    Text(
                                      widget.checkoutdetail.data.createdOn
                                          .toString(),
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text("Order Items:",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          for (var item in orderItems)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Product Name: ${item.product.title}",
                                    style: GoogleFonts.poppins(fontSize: 14)),
                                Text("Price: ${item.product.price}",
                                    style: GoogleFonts.poppins(fontSize: 14)),
                                Text("Quantity: ${item.qty}",
                                    style: GoogleFonts.poppins(fontSize: 14)),
                                // Text("HSN CODE: ${item.qty}",
                                //     style: GoogleFonts.poppins(fontSize: 14)),
                                Text("DISC(%): ${item.totalDiscount}",
                                    style: GoogleFonts.poppins(fontSize: 14)),
                                Text("TAX(%): ${item.taxDiscountPercentage}",
                                    style: GoogleFonts.poppins(fontSize: 14)),
                                const VerticalSpeacing(8),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Amount Before Tax",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                widget.checkoutdetail.data.total.toStringAsFixed(2),
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Coupon Discount",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                widget.checkoutdetail.data.couponDiscount
                                    .toStringAsFixed(2),
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Shipment Charges",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                widget.checkoutdetail.data.shippingCharges
                                    .toStringAsFixed(2),
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  widget.checkoutdetail.data.state.toLowerCase() == 'gujarat'
                                      ? "Tax(SGST/IGST)"
                                      : "Tax(IGST)",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                widget.checkoutdetail.data.tax
                                    .toStringAsFixed(2)
                                    .toString(),
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          const Divider(
                            color: AppColor.primaryColor,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Sub-Total",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                widget.checkoutdetail.data.subTotal.toStringAsFixed(2),
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
