import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n_app_localizations.dart';
import 'main_navigation_screen.dart';
import 'providers/activity_provider.dart';
import 'providers/app_connections_provider.dart';
import 'providers/challenge_provider.dart';
import 'providers/reward_provider.dart';
import 'providers/session_provider.dart';
import 'screens/activities/activity_history_screen.dart';
import 'screens/activities/manual_report_screen.dart';
import 'screens/activities/sync_apps_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/security_pin_screen.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/rewards/redeem_screen.dart';
import 'services/api/activity_api_service.dart';
import 'services/api/api_client.dart';
import 'services/api/auth_api_service.dart';
import 'services/api/challenge_api_service.dart';
import 'services/api/integration_api_service.dart';
import 'services/api/reward_api_service.dart';
import 'services/oauth/oauth_flow_service.dart';

void main() {
  final apiClient = ApiClient();
  const oauthFlowService = OAuthFlowService();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder:
          (context) => MultiProvider(
            providers: [
              Provider<ApiClient>.value(value: apiClient),
              Provider<OAuthFlowService>.value(value: oauthFlowService),
              ProxyProvider<ApiClient, AuthApiService>(
                update: (_, client, __) => AuthApiService(client),
              ),
              ProxyProvider<ApiClient, ActivityApiService>(
                update: (_, client, __) => ActivityApiService(client),
              ),
              ProxyProvider<ApiClient, ChallengeApiService>(
                update: (_, client, __) => ChallengeApiService(client),
              ),
              ProxyProvider<ApiClient, RewardApiService>(
                update: (_, client, __) => RewardApiService(client),
              ),
              ProxyProvider<ApiClient, IntegrationApiService>(
                update: (_, client, __) => IntegrationApiService(client),
              ),
              ChangeNotifierProvider(
                create:
                    (context) => SessionProvider(
                      authService: context.read<AuthApiService>(),
                      integrationService: context.read<IntegrationApiService>(),
                      apiClient: context.read<ApiClient>(),
                      oauthFlowService: context.read<OAuthFlowService>(),
                    ),
              ),
              ChangeNotifierProxyProvider2<
                ActivityApiService,
                SessionProvider,
                ActivityProvider
              >(
                create:
                    (context) => ActivityProvider(
                      apiService: context.read<ActivityApiService>(),
                    ),
                update: (_, apiService, sessionProvider, previous) {
                  final provider =
                      previous ?? ActivityProvider(apiService: apiService);
                  provider.bindSession(sessionProvider);
                  return provider;
                },
              ),
              ChangeNotifierProxyProvider2<
                ChallengeApiService,
                SessionProvider,
                ChallengeProvider
              >(
                create:
                    (context) => ChallengeProvider(
                      apiService: context.read<ChallengeApiService>(),
                    ),
                update: (_, apiService, sessionProvider, previous) {
                  final provider =
                      previous ?? ChallengeProvider(apiService: apiService);
                  provider.bindSession(sessionProvider);
                  return provider;
                },
              ),
              ChangeNotifierProxyProvider4<
                RewardApiService,
                SessionProvider,
                ActivityProvider,
                ChallengeProvider,
                RewardProvider
              >(
                create:
                    (context) => RewardProvider(
                      apiService: context.read<RewardApiService>(),
                    ),
                update: (
                  _,
                  apiService,
                  sessionProvider,
                  activityProvider,
                  challengeProvider,
                  previous,
                ) {
                  final provider =
                      previous ?? RewardProvider(apiService: apiService);
                  provider.bindSession(sessionProvider);
                  provider.syncEarnedPoints(
                    totalApprovedPoints: activityProvider.totalPoints,
                    challengeBonusPoints: challengeProvider.totalBonusPoints,
                  );
                  return provider;
                },
              ),
              ChangeNotifierProxyProvider2<
                IntegrationApiService,
                SessionProvider,
                AppConnectionsProvider
              >(
                create:
                    (context) => AppConnectionsProvider(
                      apiService: context.read<IntegrationApiService>(),
                      oauthFlowService: context.read<OAuthFlowService>(),
                    ),
                update: (context, apiService, sessionProvider, previous) {
                  final provider =
                      previous ??
                      AppConnectionsProvider(
                        apiService: apiService,
                        oauthFlowService: context.read<OAuthFlowService>(),
                      );
                  provider.bindSession(sessionProvider);
                  return provider;
                },
              ),
            ],
            child: const MyApp(),
          ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.select<SessionProvider, Locale>(
      (session) => session.locale,
    );
    final isDarkMode = context.select<SessionProvider, bool>(
      (session) => session.isDarkMode,
    );

    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        return DevicePreview.appBuilder(context, child);
      },
      debugShowCheckedModeBanner: false,
      title: 'Think Green',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFE0E0E0),
        fontFamily: 'Outfit',
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/security_pin': (context) => const SecurityPinScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/home': (context) => const MainNavigationScreen(),
        '/redeem': (context) => const RedeemScreen(),
        '/history': (context) => const ActivityHistoryScreen(),
        '/manual_report': (context) => const ManualReportScreen(),
        '/sync_apps': (context) => const SyncAppsScreen(),
      },
    );
  }
}
