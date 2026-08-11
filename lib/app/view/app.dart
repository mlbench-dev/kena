import 'package:kena_emotional_journey/app/routes/routes.dart';
import 'package:kena_emotional_journey/app/styles/app_dimensions.dart';
import 'package:kena_emotional_journey/app/styles/theme_factory.dart';
import 'package:kena_emotional_journey/l10n/app_localizations.dart';
import 'package:kena_emotional_journey/provider/auth/locale_provider.dart';
import 'package:kena_emotional_journey/provider/connectivity_provider.dart';
import 'package:kena_emotional_journey/services/common/connectivity service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/common/no_connection.dart';
import 'package:kena_emotional_journey/view/home/widgets/app_usage_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final AppUsageController _appUsageController;
  late final UserHomeService _userHomeService;

  @override
  void initState() {
    super.initState();
    _userHomeService = UserHomeService();
    _appUsageController = AppUsageController(_userHomeService);
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _appUsageController.onUserInteraction();
      _appUsageController.start();

      final connectivityProvider = context.read<ConnectivityProvider>();

      final initial = await ConnectivityService.instance.checkConnection();
      connectivityProvider.updateConnection(initial);

      ConnectivityService.instance.startListening(
        onStatusChanged: (isConnected) {
          connectivityProvider.updateConnection(isConnected);
        },
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Temporary diagnostic: logs every transition so we can tell a real
    // pause/resume cycle apart from iOS killing the process outright (which
    // would show the 🚀 COLD START log from bootstrap.dart with no
    // preceding "paused" instead).
    debugPrint('🔄 AppLifecycleState -> $state at ${DateTime.now()}');
    if (state == AppLifecycleState.resumed) {
      _appUsageController.onAppResumed();
    } else if (state == AppLifecycleState.paused) {
      _appUsageController.onAppPaused();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appUsageController.dispose();
    ConnectivityService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _appUsageController.onUserInteraction(),
      onPointerMove: (_) => _appUsageController.onUserInteraction(),
      child: ScreenUtilInit(
        designSize: AppDimensions.mockSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final locale = context.watch<LocaleNotifier>().locale;
          return MaterialApp(
            navigatorKey: App.navigatorKey,
            title: 'kena',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            theme: ThemeFactory.darkThemeData(),
            darkTheme: ThemeFactory.darkThemeData(),
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: Routes.initialRoute(),
            onGenerateRoute: Routes.generateRoute,
            builder: (context, appChild) {
              return Consumer<ConnectivityProvider>(
                builder: (context, connectivityProvider, _) {
                  return Stack(
                    children: [
                      appChild ?? const SizedBox.shrink(),
                      if (!connectivityProvider.isConnected)
                        const Positioned.fill(child: NoConnectionScreen()),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
