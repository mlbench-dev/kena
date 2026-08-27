import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openLegalUrl(BuildContext context, String url) async {
  final launched = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
  if (!launched && context.mounted) {
    context.flushBarErrorMessage(message: 'Could not open the link.');
  }
}
