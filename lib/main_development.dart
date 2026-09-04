import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/view/app.dart';
import 'package:kena_emotional_journey/bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(() => App());
}
