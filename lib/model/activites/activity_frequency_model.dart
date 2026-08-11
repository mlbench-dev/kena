import 'package:intl/intl.dart';

enum FrequencyOption { dateOfMonth, dayOfWeek }

class ActivityFrequency {
  final String name;
  final bool isCustom;
  String frequencyType; // 'daily', 'weekly', 'monthly'
  List<int> selectedDays; // for weekly (1-7)
  FrequencyOption monthOption; // dateOfMonth or dayOfWeek for monthly
  DateTime currentViewMonth; // selected month view for monthly calendar
  List<int> monthlyDays; // selected dates of month (1-31)
  String? monthlyWeekOccurrence; // 'First', 'Second', etc.
  int monthlyWeekDay; // selected weekday for relative monthly rules

  ActivityFrequency({
    required this.name,
    required this.isCustom,
    this.frequencyType = 'weekly',
    List<int>? selectedDays,
    this.monthOption = FrequencyOption.dateOfMonth,
    DateTime? currentViewMonth,
    this.monthlyWeekOccurrence = 'First',
    List<int>? monthlyDays,
    int? monthlyWeekDay,
  }) : selectedDays = selectedDays ?? [2],
       currentViewMonth =
           currentViewMonth ??
           DateTime(DateTime.now().year, DateTime.now().month, 1),
       monthlyDays = monthlyDays ?? [DateTime.now().day],
       monthlyWeekDay = monthlyWeekDay ?? DateTime.now().weekday;

  Map<String, dynamic> toRequestJson({DateTime? day}) {
    final isWeekly = frequencyType == 'weekly';
    final isMonthlyByDate =
        frequencyType == 'monthly' &&
        monthOption == FrequencyOption.dateOfMonth;
    final isMonthlyByWeekday =
        frequencyType == 'monthly' && monthOption == FrequencyOption.dayOfWeek;

    final weekly = isWeekly ? ([...selectedDays]..sort()) : <int>[];
    final monthly = isMonthlyByDate ? ([...monthlyDays]..sort()) : <int>[];

    return {
      'name': name,
      'isCustom': isCustom,
      'frequency': frequencyType,
      'weeklyDays': weekly,
      'monthlyDays': monthly,
      'monthlyWeekNumber': isMonthlyByWeekday
          ? _weekOccurrenceNumber(monthlyWeekOccurrence)
          : null,
      'monthlyWeekDay': isMonthlyByWeekday ? monthlyWeekDay : null,
      'day': DateFormat('yyyy-MM-dd').format(day ?? DateTime.now()),
    };
  }

  static int _weekOccurrenceNumber(String? occurrence) {
    const occurrences = {'First': 1, 'Second': 2, 'Third': 3, 'Fourth': 4};
    return occurrences[occurrence] ?? 1;
  }
}
