import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../component/colors.dart';
import '../controller/product_add_controller.dart';
import '../widgets/large_buttons.dart';
import 'my_home_page.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({Key? key}) : super(key: key);

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  final formKey = GlobalKey<FormState>();

  late final ProductController productController;

  bool isSaving = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    productController = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());

    _loadCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backGroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
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

  // Header - Same as ProductAdd
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
          const Text(
            'CUSTOMER DETAILS',
            style: TextStyle(
              color: Color(0xFFB8C7D9),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add Customer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter customer details to continue.',
            style: TextStyle(color: Color(0xFFD0D9E5), fontSize: 14),
          ),
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

  // Customer Form
  Widget _buildForm() {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF243247),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter the basic details of your customer.',
            style: TextStyle(color: Color(0xFF8491A3), fontSize: 13),
          ),
          const SizedBox(height: 24),

          _buildInputLabel('Customer Name'),
          const SizedBox(height: 9),

          TextFormField(
            controller: productController.customerCtrl,
            enabled: !isLoading,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: _inputDecoration(
              hint: 'Enter customer name',
              icon: Icons.person_outline_rounded,
            ),
            validator: (value) {
              return productController.validateCustomer(value?.trim() ?? '');
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
  }) {
    return InputDecoration(
      hintText: hint,
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
              'Customer name will be saved for your invoice. '
              'You can update it whenever required.',
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

  // Bottom Button - Same as ProductAdd
  Widget _buildBottomButton() {
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
        text: isSaving ? 'Saving...' : 'Add Customer',
        height: 56,
        borderRadius: 15,
        fontSize: 16,
        margin: EdgeInsets.zero,
        textColor: Colors.white,
        backgroundColor: AppColor.mainColor,
        onTap: isSaving || isLoading ? null : _saveCustomer,
      ),
    );
  }

  // Load saved customer
  Future<void> _loadCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? '';

    if (!mounted) return;

    productController.customerCtrl.text = name;

    setState(() {
      isLoading = false;
    });
  }

  // Save customer
  Future<void> _saveCustomer() async {
    FocusScope.of(context).unfocus();

    if (isSaving) return;

    final form = formKey.currentState;

    if (form == null || !form.validate()) return;

    final name = productController.customerCtrl.text.trim();

    setState(() {
      isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);

      if (!mounted) return;

      Get.offAll(() => const MyHomePage());
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Unable to save customer details.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // Quick Actions
  void _showQuickActions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
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
              const SizedBox(height: 12),
              _quickActionTile(
                icon: Icons.receipt_long_rounded,
                title: 'Add Bills',
                subtitle: 'Go back to product list',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.offAll(() => const MyHomePage());
                },
              ),
              _quickActionTile(
                icon: Icons.history_rounded,
                title: 'History',
                subtitle: 'View previous bills',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.snackbar(
                    'History',
                    'History screen is not connected yet.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
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
