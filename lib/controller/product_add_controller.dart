import 'package:flutter/material.dart';
import 'package:flutter_payment_app/model/product.dart';
import 'package:get/get.dart';

import '../db_helper/dbHelper.dart';

class ProductController extends GetxController {
  late TextEditingController nameCtrl = TextEditingController();
  late TextEditingController qtyCtrl = TextEditingController();
  late TextEditingController priceCtrl = TextEditingController();
  late TextEditingController productQtyController = TextEditingController();

  var selected = "false".obs;
  var isSelected = false.obs;
  DatabaseHelper? dbHelper;
  final ProductModel productModel = ProductModel();
  RxList productData = [].obs;
  RxList billData = [].obs;
  var num = 0.obs;


  @override
  void onInit() {
    super.onInit();

    nameCtrl = TextEditingController();
    qtyCtrl = TextEditingController();
    priceCtrl = TextEditingController();
    productQtyController = TextEditingController();
    productQtyController.text = num.toString();
  }

  @override
  void onClose() {
    super.onClose();
    nameCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
    productQtyController.dispose();
  }

  String? validateName(String value) {
    if (value == "" && value.isEmpty) {
      return "Enter Product Name";
    }
    return null;
  }

  String? validateQuantity(String value) {
    if (value == "0") {
      return "Add Quantity";
    }
    return null;
  }

  String? validatePrice(String value) {
    if (value == "" && value.isEmpty) {
      return "Enter Price";
    }
    return null;
  }

  void getData() async {
    List<ProductModel> x = await dbHelper!.getProductData();
      productData.value = x;
      print(productData.value);
  }

  void getBill() async{
    await dbHelper!.getProductBill("true").then((value){
      if(value != null){
        billData.value = value;
      }
    });

    print(billData.value);
  }

  void increment() {
    num += 1;
  }

  void decrement() {
    num -= 1;
  }


  void onClickMarriedRadioButton(value) {
    selected.value = value;
    update();
  }
}
