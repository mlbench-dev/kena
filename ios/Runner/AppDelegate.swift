import Flutter
import UIKit
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController

    let liquidGlassAppleButtonFactory = NativeLiquidGlassAppleButtonFactory(
      messenger: controller.binaryMessenger
    )

    registrar(forPlugin: "NativeLiquidGlassAppleButton")?.register(
      liquidGlassAppleButtonFactory,
      withId: "native_liquid_glass_apple_button"
    )

    GeneratedPluginRegistrant.register(with: self)

    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}


// import UIKit
// import Flutter
// import GoogleMaps 

// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {

//     GMSServices.provideAPIKey("AIzaSyDCnnrXknaOvWIF-eHHAIia-ThQzWfWTrU") 

//     GeneratedPluginRegistrant.register(with: self)  // Important!

//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }
