import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payment_app/controller/product_add_controller.dart';
import 'package:flutter_payment_app/pages/my_home_page.dart';
import 'package:get/get.dart';

import '../component/colors.dart';
import '../widgets/large_buttons.dart';
import 'add_customer.dart';

class ProductAdd extends StatefulWidget {
  const ProductAdd({Key? key}) : super(key: key);

  @override
  State<ProductAdd> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  final formKey = GlobalKey<FormState>();

  late final ProductController productController;

  @override
  void initState() {
    super.initState();

    productController = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: _buildForm(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomButton()),
    );
  }

  // Header
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 18, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF243B55), Color(0xFF141E30)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _headerIcon(
                icon: Icons.arrow_back_rounded,
                onTap: () => Get.back(),
              ),
              const Spacer(),
              _headerIcon(
                icon: Icons.more_horiz_rounded,
                onTap: _showQuickActions,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Obx(() {
            final isEdit = productController.isEdit.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'UPDATE PRODUCT' : 'NEW PRODUCT',
                  style: const TextStyle(
                    color: Color(0xFFB8C7D9),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEdit ? 'Edit Product' : 'Add Product',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEdit
                      ? 'Update your product details below.'
                      : 'Add product details to create a new bill.',
                  style: const TextStyle(
                    color: Color(0xFFD0D9E5),
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _headerIcon({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          height: 44,
          width: 44,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  // Form
  Widget _buildForm() {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF243247),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter the basic details of your product.',
            style: TextStyle(color: Color(0xFF8491A3), fontSize: 13),
          ),
          const SizedBox(height: 24),

          _buildInputLabel('Product Name'),
          const SizedBox(height: 9),
          TextFormField(
            controller: productController.nameCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hint: 'Enter product name',
              icon: Icons.inventory_2_outlined,
            ),
            onSaved: (value) {
              productController.productModel.name = value?.trim();
            },
            validator: (value) {
              return productController.validateName(value ?? '');
            },
          ),

          const SizedBox(height: 22),

          _buildInputLabel('Product Price'),
          const SizedBox(height: 9),
          TextFormField(
            controller: productController.priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: _inputDecoration(
              hint: 'Enter product price',
              icon: Icons.currency_rupee_rounded,
              prefixText: '₹ ',
            ),
            onSaved: (value) {
              productController.productModel.price = value?.trim();
            },
            validator: (value) {
              return productController.validatePrice(value ?? '');
            },
          ),

          const SizedBox(height: 28),

          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF344256),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      prefixIcon: Icon(icon, color: AppColor.mainColor, size: 21),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      hintStyle: const TextStyle(color: Color(0xFFA0AABA), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColor.mainColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF3974C6)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Make sure the product name and price are correct. '
              'You can edit product details later.',
              style: TextStyle(
                color: Color(0xFF45658F),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom action
  Widget _buildBottomButton() {
    return Obx(() {
      final isEdit = productController.isEdit.value;

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: AppLargeButtons(
          text: isEdit ? 'Update Product' : 'Add Product',
          height: 56,
          borderRadius: 15,
          fontSize: 16,
          margin: EdgeInsets.zero,
          textColor: Colors.white,
          backgroundColor: AppColor.mainColor,
          onTap: _saveProduct,
        ),
      );
    });
  }

  // Save product
  void _saveProduct() {
    FocusScope.of(context).unfocus();

    final form = formKey.currentState;

    if (form == null || !form.validate()) return;

    form.save();

    final product = productController.productModel;

    product.selected = 'false';
    product.quantity = '1';
    product.totalPrice = productController.priceCtrl.text.trim();

    if (product.id != null) {
      productController.updateProduct(product);
    } else {
      productController.addDBProduct(product);
    }

    _clearForm();

    Get.offAll(() => const MyHomePage());
  }

  void _clearForm() {
    formKey.currentState?.reset();

    productController.nameCtrl.clear();
    productController.priceCtrl.clear();
    productController.qtyCtrl.clear();
  }

  // Quick actions
  void _showQuickActions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 22),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _quickActionTile(
                icon: Icons.receipt_long_rounded,
                title: 'Add Bills',
                subtitle: 'Go back to your product list',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.back();
                },
              ),
              _quickActionTile(
                icon: Icons.person_add_alt_1_rounded,
                title: 'Add Customer',
                subtitle: 'Create a new customer',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.back();
                  Get.to(() => AddCustomer());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      leading: Container(
        height: 46,
        width: 46,
        decoration: BoxDecoration(
          color: AppColor.mainColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: AppColor.mainColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
      onTap: onTap,
    );
  }
}
