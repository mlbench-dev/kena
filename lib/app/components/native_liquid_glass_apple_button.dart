import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps the native iOS Liquid Glass "Sign in with Apple" button
/// (`UIButton.Configuration.glass()`) rendered via a [UiKitView].
///
/// Falls back to a plain filled UIButton on iOS < 26 (handled natively).
class NativeLiquidGlassAppleButton extends StatefulWidget {
  const NativeLiquidGlassAppleButton({
    super.key,
    this.width,
    this.height = 56,
    this.onPressed,
  });

  final double? width;
  final double height;
  final VoidCallback? onPressed;

  @override
  State<NativeLiquidGlassAppleButton> createState() =>
      _NativeLiquidGlassAppleButtonState();
}

class _NativeLiquidGlassAppleButtonState
    extends State<NativeLiquidGlassAppleButton> {
  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('native_liquid_glass_apple_button_$id');
    channel.setMethodCallHandler((call) async {
      if (call.method == 'onTap') {
        widget.onPressed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: UiKitView(
        viewType: 'native_liquid_glass_apple_button',
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }
}
