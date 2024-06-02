import 'package:cloud_firestore/cloud_firestore.dart';
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

  Stream<List<ProductModel>> readProduct() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList());

  void getData() async {
    // Get a snapshot of the 'product' collection
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    // Map each document in the snapshot to a ProductModel object and return the list
    List<ProductModel> x = snapshot.docs.map((doc) {
      return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
    productData.value = x;
  }

  void getBill() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('selected', isEqualTo: "true")
        .get();

    List<ProductModel> products = snapshot.docs.map((doc) {
      return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
      billData.value = products;
  }

  void quantityAddRemove(int index, int type) {
    productModel.id = productData[index].id;
    productModel.name = productData[index].name;
    productModel.quantity = productData[index].quantity;
    productModel.price = productData[index].price;
    productModel.totalPrice = productData[index].totalPrice;
    if (type == 1) {
      if (num.parse(productData[index].quantity) > 1) {
        productModel.quantity = "${num.parse(productData[index].quantity) - 1}";
      }
    } else if (type == 2) {
      productModel.quantity = "${num.parse(productData[index].quantity) + 1}";
    } else if (type == 3) {
      productModel.quantity = qtyCtrl.text;
    }
    productModel.selected = "false";
    // dbHelper!.updateProduct(productModel);
    updateProduct(productModel);
    getData();
  }

  void onClickMarriedRadioButton(value) {
    selected.value = value;
    update();
  }

  Future deleteProduct(String id) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(id)
        .delete();

    getData();
  }

  Future addDBProduct(ProductModel productModel) async {
    final docUser = FirebaseFirestore.instance.collection('products').doc();
    productModel.id = docUser.id;

    final json = productModel.toMap();
    await docUser.set(json);
  }

  Future updateProduct(ProductModel productModel) async {
    final docUser =
        FirebaseFirestore.instance.collection('products').doc(productModel.id);

    final json = productModel.toMap();
    await docUser.update(json);
  }
}
