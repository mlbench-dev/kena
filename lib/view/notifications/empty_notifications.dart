import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';

class EmptyNotificationsScreen extends StatelessWidget {
  const EmptyNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.notifications.svg(
            width: 64,
            height: 64,
            // colorFilter: ColorFilter.mode(
            //   context.colors.textSecondary,
            //   BlendMode.srcIn,
            // ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications Yet',
            style: context.typography.title.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up!\nWe'll notify you when something arrives.",
            textAlign: TextAlign.center,
            style: context.typography.body.copyWith(
              fontSize: 14,
              color: context.colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
