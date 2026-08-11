import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'PLACES_API_KEY')
  static final String placesApiKey = _Env.placesApiKey;

  // @EnviedField(varName: 'STRIPE_PUBLISHABLE_KEY')
  // static final String stripePublishableKey = _Env.stripePublishableKey;

  // @EnviedField(varName: 'IOS_GOOGLE_MAPS_API_KEY')
  // static final String iosGoogleMapApiKey = _Env.iosGoogleMapApiKey;

  // @EnviedField(varName: 'ANDROID_GOOGLE_MAPS_API_KEY')
  // static final String androidGoogleMapApiKey = _Env.androidGoogleMapApiKey;
}
