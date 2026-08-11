import Flutter
import UIKit

@available(iOS 26.0, *)
class NativeLiquidGlassAppleButton: NSObject, FlutterPlatformView {

    private let containerView: UIView
    private let button: UIButton
    private let channel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        containerView = UIView(frame: frame)
        button = UIButton(type: .system)
        channel = FlutterMethodChannel(
            name: "native_liquid_glass_apple_button_\(viewId)",
            binaryMessenger: messenger
        )

        super.init()

        setupButton()
    }

    private func setupButton() {

        // Create the native Liquid Glass button (icon-only, circular —
        // matches the size/shape of the Google sign-in button next to it)
        var configuration = UIButton.Configuration.glass()

        configuration.baseForegroundColor = .label

        configuration.image = UIImage(
            systemName: "apple.logo"
        )

        configuration.cornerStyle = .capsule

        button.configuration = configuration

        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        containerView.addSubview(button)

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),

            button.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),

            button.topAnchor.constraint(
                equalTo: containerView.topAnchor
            ),

            button.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            )
        ])
    }

    @objc private func handleTap() {
        channel.invokeMethod("onTap", arguments: nil)
    }

    func view() -> UIView {
        return containerView
    }
}
