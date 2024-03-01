import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_payment_app/component/colors.dart';
import 'package:flutter_payment_app/pages/my_home_page.dart';
import 'package:flutter_payment_app/widgets/buttons.dart';
import 'package:flutter_payment_app/widgets/large_buttons.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/product_add_controller.dart';
import '../db_helper/dbHelper.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage(this.name, {Key? key}) : super(key: key);
  final String name;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final ProductController productController = Get.put(ProductController());
  ScreenshotController screenshotController = ScreenshotController();



  @override
  void initState() {
    super.initState();
    productController.dbHelper = DatabaseHelper.instance;
    productController.getBill();
    productController.total.value = 0;
    productController.totalPrice.value = 0;
    productController.totalPriceList.clear();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
          children: [
          Obx(() =>  (productController.billData.length !=0)
                ? Screenshot(
              controller: screenshotController,
              child: Container(
                  padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image:
                              AssetImage("assets/images/paymentbackground.jpg"))),
                  child: Column(children: [
                    SizedBox(height: h * 0.159),
                    Row(
                      children: [
                        SizedBox(width: 21,),
                        Text(widget.name,style: TextStyle(fontSize: 16),),
                      ],
                    ),
                    SizedBox(height: h * 0.131),
                    Container(
                      height: 175,
                      width: 305,
                      child: MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: ListView.builder(
                              itemCount: productController.billData.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  child: Column(
                                    children: [
                                      Row(children: [
                                        Container(
                                            margin: const EdgeInsets.only(left: 10),
                                            width: 20,
                                            height: 20,
                                            child: Center(
                                                child: Text(
                                                    "${productController.billData[index].quantity}",
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w900,
                                                      color: Colors.black,
                                                    )))),
                                        Container(
                                          margin: const EdgeInsets.only(left: 10),
                                          width: 100,
                                          height: 20,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "${productController.billData[index].name}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.mainColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                        ),
                                        Text(
                                          "${num.parse(productController.billData[index].totalPrice).ceil().toStringAsFixed(0)}.00",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.mainColor,
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                );

                              }),
                        ),
                      ),
                    totalPrice(),
                  ]),
              ),

            )
                : Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network("https://img.freepik.com/free-vector/no-data-concept-illustration_114360-536.jpg?w=2000"),
                    Text("No Product Selected Yet"),
                  ],
                ),))
            ,
            Obx(
              () => Positioned(
                top: 470,
                child: (productController.billData.length != 0)
                    ? Column(
                    children: [
                      SizedBox(height: h * 0.16),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        AppButtons(
                            icon: Icons.share_sharp,
                            onTap: () {
                              screenToPdf();
                            },
                            text: "Share"),
                      ]),
                      SizedBox(height: h * 0.02),
                      AppLargeButtons(
                          text: "Done",
                          backgroundColor: Colors.white,
                          textColor: AppColor.mainColor,
                          onTap: () {
                            Get.offAll(() => MyHomePage());
                          })
                    ],
                  )
                    : Column(
                        children: [
                          SizedBox(height: h * 0.25),
                          AppLargeButtons(
                          text: "Select Product",
                          backgroundColor: Colors.white,
                          textColor: AppColor.mainColor,
                          onTap: () {
                            Get.offAll(() => MyHomePage());
                          }),
                        ],
                      ),
              ),
            )
          ],
        ),

    );
  }

  Future screenToPdf() async {
    final screenShot = await screenshotController.capture();
    pw.Document pdf = pw.Document();
    String fileName = "myFile";
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.legal,
        build: (context) {
          return pw.Expanded(
            child: pw.Image(pw.MemoryImage(screenShot!), fit: pw.BoxFit.cover),
          );
        },
      ),
    );
    String path = (await getTemporaryDirectory()).path;
    File pdfFile = await File('$path/$fileName.pdf').create();
    await pdfFile.writeAsBytes(await pdf.save());
    await Share.shareFiles([pdfFile.path]);
  }

  totalPrice() {
    num totals=0;
    for(int i = 0; i< productController.billData.length; i++){
      totals = int.parse(num.parse(productController.billData[i].totalPrice).ceil().toStringAsFixed(0)) + totals;
    }
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 230),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("₹ $totals.00",style: TextStyle(fontSize: 14),),
          ],
        ),
      );
  }
}
