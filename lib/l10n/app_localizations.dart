import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @kena.
  ///
  /// In en, this message translates to:
  /// **'kena'**
  String get kena;

  /// No description provided for @unknown_oops.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get unknown_oops;

  /// No description provided for @unknown_page_not_found.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get unknown_page_not_found;

  /// No description provided for @unknown_page_does_not_exist.
  ///
  /// In en, this message translates to:
  /// **'The page you\'re looking for doesn\'t seem to exist.'**
  String get unknown_page_does_not_exist;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgot_password;

  /// No description provided for @auth_forgot_password_instruction.
  ///
  /// In en, this message translates to:
  /// **'Nothing to worry. Just enter your email address so we can send you a verification code to continue.'**
  String get auth_forgot_password_instruction;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_resend_otp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get auth_resend_otp;

  /// No description provided for @auth_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get auth_submit;

  /// No description provided for @auth_new_password_instruction.
  ///
  /// In en, this message translates to:
  /// **'Enter new password to secure your account.'**
  String get auth_new_password_instruction;

  /// No description provided for @auth_new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get auth_new_password;

  /// No description provided for @auth_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_confirm_password;

  /// No description provided for @auth_apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get auth_apple;

  /// No description provided for @auth_google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get auth_google;

  /// No description provided for @signup_welcome_to_kena.
  ///
  /// In en, this message translates to:
  /// **'Welcome to kena'**
  String get signup_welcome_to_kena;

  /// No description provided for @signup_welcome_message.
  ///
  /// In en, this message translates to:
  /// **'We are happy to see here. Please fill all the following fields to create a new account.'**
  String get signup_welcome_message;

  /// No description provided for @signup_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get signup_name;

  /// No description provided for @signup_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signup_password;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @signup_with.
  ///
  /// In en, this message translates to:
  /// **'Sign Up With'**
  String get signup_with;

  /// No description provided for @signup_already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have account?'**
  String get signup_already_have_account;

  /// No description provided for @signup_signin.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signup_signin;

  /// No description provided for @signup_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get signup_phone_number;

  /// No description provided for @signup_vendor_type.
  ///
  /// In en, this message translates to:
  /// **'Vendor Type'**
  String get signup_vendor_type;

  /// No description provided for @signup_vendor_type_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Food Vendor'**
  String get signup_vendor_type_hint;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @login_with.
  ///
  /// In en, this message translates to:
  /// **'Log In With'**
  String get login_with;

  /// No description provided for @login_dont_have_an_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have account?'**
  String get login_dont_have_an_account;

  /// No description provided for @profile_type.
  ///
  /// In en, this message translates to:
  /// **'Profile Type'**
  String get profile_type;

  /// No description provided for @profile_type_select_instruction.
  ///
  /// In en, this message translates to:
  /// **'Select your profile type according to your need.'**
  String get profile_type_select_instruction;

  /// No description provided for @profile_type_i_am.
  ///
  /// In en, this message translates to:
  /// **'I am'**
  String get profile_type_i_am;

  /// No description provided for @profile_vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get profile_vendor;

  /// No description provided for @profile_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get profile_user;

  /// No description provided for @welcome_discover_track_savour.
  ///
  /// In en, this message translates to:
  /// **'Discover Track, Savour, '**
  String get welcome_discover_track_savour;

  /// No description provided for @welcome_your_guide_to_local_flavours.
  ///
  /// In en, this message translates to:
  /// **'Your Guide to Local Flavours!'**
  String get welcome_your_guide_to_local_flavours;

  /// No description provided for @welcome_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get welcome_get_started;

  /// No description provided for @auth_change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get auth_change_password;

  /// No description provided for @dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialog_cancel;

  /// No description provided for @dialog_yes_delete.
  ///
  /// In en, this message translates to:
  /// **'Yes Delete'**
  String get dialog_yes_delete;

  /// No description provided for @exception_check_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'We\'re unable to show results.\nPlease check your data\nconnection.'**
  String get exception_check_internet_connection;

  /// No description provided for @exception_retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get exception_retry;

  /// No description provided for @test_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get test_done;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
