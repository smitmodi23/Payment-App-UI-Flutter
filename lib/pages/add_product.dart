import 'package:flutter/material.dart';
import 'package:flutter_payment_app/controller/product_add_controller.dart';
import 'package:flutter_payment_app/db_helper/dbHelper.dart';
import 'package:flutter_payment_app/pages/my_home_page.dart';
import 'package:get/get.dart';

import '../component/colors.dart';
import '../widgets/buttons.dart';
import '../widgets/large_buttons.dart';
import 'add_customer.dart';

class ProductAdd extends StatefulWidget {
  ProductAdd({Key? key}) : super(key: key);

  @override
  State<ProductAdd> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final ProductController productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    productController.dbHelper = DatabaseHelper.instance;
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.backGroundColor,
      body: Container(
        height: h,
        child: Stack(
          children: [
            _headSection(),
            _listBills(),
            _payButton(),
          ],
        ),
      ),
    );
  }

  _headSection() {
    return Container(
        height: 310,
        child: Stack(
          children: [
            _mainBackground(),
            _curveImageContainer(),
            _buttonContainer(),
            _textContainer(),
          ],
        ));
  }

  _mainBackground() {
    return Positioned(
        bottom: 10,
        left: 0,
        child: Container(
          height: 300,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/background.png"))),
        ));
  }

  _curveImageContainer() {
    return Positioned(
        left: 0,
        right: -2,
        bottom: 10,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.1,
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/curve.png"))),
        ));
  }

  _buttonContainer() {
    return Positioned(
        bottom: 10,
        right: 45,
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet<dynamic>(
                isScrollControlled: true,
                barrierColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (BuildContext bc) {
                  return Container(
                      height: MediaQuery.of(context).size.height - 240,
                      child: Stack(children: [
                        Positioned(
                          bottom: 0,
                          child: Container(
                            color: Color(0xFFeef1f4).withOpacity(0.7),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height - 300,
                          ),
                        ),
                        Positioned(
                            top: 0,
                            right: 45,
                            child: Container(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 25),
                                width: 60,
                                height: 250,
                                decoration: BoxDecoration(
                                  color: AppColor.mainColor,
                                  borderRadius: BorderRadius.circular(29),
                                ),
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppButtons(
                                          icon: Icons.cancel,
                                          iconColor: AppColor.mainColor,
                                          textColor: Colors.white,
                                          backgroundColor: Colors.white,
                                          onTap: () {
                                            Navigator.pop(context);
                                          }),
                                      AppButtons(
                                          icon: Icons.add,
                                          iconColor: AppColor.mainColor,
                                          textColor: Colors.white,
                                          backgroundColor: Colors.white,
                                          onTap: () {
                                            Get.back();
                                            Get.back();
                                          },
                                          text: "Add Bills"),
                                      AppButtons(
                                          icon: Icons.person,
                                          iconColor: AppColor.mainColor,
                                          textColor: Colors.white,
                                          backgroundColor: Colors.white,
                                          onTap: () {
                                            Get.back();
                                            Get.back();
                                            Get.to(() => AddCustomer());
                                          },
                                          text: "Add Customer")
                                    ])))
                      ]));
                });
          },
          child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/lines.png"),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 15,
                      offset: Offset(0, 1),
                      color: Color(0xFF11324D).withOpacity(0.2),
                    )
                  ])),
        ));
  }

  _textContainer() {
    return Stack(children: [
      Positioned(
          left: 0,
          top: 100,
          child: Text(
            "Add\nProduct",
            style: TextStyle(
              fontSize: 70,
              fontWeight: FontWeight.bold,
              color: Color(0xFF293952),
            ),
          )),
      Positioned(
          left: 40,
          top: 80,
          child: Text(
            "Add\nProduct",
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )),
    ]);
  }

  _listBills() {
    return Positioned(
      top: 320,
      left: 0,
      right: 0,
      bottom: 0,
      child: MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 50,
                    child: TextFormField(
                      controller: productController.nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.black54)),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        labelText: "Product Name",
                      ),
                      onSaved: (value) {
                        productController.productModel.name = value;
                      },
                      validator: (value) {
                        return productController.validateName(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 50,
                    child: TextFormField(
                      controller: productController.priceCtrl,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.black54)),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        labelText: "Price",
                      ),
                      onSaved: (value) {
                        productController.productModel.price = value;
                      },
                      validator: (value) {
                        return productController.validatePrice(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          )),
    );
  }

  _payButton() {
    return Positioned(
        bottom: 10,
        child: Obx(
          () => AppLargeButtons(
              text: productController.isEdit.value ? "Edit" : "Add Product",
              textColor: Colors.white,
              onTap: () async {
                var form = formKey.currentState;
                if (form!.validate()) {
                  form.save();
                  productController.productModel.selected = "false";
                  productController.productModel.quantity = "1";
                  productController.productModel.totalPrice =
                      productController.priceCtrl.text;

                  if (productController.productModel.id != null) {
                    productController.updateProduct(productController.productModel);
                    // await productController.dbHelper!
                    //     .updateProduct(productController.productModel);
                  } else {
                    // await productController.dbHelper!
                        // .insertProduct(productController.productModel);
                    productController.addDBProduct(productController.productModel);
                  }
                  form.reset();
                  productController.nameCtrl.clear();
                  productController.qtyCtrl.clear();
                  productController.priceCtrl.clear();
                  Get.offAll(() => MyHomePage());
                  print("success");
                } else {
                  print("error");
                }

              }),
        ));
  }
}
