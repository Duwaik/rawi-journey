import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsService.init();

  // Pre-cache critical fonts to prevent flash of fallback on splash
  await GoogleFonts.pendingFonts([
    GoogleFonts.cinzelDecorative(),
    GoogleFonts.lora(),
    GoogleFonts.nunito(),
  ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const RawiApp());
}

class RawiApp extends StatefulWidget {
  const RawiApp({super.key});

  @override
  State<RawiApp> createState() => _RawiAppState();
}

class _RawiAppState extends State<RawiApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Global: fade all audio when app goes to background (LOCKED RULE: no hard cuts)
      AudioService.fadeOut(duration: const Duration(milliseconds: 300));
      AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 200));
      AudioService.stopSfx();
    }
    // Resume is handled per-screen (event list restarts ambient_intro,
    // immersive_event_screen restarts scene ambient via its own observer)
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rawi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.teal,
          surface: AppColors.card,
          onPrimary: AppColors.bg,
          onSecondary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.bg,
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
        ),
      ),
      builder: (context, child) {
        // Absolute text scale — ignores device system scale.
        // Small=0.85, Normal=1.0, Large=1.2
        final scale = PrefsService.textScale;
        final data = MediaQuery.of(context);
        return Directionality(
          textDirection: PrefsService.isAr ? TextDirection.rtl : TextDirection.ltr,
          child: MediaQuery(
            data: data.copyWith(
              textScaler: TextScaler.linear(scale),
            ),
            child: child!,
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
