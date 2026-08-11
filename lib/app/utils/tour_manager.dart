import 'package:shared_preferences/shared_preferences.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';

class OnboardingTourService {
  static const _prefix = 'tour_shown_';

  String _getKey(String sectionKey) {
    final userId = SessionController().user?.id ?? 'guest';
    return '$_prefix${userId}_$sectionKey';
  }

  Future<bool> isTourShown(String sectionKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getKey(sectionKey)) ?? false;
  }

  Future<void> markTourShown(String sectionKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getKey(sectionKey), true);
  }

  Future<void> resetTour(String sectionKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getKey(sectionKey));
  }
}
