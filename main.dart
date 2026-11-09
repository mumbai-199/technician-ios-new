import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/app_language.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppLanguage.instance.load();
  } catch (error, stackTrace) {
    debugPrint('Unable to load saved language: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  var firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PestControlApp());

  if (firebaseInitialized && !kIsWeb) {
    unawaited(_initializeNotifications());
  }
}

Future<void> _initializeNotifications() async {
  try {
    await NotificationService.initialize();
  } catch (error, stackTrace) {
    debugPrint('Push notification initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class PestControlApp extends StatelessWidget {
  const PestControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLanguage.instance,
      builder: (context, child) => MaterialApp(
        title: 'Pest Control Technician',
        debugShowCheckedModeBanner: false,
        locale: AppLanguage.instance.locale,
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('mr'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          primarySwatch: Colors.grey,
          scaffoldBackgroundColor: const Color(0xFFE0E5EC),
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFFE0E5EC),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            titleTextStyle: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Optimize material rendering
          useMaterial3: false,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // Performance optimizations
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
              ),
            ),
            child: child!,
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
