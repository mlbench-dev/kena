import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';

class EmptyNotificationsScreen extends StatelessWidget {
  const EmptyNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: NetworkImage(
                'https://cdn-icons-png.flaticon.com/512/2645/2645890.png',
              ),
              width: 120,
              height: 120,
            ),
            SizedBox(height: 24),
            Text(
              'No Notifications Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "You're all caught up!\nWe'll notify you when something arrives.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black38,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
