import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/styles/app_radiuses.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';

class DateTimeField extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  const DateTimeField({super.key, required this.onDateSelected});

  @override
  State<DateTimeField> createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<DateTimeField> {
  final TextEditingController _controller = TextEditingController();

  DateTime? selectedDateTime;

  Future<void> _pickDateTime() async {
    // 1. Pick Date
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    // 2. Pick Time
    // TimeOfDay? time = await showTimePicker(
    //   context: context,
    //   initialTime: TimeOfDay.now(),
    // );

    // if (time == null) return;

    // 3. Combine
    final DateTime finalDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      // time.hour,
      // time.minute,
    );

    setState(() {
      selectedDateTime = finalDateTime;

      // 4. Show in TextField
      _controller.text = DateFormat('yyyy-MM-dd').format(finalDateTime);
    });
    widget.onDateSelected?.call(finalDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true, // important
      style: TextStyle(color: context.colors.textPrimary),
      decoration: InputDecoration(
        hintText: "Select Date & Time",
        hintStyle: TextStyle(color: context.colors.textPrimary),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Assets.icons.calendar.svg(height: 20, width: 20),
        ),
        fillColor: context.colors.background,
        filled: true, // important if using fillColor
        contentPadding: EdgeInsets.symmetric(
          vertical: 16, // 👈 increase this
          horizontal: 12,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadiuses.smallRadius),
          borderSide: BorderSide(color: Color(0xFFe7e7e7)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadiuses.smallRadius),
          borderSide: BorderSide(color: context.colors.primary),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadiuses.smallRadius),
        ),
      ),
      onTap: _pickDateTime, // 👈 main logic
    );
  }
}
