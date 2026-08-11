import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

// ============================================================
// Input formatter — enforces valid 12-hour time as the user types.
// Allowed: 1–12 for hour, 00–59 for minute, single colon, digits only.
// ============================================================
class _TimeInputFormatter extends TextInputFormatter {
  static final _validCharsPattern = RegExp(r'^[0-9:]*$');
  static const _maxHourDigits = 2;
  static const _maxMinuteDigits = 2;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    if (!_hasOnlyDigitsAndOneColon(text)) return oldValue;
    if (!_hasValidHour(text) || !_hasValidMinute(text)) return oldValue;

    return newValue;
  }

  bool _hasOnlyDigitsAndOneColon(String text) {
    if (!_validCharsPattern.hasMatch(text)) return false;
    return ':'.allMatches(text).length <= 1;
  }

  bool _hasValidHour(String text) {
    final hourPart = text.split(':').first;
    if (hourPart.length > _maxHourDigits) return false;
    if (hourPart.isEmpty) return true;

    final hour = int.parse(hourPart);
    return hour >= 1 && hour <= 12;
  }

  bool _hasValidMinute(String text) {
    final parts = text.split(':');
    if (parts.length < 2) return true; // no colon typed yet

    final minutePart = parts[1];
    if (minutePart.length > _maxMinuteDigits) return false;
    if (minutePart.isEmpty) return true;

    final minute = int.parse(minutePart);
    return minute <= 59;
  }
}

// ============================================================
// TimePickerInputField
// A text field for entering a 12-hour time (e.g. "8:00") with an
// inline AM/PM selector. Input is restricted to valid times as the
// user types; `onTimeChanged` only fires once a complete, valid
// time has been entered.
// ============================================================
class TimePickerInputField extends StatefulWidget {
  /// Called with the full time string once it's complete and valid,
  /// e.g. "8:00 AM".
  final ValueChanged<String>? onTimeChanged;

  /// Initial time value, e.g. "8:00".
  final String? initialTime;

  /// Initial period, "AM" or "PM".
  final String initialPeriod;

  const TimePickerInputField({
    super.key,
    this.onTimeChanged,
    this.initialTime,
    this.initialPeriod = 'AM',
  });

  @override
  State<TimePickerInputField> createState() => _TimePickerInputFieldState();
}

class _TimePickerInputFieldState extends State<TimePickerInputField> {
  static const _borderRadius = 12.0;
  static final _completeTimePattern = RegExp(r'^([1-9]|1[0-2]):[0-5][0-9]$');

  final _timeController = TextEditingController();
  late String _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPeriod;
    _timeController.text = widget.initialTime ?? '';
    _timeController.addListener(_handleTimeTextChanged);
  }

  @override
  void didUpdateWidget(covariant TimePickerInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncWithNewInitialValues(oldWidget);
  }

  @override
  void dispose() {
    _timeController.removeListener(_handleTimeTextChanged);
    _timeController.dispose();
    super.dispose();
  }

  // ---------------- state & callbacks ----------------

  /// Keeps the field in sync if the parent supplies new initial
  /// values after first build (e.g. async data arriving late).
  void _syncWithNewInitialValues(TimePickerInputField oldWidget) {
    final newInitialTime = widget.initialTime;
    if (newInitialTime != null &&
        newInitialTime != oldWidget.initialTime &&
        newInitialTime != _timeController.text) {
      _timeController.text = newInitialTime;
    }

    if (widget.initialPeriod != oldWidget.initialPeriod &&
        widget.initialPeriod != _selectedPeriod) {
      setState(() => _selectedPeriod = widget.initialPeriod);
    }
  }

  void _handleTimeTextChanged() {
    final text = _timeController.text.trim();
    if (_completeTimePattern.hasMatch(text)) {
      widget.onTimeChanged?.call('$text $_selectedPeriod');
    }
  }

  void _selectPeriod(String period) {
    if (period == _selectedPeriod) return;
    setState(() => _selectedPeriod = period);
    _handleTimeTextChanged();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _timeController,
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        _TimeInputFormatter(),
        LengthLimitingTextInputFormatter(
          5,
        ), // "12:59" is the longest valid value
      ],
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: _buildInputDecoration(context),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context) {
    return InputDecoration(
      hintText: '8:00',
      hintStyle: context.typography.body.copyWith(
        color: context.colors.textSecondary.withValues(alpha: 0.6),
        fontSize: 14.sp,
      ),
      filled: true,
      fillColor: context.colors.background,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: _buildBorder(context.colors.textSecondary.withValues(alpha: 0.3)),
      enabledBorder: _buildBorder(
        context.colors.textSecondary.withValues(alpha: 0.3),
      ),
      focusedBorder: _buildBorder(
        context.colors.primary.withValues(alpha: 0.3),
      ),
      suffixIcon: _buildPeriodSelector(context),
    );
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: BorderSide(color: color, width: 1),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PeriodOption(
            label: 'AM',
            isSelected: _selectedPeriod == 'AM',
            onTap: () => _selectPeriod('AM'),
          ),
          SizedBox(width: 8.w),
          _PeriodOption(
            label: 'PM',
            isSelected: _selectedPeriod == 'PM',
            onTap: () => _selectPeriod('PM'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// A single AM/PM tap target, shown inside the field's suffix.
// Pulled out as its own widget so styling/behavior for one option
// can be changed without touching the parent field's build method.
// ============================================================
class _PeriodOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: isSelected ? context.colors.primary : Colors.grey,
          fontFamily: 'sfpro',
        ),
      ),
    );
  }
}
