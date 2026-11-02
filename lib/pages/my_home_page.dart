import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payment_app/component/colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/product_add_controller.dart';
import 'add_customer.dart';
import 'add_product.dart';
import 'payment_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ProductController controller = Get.put(ProductController());

  final GlobalKey<FormState> quantityFormKey = GlobalKey<FormState>();

  static const Color primary = Color(0xFF2457D6);
  static const Color background = Color(0xFFF5F7FB);
  static const Color dark = Color(0xFF17233C);
  final NumberFormat currencyFormat = NumberFormat('#,##,##0.00', 'en_IN');

  @override
  void initState() {
    super.initState();
    controller.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                final products = controller.productData;

                if (products.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  itemCount: products.length,
                  physics: const ClampingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return _ProductCard(
                      key: ValueKey(product.id),
                      name: product.name ?? '',
                      price: _toNum(product.price),
                      quantity: _toNum(product.quantity),
                      selected: product.selected == 'true',
                      onIncrement: () => controller.quantityAddRemove(index, 2),
                      onDecrement: () => controller.quantityAddRemove(index, 1),
                      onEditQuantity: () => showQuantityDialog(index),
                      onSelect: () => _toggleSelection(index),
                      onEdit: () => _editProduct(index),
                      onDelete: () => _deleteProduct(index),
                    );
                  },
                );
              }),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF172D56), Color(0xFF2457D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Bill',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Manage your products & invoices',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showAddMenu,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primary,
                ),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Obx(() {
            final count = controller.productData.length;

            final selectedProducts = controller.productData
                .where((p) => p.selected == 'true')
                .toList();

            final selectedCount = selectedProducts.length;

            final selectedTotal = selectedProducts.fold<num>(0, (sum, p) {
              final quantity = _toNum(p.quantity);
              final price = _toNum(p.price);

              return sum + (quantity * price);
            });

            return Row(
              children: [
                Expanded(
                  child: _headerStat(
                    'Products',
                    '$count',
                    Icons.inventory_2_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _headerStat(
                    'Selected',
                    '$selectedCount',
                    Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _headerStat(
                    'Selected Value',
                    '₹${selectedTotal.toStringAsFixed(0)}',
                    Icons.currency_rupee,
                    animated: true,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _headerStat(
    String title,
    String value,
    IconData icon, {
    bool animated = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 19),
          const SizedBox(height: 9),

          if (animated)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: double.tryParse(value.replaceAll('₹', '')) ?? 0,
              ),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, amount, child) {
                return Text(
                  '₹${currencyFormat.format(amount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            )
          else
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

          const SizedBox(height: 3),

          Text(
            title,
            maxLines: 1,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: primary,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No Products Yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first product to start creating bills.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addProduct,
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTTOM BAR
  Widget _buildBottomBar() {
    return Obx(() {
      final products = controller.productData;
      final hasProducts = products.isNotEmpty;

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: hasProducts ? checkUser : _addProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(hasProducts ? Icons.receipt_long : Icons.add),
                const SizedBox(width: 10),
                Text(
                  hasProducts ? 'Create Invoice' : 'Add Product',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ADD MENU
  void _showAddMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _actionTile(
              Icons.add_box_outlined,
              'Add Product',
              'Create a new product',
              _addProduct,
            ),
            const SizedBox(height: 12),
            _actionTile(
              Icons.person_add_alt_1,
              'Add Customer',
              'Add customer details',
              () => Get.to(() => AddCustomer()),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _actionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      tileColor: const Color(0xFFF5F7FB),
      leading: CircleAvatar(
        backgroundColor: primary.withValues(alpha: 0.1),
        child: Icon(icon, color: primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 15),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }

  // ADD PRODUCT
  void _addProduct() {
    controller.nameCtrl.clear();
    controller.priceCtrl.clear();
    controller.isEdit.value = false;
    controller.productModel.id = null;

    Get.to(() => ProductAdd());
  }

  // EDIT PRODUCT
  void _editProduct(int index) {
    final product = controller.productData[index];

    controller.nameCtrl.text = product.name!;
    controller.priceCtrl.text = product.price!;
    controller.isEdit.value = true;

    controller.productModel
      ..id = product.id
      ..name = product.name
      ..price = product.price;

    Get.to(() => ProductAdd());
  }

  // DELETE PRODUCT
  Future<void> _deleteProduct(int index) async {
    final product = controller.productData[index];

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.deleteProduct(product.id);
    }
  }

  // QUANTITY DIALOG

  Future<void> showQuantityDialog(int index) async {
    final product = controller.productData[index];

    final int currentQuantity = int.tryParse(product.quantity.toString()) ?? 1;

    controller.qtyCtrl.text = currentQuantity.toString();

    final quantityFormKey = GlobalKey<FormState>();

    await Get.bottomSheet(
      Builder(
        builder: (context) {
          final screenHeight = MediaQuery.of(context).size.height;

          return SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.55),
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Form(
                          key: quantityFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Drag Handle
                              Center(
                                child: Container(
                                  width: 42,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              // Title
                              const Center(
                                child: Text(
                                  'Update Quantity',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Product Name
                              Center(
                                child: Text(
                                  product.name.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Label
                              const Text(
                                'SELECT QUANTITY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Quantity Controls
                              Row(
                                children: [
                                  // Minus Button
                                  _quantityControl(
                                    icon: Icons.remove,
                                    onTap: () {
                                      int quantity =
                                          int.tryParse(
                                            controller.qtyCtrl.text,
                                          ) ??
                                          1;

                                      if (quantity > 1) {
                                        quantity--;

                                        setModalState(() {
                                          controller.qtyCtrl.text = quantity
                                              .toString();
                                        });
                                      }
                                    },
                                  ),

                                  const SizedBox(width: 16),

                                  // Quantity Input
                                  Expanded(
                                    child: TextFormField(
                                      controller: controller.qtyCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: false,
                                          ),
                                      autofocus: false,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        hintText: 'Enter quantity',
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: 12,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColor.mainColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        return controller.validateQuantity(
                                          value ?? '',
                                        );
                                      },
                                      onChanged: (_) {
                                        setModalState(() {});
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Plus Button
                                  _quantityControl(
                                    icon: Icons.add,
                                    onTap: () {
                                      int quantity =
                                          int.tryParse(
                                            controller.qtyCtrl.text,
                                          ) ??
                                          0;

                                      quantity++;

                                      setModalState(() {
                                        controller.qtyCtrl.text = quantity
                                            .toString();
                                      });
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),

                              // Action Buttons
                              Row(
                                children: [
                                  // Cancel
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        controller.qtyCtrl.clear();
                                        Get.back();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(
                                          double.infinity,
                                          52,
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Update
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (!(quantityFormKey.currentState
                                                ?.validate() ??
                                            false)) {
                                          return;
                                        }

                                        final newQuantity = controller
                                            .qtyCtrl
                                            .text
                                            .trim();

                                        // Keep value for controller method.
                                        controller.qtyCtrl.text = newQuantity;

                                        // Close keyboard and bottom sheet.
                                        FocusScope.of(context).unfocus();
                                        Get.back();

                                        try {
                                          await controller.quantityAddRemove(
                                            index,
                                            3,
                                          );

                                          Get.snackbar(
                                            'Success',
                                            'Quantity updated successfully.',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                        } catch (e) {
                                          Get.snackbar(
                                            'Error',
                                            'Unable to update quantity.',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                        } finally {
                                          controller.qtyCtrl.clear();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.mainColor,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(
                                          double.infinity,
                                          52,
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Update',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
    );

    // Clear controller when sheet is dismissed.
    controller.qtyCtrl.clear();
  }

  Widget _quantityControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColor.mainColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 46,
          width: 46,
          child: Icon(icon, color: AppColor.mainColor),
        ),
      ),
    );
  }

  // SELECT / UNSELECT
  void _toggleSelection(int index) {
    final product = controller.productData[index];

    final quantity = _toNum(product.quantity);
    final price = _toNum(product.price);

    controller.productModel
      ..id = product.id
      ..name = product.name
      ..quantity = product.quantity
      ..price = product.price
      ..totalPrice = (quantity * price).toString()
      ..selected = product.selected == 'true' ? 'false' : 'true';

    controller.updateProduct(controller.productModel);
    controller.getData();
  }

  // CUSTOMER CHECK
  Future<void> checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');

    if (!mounted) return;

    if (name != null && name.trim().isNotEmpty) {
      Get.to(() => PaymentPage(name));
    } else {
      Get.to(() => AddCustomer());
      Get.snackbar(
        'Customer Required',
        'Please add customer name first.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  num _toNum(dynamic value) {
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}

// PRODUCT CARD
class _ProductCard extends StatelessWidget {
  _ProductCard({
    Key? key,
    required this.name,
    required this.price,
    required this.quantity,
    required this.selected,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEditQuantity,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  final String name;
  final num price;
  final num quantity;
  final bool selected;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onEditQuantity;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  static const Color primary = Color(0xFF2457D6);

  final NumberFormat currencyFormat = NumberFormat('#,##,##0.00', 'en_IN');

  @override
  Widget build(BuildContext context) {
    final total = quantity == 0 ? price : quantity * price;

    return Dismissible(
      key: ValueKey('$name-${price.toString()}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: Colors.red.shade500,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onLongPress: onEdit,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? primary.withValues(alpha: 0.5)
                    : const Color(0xFFEDF0F5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: primary,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF17233C),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${price.toStringAsFixed(2)} / unit',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const Spacer(),
                    _quantityButton(Icons.remove, onDecrement),
                    GestureDetector(
                      onTap: onEditQuantity,
                      child: Container(
                        width: 58,
                        height: 34,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FB),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    _quantityButton(Icons.add, onIncrement),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onSelect,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? primary.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 15,
                              color: selected ? primary : Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              selected ? 'Selected' : 'Select',
                              style: TextStyle(
                                color: selected ? primary : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '₹${currencyFormat.format(total)}',
                          style: const TextStyle(
                            color: Color(0xFF17233C),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: primary, size: 18),
      ),
    );
  }
}
