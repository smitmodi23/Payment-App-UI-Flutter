import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_payment_app/pages/my_home_page.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../controller/product_add_controller.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage(this.name, {Key? key}) : super(key: key);
  final String name;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final ProductController productController = Get.put(ProductController());
  ScreenshotController screenshotController = ScreenshotController();

  String existingFilePath = '';

  final NumberFormat currencyFormat = NumberFormat('#,##,##0.00', 'en_IN');

  @override
  void initState() {
    super.initState();
    productController.getBill();
    getDownloadExistingFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: const Text(
          'Invoice',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF176B2C),
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (productController.billData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 75,
                    color: Colors.green.shade200,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Product Selected Yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select products to generate your invoice.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.offAll(() => MyHomePage()),
                    icon: const Icon(Icons.add),
                    label: const Text('Select Products'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF176B2C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 650),
                          child: Screenshot(
                            controller: screenshotController,
                            child: _buildInvoice(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom actions - excluded from invoice screenshot
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 15,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => screenToPdf("Share"),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF176B2C),
                          side: const BorderSide(color: Color(0xFF176B2C)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => screenToPdf("Save"),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF176B2C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInvoice() {
    final items = productController.billData;

    final total = items.fold<num>(0, (sum, item) {
      final price = num.tryParse(item.totalPrice.toString()) ?? 0;
      return sum + price.ceil();
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE9D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Business header
          const Icon(Icons.eco_rounded, color: Color(0xFF23853B), size: 42),
          const SizedBox(height: 8),
          const Text(
            'Sweta Pan Mandir',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF176B2C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Modi Ashwinkumar Chandulal',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'C/ 218 Bhaviknagar',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Adinathnagar, New Odhav, Ahmedabad-382415',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 18),

          Container(height: 2, color: const Color(0xFF23853B)),
          const SizedBox(height: 22),

          // Customer and date
          Row(
            children: [
              const Text('To:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 28,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black54)),
                  ),
                  child: Text(
                    widget.name,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Date:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 28,
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black54)),
                  ),
                  child: Text(
                    '${DateTime.now().day.toString().padLeft(2, '0')}/'
                    '${DateTime.now().month.toString().padLeft(2, '0')}/'
                    '${DateTime.now().year}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),

          // Invoice table
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD5E2D2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF176B2C),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(7),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Amount',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Product rows
                ...List.generate(items.length, (index) {
                  final item = items[index];
                  final price = num.tryParse(item.totalPrice.toString()) ?? 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: index.isEven
                          ? const Color(0xFFF5FAF2)
                          : Colors.white,
                      border: const Border(
                        bottom: BorderSide(color: Color(0xFFE8EFE5)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qty: ${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₹${currencyFormat.format(price.ceil())}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Total
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F4DD),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(7),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Grand Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xFF176B2C),
                          ),
                        ),
                      ),
                      Text(
                        '₹${currencyFormat.format(total)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          color: Color(0xFF176B2C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bank details
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5FAF2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDCE9D9)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Details',
                  style: TextStyle(
                    color: Color(0xFF176B2C),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 10),
                Text('IFSC: AMCB0660011', style: TextStyle(fontSize: 13)),
                SizedBox(height: 6),
                Text(
                  'AMCO Bank Account No. - 066011001012174',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          const Text(
            'Thank You!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF176B2C),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Visit Again',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> screenToPdf(String fileType) async {
    try {
      // Capture invoice only
      final Uint8List? screenShot = await screenshotController.capture();

      if (screenShot == null) {
        Get.snackbar(
          'Error',
          'Unable to capture invoice.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Generate PDF
      final pdf = pw.Document();
      final image = pw.MemoryImage(screenShot);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
          },
        ),
      );

      // App-specific storage (No storage permission required)
      final directory = await getApplicationDocumentsDirectory();

      final fileName = 'Invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final savePath = path.join(directory.path, fileName);

      final pdfFile = File(savePath);

      await pdfFile.writeAsBytes(await pdf.save(), flush: true);

      // Share PDF
      if (fileType == 'Share') {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(pdfFile.path)],
            subject: 'Invoice',
            text: 'Please find the attached invoice.',
          ),
        );
      } else {
        Get.snackbar(
          'PDF Downloaded',
          'Invoice saved successfully: $savePath',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('PDF Error: $e');
      debugPrintStack(stackTrace: stackTrace);

      Get.snackbar(
        'Error',
        'Unable to generate PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  getDownloadExistingFile() async {
    Directory? directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists()) {
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }
    }
    existingFilePath = directory!.absolute.path;
  }

  totalPrice() {
    num totals = 0;
    for (int i = 0; i < productController.billData.length; i++) {
      totals =
          int.parse(
            num.parse(
              productController.billData[i].totalPrice!,
            ).ceil().toStringAsFixed(0),
          ) +
          totals;
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 230),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [Text("₹ $totals.00", style: TextStyle(fontSize: 14))],
      ),
    );
  }
}
