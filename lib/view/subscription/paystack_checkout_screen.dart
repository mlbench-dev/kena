import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Hosts the Paystack-hosted checkout page inside a WebView.
///
/// The mobile app already has the transaction `reference` from the
/// `/mobile/subscribe` (or `/change`) response before the checkout even
/// starts, so this screen only needs to detect *when* checkout finished —
/// it doesn't need to parse the reference back out of the redirect URL.
/// Completion is detected once the WebView navigates to the configured
/// Paystack callback URL (or a URL carrying Paystack's `trxref`/`reference`
/// query params), at which point it pops with `true`.
class PaystackCheckoutScreen extends StatefulWidget {
  const PaystackCheckoutScreen({
    super.key,
    required this.authorizationUrl,
    this.callbackUrl,
  });

  final String authorizationUrl;
  final String? callbackUrl;

  @override
  State<PaystackCheckoutScreen> createState() =>
      _PaystackCheckoutScreenState();
}

class _PaystackCheckoutScreenState extends State<PaystackCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _maybeFinishCheckout(url),
          onNavigationRequest: (request) {
            _maybeFinishCheckout(request.url);
            return _finished
                ? NavigationDecision.prevent
                : NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  bool _looksLikeCompletion(String url) {
    final callback = widget.callbackUrl;
    if (callback != null &&
        callback.isNotEmpty &&
        url.startsWith(callback)) {
      return true;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.queryParameters.containsKey('trxref') ||
        uri.queryParameters.containsKey('reference');
  }

  void _maybeFinishCheckout(String url) {
    if (_finished) return;
    if (_looksLikeCompletion(url)) {
      _finished = true;
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complete Payment',
          style: context.typography.title.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (_finished) return;
            _finished = true;
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
