import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class ColoredRichText extends StatelessWidget {
  const ColoredRichText({
    required this.first,
    required this.second,
    super.key,
    this.firstColor,
    this.secondColor,
    this.firstFontSize = 24,
    this.secondFontSize = 24,
    this.firstFontWeight = FontWeight.w700,
    this.secondFontWeight = FontWeight.w700,
    this.textAlign = TextAlign.center,
  });
  final String first;
  final String second;
  final Color? firstColor;
  final Color? secondColor;
  final double firstFontSize;
  final double secondFontSize;
  final FontWeight firstFontWeight;
  final FontWeight secondFontWeight;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        children: [
          TextSpan(
            text: first,
            style: context.typography.title.copyWith(
              color: firstColor ?? context.colors.primary,
              fontSize: firstFontSize,
              fontWeight: firstFontWeight,
              letterSpacing: -.2,
            ),
          ),
          TextSpan(
            text: second,
            style: context.typography.title.copyWith(
              color: secondColor ?? context.colors.buttonPrimary,
              fontSize: secondFontSize,
              fontWeight: secondFontWeight,
              letterSpacing: -.2,
            ),
          ),
        ],
      ),
    );
  }
}
