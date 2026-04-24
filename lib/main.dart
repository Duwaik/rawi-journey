import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/debug_log_service.dart';
import 'services/prefs_service.dart';
import 'services/route_observer.dart';
import 'widgets/debug_nav_observer.dart';
import 'widgets/debug_reporter_overlay.dart';

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

  /// Global rebuild trigger — call after language or text scale change.
  static void rebuild(BuildContext context) {
    context.findAncestorStateOfType<_RawiAppState>()?.rebuild();
  }

  @override
  State<RawiApp> createState() => _RawiAppState();
}

class _RawiAppState extends State<RawiApp> with WidgetsBindingObserver {
  void rebuild() => setState(() {});

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
    // R28 S1-BUG2: log every transition to `lifecycle` so Khaled can
    // read the exact sequence from the in-app debug overlay (B27) when
    // the A56 home-button bug is reproduced. Each line includes the
    // state so we can tell apart:
    //   - paused  = Flutter's "app backgrounded"
    //   - inactive = transitional (notifications, phone call incoming)
    //   - hidden  = Android 12+ "visible but not foreground"
    //   - resumed = back in front
    //   - detached = process ending
    DebugLogService.log('lifecycle', 'state=$state');
    // R28 S1-BUG2: `hidden` (Android 12+) can fire without `paused` on
    // some OEMs (Samsung One UI reported). Treat it like paused so the
    // resume key is captured either way — otherwise a hidden-without-
    // paused path would leave us with no key to resume from.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // R27 S3-AUDIO2: capture what's playing BEFORE the fade clears
      // `_currentAmbientPath`. On resume we play the same track back.
      // R28 S1-BUG2: captureResumeKey also persists to PrefsService so
      // an Activity recreate (Dart isolate reset) can still recover.
      AudioService.captureResumeKey();
      // Global: fade all audio when app goes to background (LOCKED RULE: no hard cuts)
      AudioService.fadeOut(duration: const Duration(milliseconds: 300));
      AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 200));
      AudioService.stopSfx();
    } else if (state == AppLifecycleState.resumed) {
      // R27 S3-AUDIO2: bring back whichever ambient was playing when
      // the app went to background. Uniform for tent cluster AND event
      // scenes. 300 ms fade-in reuses the S1.5 envelope.
      // R28 S1-BUG2: resumeLastAmbient now falls back to PrefsService
      // if the in-memory slot is null (recovery path).
      AudioService.resumeLastAmbient();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rawi',
      debugShowCheckedModeBanner: false,
      // R25-S1-6: every push/pop/replace funnels into DebugLogService.
      // R26 S1v2-T2: appRouteObserver lets screens subscribe to route
      // lifecycle events (e.g., tent refreshes when it becomes active
      // again after an event-scene pop).
      navigatorObservers: [DebugNavObserver(), appRouteObserver],
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
            // B27: debug overlay wraps every route so the reporter FAB is
            // visible on ALL screens during testing.
            child: DebugReporterOverlay(child: child!),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
