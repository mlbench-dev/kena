import Flutter
import UIKit

class NativeLiquidGlassAppleButtonFactory:
    NSObject,
    FlutterPlatformViewFactory {

    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func createArgsCodec()
        -> FlutterMessageCodec & NSObjectProtocol {

        return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {

        if #available(iOS 26.0, *) {

            return NativeLiquidGlassAppleButton(
                frame: frame,
                viewId: viewId,
                arguments: args,
                messenger: messenger
            )

        } else {

            return FallbackAppleButton(
                frame: frame,
                viewId: viewId,
                messenger: messenger
            )
        }
    }
}

/// Used on iOS versions below 26.0, where true Liquid Glass isn't available.
/// Approximates the glass look with a blurred, translucent material instead
/// of a solid fill — icon-only, no text.
class FallbackAppleButton: NSObject, FlutterPlatformView {

    private let containerView: UIView
    private let blurView: UIVisualEffectView
    private let button: UIButton
    private let channel: FlutterMethodChannel

    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger) {

        containerView = UIView(frame: frame)
        blurView = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemUltraThinMaterial)
        )
        button = UIButton(type: .system)
        channel = FlutterMethodChannel(
            name: "native_liquid_glass_apple_button_\(viewId)",
            binaryMessenger: messenger
        )

        super.init()

        blurView.frame = containerView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = frame.height / 2
        blurView.clipsToBounds = true
        blurView.layer.borderWidth = 0.5
        blurView.layer.borderColor =
            UIColor.white.withAlphaComponent(0.35).cgColor

        button.setImage(
            UIImage(systemName: "apple.logo"),
            for: .normal
        )
        button.tintColor = .label
        button.frame = containerView.bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        containerView.backgroundColor = .clear
        containerView.addSubview(blurView)
        containerView.addSubview(button)
    }

    @objc private func handleTap() {
        channel.invokeMethod("onTap", arguments: nil)
    }

    func view() -> UIView {
        return containerView
    }
}
