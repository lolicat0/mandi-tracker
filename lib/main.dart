import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'models/user_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/farmer_dashboard/farmer_main_screen.dart';
import 'screens/operator_dashboard/operator_main_screen.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import removed
import 'l10n/app_localizations.dart';
import 'providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(MandiPriceTrackerApp(prefs: prefs));
}

class MandiPriceTrackerApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MandiPriceTrackerApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Mandi Price Tracker',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: settings.locale,
            themeMode: settings.themeMode,
            theme: AppTheme.lightTheme.copyWith(
              textTheme: AppTheme.textTheme(context),
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              textTheme: AppTheme.textTheme(
                context,
              ).apply(bodyColor: Colors.white, displayColor: Colors.white),
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        final user = auth.currentUser!;
        if (user.role == UserRole.farmer) {
          return const FarmerMainScreen();
        } else {
          return const OperatorMainScreen();
        }
      },
    );
  }
}
