import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/colors.dart';
import '../controller/product_add_controller.dart';
import '../widgets/buttons.dart';
import '../widgets/large_buttons.dart';
import 'my_home_page.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({Key? key}) : super(key: key);

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final ProductController productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    checkUser();
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
                                          onTap: () {},
                                          text: "Add Bills"),
                                      AppButtons(
                                          icon: Icons.history,
                                          iconColor: AppColor.mainColor,
                                          textColor: Colors.white,
                                          backgroundColor: Colors.white,
                                          onTap: () {},
                                          text: "History")
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
            "Add\nCustomer",
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
            "Add\nCustomer",
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
                      controller: productController.customerCtrl,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            const BorderSide(color: Colors.red, width: 2)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black54)),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),

                        labelText: "Customer Name",
                      ),
                      onSaved: (value) {
                        saveData(value);
                      },
                      validator: (value) {
                        return productController.validateCustomer(value!);
                      },
                    ),
                  ),

                ],
              ),
            ),
          )
      ),
    );
  }

  _payButton() {
    return Positioned(
        bottom: 10,
        child: AppLargeButtons(
            text: "Add Customer",
            textColor: Colors.white,
            onTap: () async{
              var form = formKey.currentState;
              if(form!.validate()){
                form.save();
                // productController.isSelected.value = false;
                form.reset();
                productController.customerCtrl.clear();
                Get.offAll(()=>MyHomePage());
                print("success");
              }else{
                print("error");
              }

              // Get.to(() => MyHomePage());
            }
        )
    );
  }

  void saveData(String? value) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("name", value!);
  }

  void checkUser() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString("name");
    if(name != null){
      productController.customerCtrl.text = name;
    }else{
      productController.customerCtrl.text = "";
    }
  }

}
