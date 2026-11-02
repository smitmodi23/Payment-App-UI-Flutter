import 'package:flutter/material.dart';
import 'package:flutter_payment_app/component/colors.dart';

class AppButtons extends StatelessWidget {
  final double fontSize;
  final double iconSize;
  final double buttonSize;
  final double spacing;

  final IconData icon;
  final VoidCallback? onTap;

  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  final String? text;

  const AppButtons({
    Key? key,
    this.fontSize = 14,
    this.iconSize = 26,
    this.buttonSize = 42,
    this.spacing = 5,
    this.textColor = AppColor.mainColor,
    this.iconColor = Colors.white,
    this.backgroundColor = AppColor.mainColor,
    this.text,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: buttonSize,
                width: buttonSize,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: iconSize, color: iconColor),
              ),
              if (text != null && text!.isNotEmpty) ...[
                SizedBox(height: spacing),
                SizedBox(
                  width: 65,
                  child: Text(
                    text!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
