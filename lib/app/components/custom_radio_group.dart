import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class CustomRadioGroup<T> extends StatelessWidget {
  const CustomRadioGroup({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.labelBuilder,
    this.direction = Axis.horizontal,
    super.key,
  });

  final List<T> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final String Function(T) labelBuilder;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      children: options.map((option) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<T>(
              value: option,
              groupValue: selectedValue,
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
              activeColor: context.colors.onSurface,
            ),
            Text(
              labelBuilder(option),
              style: context.typography.subtitle.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.60),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
