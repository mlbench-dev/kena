# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Services & Google Sign-In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.api.client.** { *; }
-dontwarn com.google.api.client.**
-keep class com.google.common.** { *; }
-dontwarn com.google.common.**
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Sign-In specific
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.common.api.GoogleApiClient { *; }
-keep class com.google.android.gms.common.api.internal.** { *; }

# Play Core (deferred components - not used but referenced by Flutter)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
