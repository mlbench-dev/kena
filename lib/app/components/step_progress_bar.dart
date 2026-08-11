import 'package:flutter/material.dart';

class StepProgressBar extends StatefulWidget {

  const StepProgressBar({
    required this.totalSteps, required this.currentStep, super.key,
    this.activeColor = const Color(0xFFF4E9DC),
    this.inactiveColor = const Color(0x66F4E9DC),
    this.checkColor = const Color(0xFFF4E9DC),
  });
  final int totalSteps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final Color checkColor;

  @override
  State<StepProgressBar> createState() => _StepProgressBarState();
}

class _StepProgressBarState extends State<StepProgressBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(widget.totalSteps * 2 - 1, (index) {
        if (index.isEven) {
          final int stepIndex = index ~/ 2;
          final bool isCompleted = stepIndex < widget.currentStep;
          final bool isActive = stepIndex == widget.currentStep;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted || isActive
                    ? widget.activeColor
                    : widget.inactiveColor,
                width: 2,
              ),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isCompleted || isActive
                      ? widget.activeColor
                      : widget.inactiveColor,
                  shape: BoxShape.circle,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isCompleted
                      ? Icon(Icons.check,
                          key: ValueKey(stepIndex),
                          size: 14,
                          color: widget.checkColor)
                      : null,
                ),
              ),
            ),
          );
        } else {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              color: (index ~/ 2) < widget.currentStep
                  ? widget.activeColor
                  : widget.inactiveColor,
            ),
          );
        }
      }),
    );
  }
}
