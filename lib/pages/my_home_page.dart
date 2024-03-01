import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payment_app/component/colors.dart';
import 'package:flutter_payment_app/pages/add_customer.dart';
import 'package:flutter_payment_app/pages/add_product.dart';
import 'package:flutter_payment_app/pages/payment_page.dart';
import 'package:flutter_payment_app/widgets/buttons.dart';
import 'package:flutter_payment_app/widgets/large_buttons.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/product_add_controller.dart';
import '../db_helper/dbHelper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ProductController productController = Get.put(ProductController());
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    productController.dbHelper = DatabaseHelper.instance;
    productController.getData();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
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
                                            Get.back();
                                          }),
                                      AppButtons(
                                          icon: Icons.add,
                                          iconColor: AppColor.mainColor,
                                          textColor: Colors.white,
                                          backgroundColor: Colors.white,
                                          onTap: () {
                                            productController.nameCtrl.text = '';
                                            productController.priceCtrl.text = '';
                                            productController.isEdit.value = false;
                                            productController.productModel.id = null;
                                            Get.back();
                                            Get.to(() => ProductAdd());
                                          },
                                          text: "Add Product"),
                                      AppButtons(
                                          icon: Icons.person,
                                          iconColor: AppColor.mainColor,
                                          textColor: Colors.white,
                                          backgroundColor: Colors.white,
                                          onTap: () {
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

  _listBills() {
    return Obx(
      () => (productController.productData.length != 0)
          ? Positioned(
              top: 320,
              left: 0,
              right: 0,
              bottom: 80,
              child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: ListView.builder(
                    itemCount: productController.productData.length,
                    itemBuilder: (_, index) {
                      return InkWell(
                        onLongPress: () {
                          productController.nameCtrl.text = productController.productData[index].name;
                          productController.priceCtrl.text = productController.productData[index].price;
                          productController.isEdit.value = true;
                          productController.productModel.name = productController.productData[index].name;
                          productController.productModel.price = productController.productData[index].price;
                          productController.productModel.id = productController.productData[index].id;
                          Get.to(() => ProductAdd());
                        },
                        child: Dismissible(
                          key: ValueKey<int>(
                              productController.productData[index].id),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              productController.getData();
                            }
                          },
                          /*background: Container(
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Edit..".toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),*/
                          background: Container(
                            color: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.delete, color: Colors.white),
                                  Text(
                                    "Delete..".toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            // if(direction == DismissDirection.endToStart) {
                              return await Get.defaultDialog(
                                  title: "Confirm Delete",
                                  content: const Text(
                                      "Are you sure you want to delete this item?"),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                          productController.dbHelper!
                                              .deleteHelpData(productController
                                                  .productData[index].id);
                                        },
                                        child: Text("Delete")),
                                    ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: Text("Cancel")),
                                  ]);
                            /*}else{
                              return await Get.defaultDialog(
                                  title: "Confirm Edit",
                                  content: const Text(
                                      "Are you sure you want to edit this item?"),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                          Get.to(() => ProductAdd(index: index));
                                        },
                                        child: Text("Edit")),
                                    ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: Text("Cancel")),
                                  ]);
                            }*/
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 20, right: 20),
                            height: 110,
                            width: MediaQuery.of(context).size.width - 20,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomRight: Radius.circular(30)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFd8dbe0),
                                    offset: Offset(1, 1),
                                    blurRadius: 20.0,
                                    spreadRadius: 10,
                                  )
                                ]),
                            child: Container(
                              margin: const EdgeInsets.only(top: 10, left: 18),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  width: 3,
                                                  color: Colors.grey,
                                                ),
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: AssetImage(
                                                        "assets/images/brand1.jpeg"))),
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${productController.productData[index].name}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: AppColor.mainColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                "Quantity : ",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: AppColor.idColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    child: Container(
                                                      margin: EdgeInsets.all(0.0),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors.grey),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                2.0),
                                                        child: Icon(Icons.remove,
                                                            size: 16),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      productController.quantityAddRemove(index, 1);
                                                    },
                                                  ),
                                                  SizedBox(width: 8),
                                                  GestureDetector(
                                                    child: Container(
                                                        width: 55,
                                                        height: 30,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                              color: Colors.grey,
                                                              // set border color
                                                              width: 1.0),
                                                          // set border width
                                                          borderRadius: BorderRadius
                                                              .all(Radius.circular(
                                                                  4.0)), // set rounded corner radius
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "${productController.productData[index].quantity}",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: AppColor
                                                                  .idColor,
                                                              fontWeight:
                                                                  FontWeight.w700,
                                                            ),
                                                          ),
                                                        )),
                                                    onLongPress: () {
                                                      productController
                                                              .qtyCtrl.text =
                                                          productController
                                                              .productData[index]
                                                              .quantity;
                                                      Get.defaultDialog(
                                                        barrierDismissible: false,
                                                        title: "Add Quantity",
                                                        content: Form(
                                                          key: formKey,
                                                          child: SizedBox(
                                                            height: 40,
                                                            width: 80,
                                                            child: TextFormField(
                                                              controller:
                                                                  productController
                                                                      .qtyCtrl,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly
                                                              ],
                                                              textAlign: TextAlign
                                                                  .center,
                                                              decoration:
                                                                  InputDecoration(
                                                                focusedBorder: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                10),
                                                                    borderSide: const BorderSide(
                                                                        color: Colors
                                                                            .red,
                                                                        width:
                                                                            2)),
                                                                enabledBorder: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                10),
                                                                    borderSide:
                                                                        const BorderSide(
                                                                            color:
                                                                                Colors.black54)),
                                                                labelText:
                                                                    "Quantity",
                                                              ),
                                                              onSaved: (value) {
                                                                productController
                                                                    .productModel
                                                                    .quantity = value;
                                                              },
                                                              validator: (value) {
                                                                return productController
                                                                    .validateQuantity(
                                                                        value!);
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        textConfirm: "Add",
                                                        textCancel: "Cancel",
                                                        confirmTextColor:
                                                            Colors.white,
                                                        onConfirm: () async {
                                                          var form = formKey
                                                              .currentState;
                                                          if (form!.validate()) {
                                                            form.save();
                                                            productController.quantityAddRemove(index, 3);
                                                            form.reset();
                                                            productController.qtyCtrl.clear();
                                                            Get.back();
                                                          } else {
                                                            Get.snackbar("Fail",
                                                                "Failed to save Data....");
                                                          }
                                                        },
                                                        onCancel: () {
                                                          Get.back();
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(width: 8),
                                                  GestureDetector(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors.grey),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                2.0),
                                                        child: Icon(Icons.add,
                                                            size: 16),
                                                      ),
                                                    ),
                                                    onTap: (){
                                                      productController.quantityAddRemove(index, 2);
                                                    }
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Obx(
                                            () => Container(
                                              width: 80,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                    color:
                                                        ("${productController.productData[index].selected}" ==
                                                                "true")
                                                            ? Colors.orange
                                                            : Colors.grey),
                                              ),
                                              child: Center(
                                                child: GestureDetector(
                                                  child: Text("Select",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              ("${productController.productData[index].selected}" ==
                                                                      "true")
                                                                  ? Colors.orange
                                                                  : Colors.grey)),
                                                  onTap: () {
                                                    productController.productModel.id = productController.productData[index].id;
                                                    productController.productModel.name = productController.productData[index].name;
                                                    productController.productModel.quantity = productController.productData[index].quantity;
                                                    productController.productModel.price = productController.productData[index].price;
                                                    if ("${num.parse(productController.productData[index].quantity) * num.parse(productController.productData[index].price)}" !=
                                                        productController.productModel.totalPrice) {productController.productModel.totalPrice = "${num.parse(productController.productData[index].quantity) * num.parse(productController.productData[index].price)}";
                                                    } else {
                                                      productController.productModel.totalPrice = productController.productData[index].totalPrice;
                                                    }
                                                    if (productController.productData[index].selected == "true") {
                                                      productController.productModel.selected = "false";
                                                    } else {
                                                      productController.productModel.selected = "true";
                                                    }
                                                    productController.dbHelper!.updateProduct(productController.productModel);productController.getData();
                                                    // productController.onClickMarriedRadioButton(value);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(child: Container()),
                                          Text(
                                            (productController.productData
                                                        [index].quantity ==
                                                    "0")
                                                ? "₹ ${num.parse(productController.productData[index].price)}"
                                                : "₹ ${(num.parse(productController.productData[index].quantity) * num.parse(productController.productData[index].price)).toStringAsFixed(2)}",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: AppColor.mainColor),
                                          ),
                                          Text(
                                            "Total Price",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: AppColor.idColor),
                                          ),
                                          SizedBox(height: 10)
                                        ],
                                      ),
                                      SizedBox(width: 5),
                                      Container(
                                        width: 5,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            color: AppColor.halfOval,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(30),
                                              bottomLeft: Radius.circular(30),
                                            )),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            )
          : Positioned(
              top: 320,
              left: 0,
              right: 0,
              bottom: 80,
              child: Center(
                child: Text("No Product Found "),
              )),
    );
  }

  _payButton() {
    return Obx(
      () => Positioned(
          bottom: 10,
          child: (productController.productData.length != 0)
              ? AppLargeButtons(
                  text: "Pay All Bills",
                  textColor: Colors.white,
                  onTap: () {
                    checkUser();
                  })
              : AppLargeButtons(
                  text: "Add Product",
                  textColor: Colors.white,
                  onTap: () {
                    productController.nameCtrl.text = '';
                    productController.priceCtrl.text = '';
                    productController.isEdit.value = false;
                    productController.productModel.id = null;
                    Get.to(() => ProductAdd());
                  })),
    );
  }

  _textContainer() {
    return Stack(children: [
      Positioned(
          left: 0,
          top: 100,
          child: Text(
            "My Bill",
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
            "My Bill",
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )),
    ]);
  }

  void checkUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString("name");
    if (name != null) {
      Get.to(() => PaymentPage(name));
    } else {
      Get.to(() => AddCustomer());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("please First Add Customer Name")));
    }
  }
}
