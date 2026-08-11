import 'package:kena_emotional_journey/l10n/l10n.dart';
import 'package:flutter/material.dart';

class InterNetExceptionWidget extends StatefulWidget {
  const InterNetExceptionWidget({required this.onPress, super.key});
  final VoidCallback onPress;

  @override
  State<InterNetExceptionWidget> createState() =>
      _InterNetExceptionWidgetState();
}

class _InterNetExceptionWidgetState extends State<InterNetExceptionWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * .15),
          const Icon(Icons.cloud_off, color: Colors.red, size: 50),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Center(
              child: Text(
                context.l10n.exception_check_internet_connection,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.displayMedium!.copyWith(fontSize: 20),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * .15),
          ElevatedButton(
            onPressed: widget.onPress,
            child: Center(
              child: Text(
                context.l10n.exception_retry,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
