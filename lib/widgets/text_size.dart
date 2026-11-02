import 'package:flutter/material.dart';

class SizedText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final double underlineHeight;
  final double underlineSpacing;

  const SizedText({
    Key? key,
    required this.text,
    required this.color,
    this.fontSize = 16,
    this.underlineHeight = 2,
    this.underlineSpacing = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: underlineSpacing),
        _buildUnderline(context),
      ],
    );
  }

  Widget _buildUnderline(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    final segmentCount = (textPainter.width / 10).ceil();

    return SizedBox(
      width: textPainter.width,
      height: underlineHeight,
      child: Row(
        children: List.generate(segmentCount, (index) {
          return Expanded(
            child: Container(
              height: underlineHeight,
              color: index.isEven ? color : Colors.white,
            ),
          );
        }),
      ),
    );
  }
}
