import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_payment_app/model/product.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Text Controllers
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController customerCtrl = TextEditingController();

  // Database
  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  // Reactive State
  final RxBool isEdit = false.obs;

  final RxList<ProductModel> productData = <ProductModel>[].obs;
  final RxList<ProductModel> billData = <ProductModel>[].obs;

  ProductModel productModel = ProductModel();

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
    customerCtrl.dispose();

    super.onClose();
  }

  // ---------------- VALIDATION ----------------

  String? validateName(String value) {
    if (value.trim().isEmpty) {
      return 'Enter Product Name';
    }
    return null;
  }

  String? validateCustomer(String value) {
    if (value.trim().isEmpty) {
      return 'Enter Customer Name';
    }
    return null;
  }

  String? validateQuantity(String value) {
    final quantity = int.tryParse(value.trim());

    if (quantity == null || quantity <= 0) {
      return 'Enter a valid quantity';
    }

    return null;
  }

  String? validatePrice(String value) {
    final price = double.tryParse(value.trim());

    if (price == null || price <= 0) {
      return 'Enter a valid price';
    }

    return null;
  }

  // ---------------- FIRESTORE STREAM ----------------

  Stream<List<ProductModel>> readProduct() {
    return _products.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  // ---------------- GET PRODUCTS ----------------

  Future<void> getData() async {
    try {
      final snapshot = await _products.get();

      final products = snapshot.docs.map((doc) {
        return ProductModel.fromMap({...doc.data(), 'id': doc.id});
      }).toList();

      productData.assignAll(products);
    } catch (e, stackTrace) {
      debugPrint('Get Products Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // ---------------- GET SELECTED BILL ----------------

  Future<void> getBill() async {
    try {
      final snapshot = await _products
          .where('selected', isEqualTo: 'true')
          .get();

      final products = snapshot.docs.map((doc) {
        return ProductModel.fromMap({...doc.data(), 'id': doc.id});
      }).toList();

      billData.assignAll(products);
    } catch (e, stackTrace) {
      debugPrint('Get Bill Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // ---------------- ADD PRODUCT ----------------

  Future<void> addDBProduct(ProductModel product) async {
    try {
      final doc = _products.doc();

      product.id = doc.id;

      await doc.set(product.toMap());

      productData.add(product);
    } catch (e, stackTrace) {
      debugPrint('Add Product Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // ---------------- UPDATE PRODUCT ----------------

  Future<void> updateProduct(ProductModel product) async {
    try {
      final id = product.id;

      if (id == null || id.isEmpty) {
        throw Exception('Product ID is missing');
      }

      await _products.doc(id).update(product.toMap());

      final index = productData.indexWhere((item) => item.id == id);

      if (index != -1) {
        productData[index] = product;
      }

      final billIndex = billData.indexWhere((item) => item.id == id);

      if (billIndex != -1) {
        if (product.selected == 'true') {
          billData[billIndex] = product;
        } else {
          billData.removeAt(billIndex);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Update Product Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // ---------------- DELETE PRODUCT ----------------

  Future<void> deleteProduct(String? id) async {
    try {
      await _products.doc(id).delete();

      productData.removeWhere((item) => item.id == id);
      billData.removeWhere((item) => item.id == id);
    } catch (e, stackTrace) {
      debugPrint('Delete Product Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // ---------------- QUANTITY UPDATE ----------------

  Future<void> quantityAddRemove(int index, int type) async {
    if (index < 0 || index >= productData.length) return;

    final currentProduct = productData[index];

    final currentQuantity = int.tryParse(currentProduct.quantity ?? '0') ?? 0;

    int newQuantity;

    switch (type) {
      case 1:
        if (currentQuantity <= 1) return;
        newQuantity = currentQuantity - 1;
        break;

      case 2:
        newQuantity = currentQuantity + 1;
        break;

      case 3:
        final enteredQuantity = int.tryParse(qtyCtrl.text.trim());

        if (enteredQuantity == null || enteredQuantity <= 0) {
          return;
        }

        newQuantity = enteredQuantity;
        break;

      default:
        return;
    }

    final updatedProduct = ProductModel()
      ..id = currentProduct.id
      ..name = currentProduct.name
      ..price = currentProduct.price
      ..quantity = newQuantity.toString()
      ..totalPrice = currentProduct.totalPrice
      ..selected = 'false';

    await updateProduct(updatedProduct);

    // Clear selection after quantity modification.
    qtyCtrl.clear();
  }
}
