import 'package:flutter/material.dart';
import 'package:flutter_payment_app/model/product.dart';
import 'package:get/get.dart';

import '../db_helper/dbHelper.dart';

class ProductController extends GetxController {
  late TextEditingController nameCtrl = TextEditingController();
  late TextEditingController qtyCtrl = TextEditingController();
  late TextEditingController priceCtrl = TextEditingController();

  var selected = "false".obs;
  var isSelected = false.obs;
  DatabaseHelper? dbHelper;
  final ProductModel productModel = ProductModel();
  RxList productData = [].obs;

  @override
  void onInit() {
    super.onInit();

    nameCtrl = TextEditingController();
    qtyCtrl = TextEditingController();
    priceCtrl = TextEditingController();
  }

  @override
  void onClose() {
    super.onClose();
    nameCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
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
    await dbHelper!.getProductData().then((value) {
      productData.value = value;
    }).onError((error, stackTrace) {
      print(error.toString());
    });
  }

  void onClickMarriedRadioButton(value) {
    selected.value = value;
    update();
  }
}
