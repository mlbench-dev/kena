/*
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/view/pro_tip/pro_tip_manager.dart';
import 'package:kena_emotional_journey/view/pro_tip/widget/pro_tips_dialog_box.dart';

/// Debug / test screen for manually triggering pro tip dialogs.
///
/// Set `initialRoute` to `RoutesName.tipScreen` to use this screen
/// during development. Use the FAB buttons to test each tip variant.
class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  void _showTipDialog({
    required String title,
    required String description,
    required String buttonLabel,
    required Widget icon,
  }) {
    MyDialogBox.show(
      context,
      child: ProTipsDialogBox(
        title: title,
        description: description,
        icon: icon,
        buttonLabel: buttonLabel,
        onButtonPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pro Tips Debug Screen',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _showTipDialog(
                  title: '3 days in a row!',
                  description:
                      "That's the foundation of real growth. Keep going!",
                  buttonLabel: 'Keep going',
                  icon: Assets.images.threeDay.image(),
                ),
                child: const Text('Show 3-Day Tip'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _showTipDialog(
                  title: '7 days in a row!',
                  description:
                      "Congratulations! You've reflected 7 days in a row. See your insights.",
                  buttonLabel: 'See analytics',
                  icon: Assets.images.week.image(),
                ),
                child: const Text('Show 7-Day Tip'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _showTipDialog(
                  title: 'Two weeks!',
                  description:
                      "Two weeks of showing up for yourself that's something to be really proud of.",
                  buttonLabel: 'Explore insights',
                  icon: Assets.images.twoWeeks.image(),
                ),
                child: const Text('Show 14-Day Tip'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _showTipDialog(
                  title: 'Pro tip',
                  description:
                      'Logging consistently unlocks deeper insights into your emotional patterns.',
                  buttonLabel: 'Got it',
                  icon: Assets.images.bulb.image(),
                ),
                child: const Text('Show Pro Tip'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Debug Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await ProTipManager.debugSetFirstLoginDaysAgo(3);
                  await ProTipManager.debugResetShownTips();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Set to 3 days ago & reset shown tips'),
                      ),
                    );
                  }
                },
                child: const Text('Simulate 3 Days Ago'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await ProTipManager.debugSetFirstLoginDaysAgo(7);
                  await ProTipManager.debugResetShownTips();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Set to 7 days ago & reset shown tips'),
                      ),
                    );
                  }
                },
                child: const Text('Simulate 7 Days Ago'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
