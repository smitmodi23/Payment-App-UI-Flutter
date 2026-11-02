import 'package:flutter/material.dart';
import 'package:flutter_payment_app/component/colors.dart';

class AppLargeButtons extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;
  final String text;
  final VoidCallback? onTap;
  final bool isBorder;
  final double height;
  final double borderRadius;
  final double fontSize;
  final EdgeInsetsGeometry margin;

  const AppLargeButtons({
    Key? key,
    this.backgroundColor = AppColor.mainColor,
    this.textColor = Colors.white,
    this.onTap,
    this.isBorder = false,
    this.height = 56,
    this.borderRadius = 14,
    this.fontSize = 17,
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return Container(
      width: double.infinity,
      height: height,
      margin: margin,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: isBorder
                  ? Border.all(color: AppColor.mainColor, width: 1.5)
                  : null,
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDisabled
                    ? (textColor ?? Colors.white).withValues(alpha: 0.5)
                    : textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
