import 'package:flutter/material.dart';
import 'package:flutter_payment_app/model/product.dart';
import 'package:get/get.dart';

import '../db_helper/dbHelper.dart';

class ProductController extends GetxController {
  late TextEditingController nameCtrl = TextEditingController();
  late TextEditingController qtyCtrl = TextEditingController();
  late TextEditingController priceCtrl = TextEditingController();
  late TextEditingController productQtyController = TextEditingController();
  late TextEditingController customerCtrl = TextEditingController();

  var selected = "false".obs;
  var isSelected = false.obs;
  RxBool isEdit = false.obs;
  DatabaseHelper? dbHelper;
  ProductModel productModel = ProductModel();
  RxList productData = [].obs;
  RxList billData = [].obs;
  // var num = 0.obs;
  var totalPrice = 0.obs;
  var total = 0.obs;
  var totalPriceList = [].obs;
  var isTotal = false.obs;


  @override
  void onInit() {
    super.onInit();

    nameCtrl = TextEditingController();
    qtyCtrl = TextEditingController();
    priceCtrl = TextEditingController();
    customerCtrl = TextEditingController();
    productQtyController = TextEditingController();
  }

  @override
  void onClose() {
    super.onClose();
    nameCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
    customerCtrl.dispose();
    productQtyController.dispose();
  }


  String? validateName(String value) {
    if (value == "" && value.isEmpty) {
      return "Enter Product Name";
    }
    return null;
  }

  String? validateCustomer(String value) {
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
  }

  void getBill() async{
    await dbHelper!.getProductBill("true").then((value){
      if(value.isNotEmpty){
        billData.value = value;
      }
    });
  }

  // void increment() {
  //   num += 1;
  // }
  //
  // void decrement() {
  //   num -= 1;
  // }

  void quantityAddRemove(int index, int type){
    productModel.id = productData[index].id;
    productModel.name = productData[index].name;
    productModel.quantity = productData[index].quantity;
    productModel.price = productData[index].price;
    productModel.totalPrice = productData[index].totalPrice;
    if(type == 1) {
      if(num.parse(productData[index].quantity) > 1){
        productModel.quantity = "${num.parse(productData[index].quantity) - 1}";
      }
    }else if(type == 2){
      productModel.quantity = "${num.parse(productData[index].quantity) + 1}";
    }else if(type == 3){
      productModel.quantity = qtyCtrl.text;
    }
    productModel.selected = "false";
    dbHelper!.updateProduct(productModel);
    getData();
  }

  void onClickMarriedRadioButton(value) {
    selected.value = value;
    update();
  }
}
