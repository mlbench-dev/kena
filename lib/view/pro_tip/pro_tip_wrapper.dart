import 'package:flutter/material.dart';

import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/view/pro_tip/pro_tip_manager.dart';
import 'package:kena_emotional_journey/view/pro_tip/widget/pro_tips_dialog_box.dart';

/// A transparent wrapper widget that checks for due pro tips on mount
/// and whenever the app resumes from background.
///
/// Wrap your home screen (or any root screen) with this widget:
/// ```dart
/// ProTipWrapper(child: HomeScreen())
/// ```
class ProTipWrapper extends StatefulWidget {
  final Widget child;

  const ProTipWrapper({super.key, required this.child});

  @override
  State<ProTipWrapper> createState() => _ProTipWrapperState();
}

class _ProTipWrapperState extends State<ProTipWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check for a due tip after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkProTip());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkProTip();
    }
  }

  Future<void> _checkProTip() async {
    final tip = await ProTipManager.getNextDueTip();
    if (tip != null && mounted) {
      // Mark as shown immediately so it won't fire again on resume.
      await ProTipManager.markTipAsShown(tip.id);

      if (!mounted) return;
      MyDialogBox.show(
        context,
        child: ProTipsDialogBox(
          title: tip.title,
          description: tip.description,
          buttonLabel: tip.buttonLabel,
          icon: tip.iconBuilder(),
          onButtonPressed: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
