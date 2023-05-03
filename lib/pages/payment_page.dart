import 'package:flutter/material.dart';
import 'package:flutter_payment_app/component/colors.dart';
import 'package:flutter_payment_app/pages/my_home_page.dart';
import 'package:flutter_payment_app/widgets/buttons.dart';
import 'package:flutter_payment_app/widgets/large_buttons.dart';
import 'package:get/get.dart';

import '../controller/product_add_controller.dart';
import '../db_helper/dbHelper.dart';
class PaymentPage extends StatefulWidget {
  const PaymentPage({ Key? key }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final ProductController productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    productController.dbHelper = DatabaseHelper.instance;
    productController.getBill();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 80,left: 20,right:20),
        height: h,
        width: w,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage("assets/images/paymentbackground.jpg"))),
        child: Column(
          children:[

          SizedBox(height:4),
          SizedBox(height: h*0.31),
          Container(
            height:160,
            width:350,
            child: Obx(() => MediaQuery.removePadding(
              removeTop: true,
              context:context,
              child: ListView.builder(
                itemCount: productController.billData.length,
                itemBuilder:(context,index){
                          return Container(
                            child: Column(
                              children: [
                                Row(children: [
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 10, bottom: 10),
                                      width: 20,
                                      height: 20,
                                      child: Center(
                                          child: Text("${index + 1}",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                              )))),
                                  SizedBox(width: 10),
                                  Text(
                                    "${productController.billData.value[index].name}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.mainColor,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          );
                        }


              ),
            ))
            )
          ,
          SizedBox(height: h * 0.16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButtons(icon: Icons.share_sharp,onTap: (){},text: "Share"),
              SizedBox(width: h*0.04),
              AppButtons(icon: Icons.print_outlined, onTap: () {}, text: "Print"),
            ]
          )
          ,
          SizedBox(height: h * 0.02),
          AppLargeButtons(text: "Done",backgroundColor:Colors.white,textColor: AppColor.mainColor,
           onTap: () {
              Get.to(() => MyHomePage());
            })
          ]
        ),
      ),
    );
  }
}