import 'package:flutter/material.dart';
import 'package:flutter_payment_app/component/colors.dart';
class AppButtons extends StatelessWidget {
  final double? fontSize;
  final IconData icon;
  final Function()? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final String? text;
  const AppButtons({ Key? key,
    this.fontSize=20,
    this.textColor=AppColor.mainColor,
    this.iconColor=Colors.white,
    this.backgroundColor=AppColor.mainColor,
    this.text,
    required this.icon,
    this.onTap



   }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width:40,
            height:40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color:backgroundColor,
            ),
            child:Icon(icon,size: 30, color: iconColor,),
          ),

          SizedBox(height: 5,),
          text!=null?Container(
            width: 50,
            child: FittedBox(
              child: Text(
                text!,
                style: TextStyle(
                  fontSize:14,
                  color: textColor,
                ),
              ),
            ),
          ):Container()
        ],
      ),
    );
  }
}