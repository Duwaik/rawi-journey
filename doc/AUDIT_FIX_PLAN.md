# RawiJourney — Code Audit Fix Plan

> **Source:** Full code audit of the `rawi-journey` repo (April 3, 2026)
> **For:** Claude Code agent in VS Code
> **Priority:** Fix in order — items 2–4 are launch blockers.
> Item 1 (fonts) is deferred to Play Store prep phase.

---

## Fix 1 — Bundle Fonts Offline (PRE-PLAY STORE — DEFERRED)

**Status:** DO NOT implement now. This is queued for the final Play Store
prep phase, after all 36 events are built and the app is feature-complete.

**Why deferred:** `google_fonts` caches fonts on the device after first
use. Since users download the app from the Play Store (online by
definition), fonts will cache on first launch in nearly all cases.
The risk is narrow — first launch with no connectivity — but for a
paid $9.99 offline app, bundling fonts removes the dependency on
Google's CDN entirely. Do this before charging users.

**Problem:** `google_fonts` package fetches fonts over the network on
first use. If the device has no connectivity on first launch, text
renders in fallback system fonts.

**Files affected:**
- `pubspec.yaml`
- `lib/main.dart`
- Every file using `GoogleFonts.xxx()` (search project-wide)

**Steps:**

1. Download these font families as TTF/OTF files:
   - **Poppins** (Regular, Bold, SemiBold) — used as base text theme
   - **Nunito** (Regular, SemiBold, Bold, W700) — UI labels, buttons, options
   - **Lora** (Regular Italic, SemiBold Italic) — explanations, narrative
   - **Cinzel Decorative** (Regular) — question text
   - **Noto Naskh Arabic** (Regular, Bold) — Arabic text fallback

   Download from: https://fonts.google.com (click Download Family)

2. Place font files in `assets/fonts/` (create the directory).

3. Declare in `pubspec.yaml` under the `flutter:` section:
   ```yaml
   fonts:
     - family: Poppins
       fonts:
         - asset: assets/fonts/Poppins-Regular.ttf
         - asset: assets/fonts/Poppins-SemiBold.ttf
           weight: 600
         - asset: assets/fonts/Poppins-Bold.ttf
           weight: 700
     - family: Nunito
       fonts:
         - asset: assets/fonts/Nunito-Regular.ttf
         - asset: assets/fonts/Nunito-SemiBold.ttf
           weight: 600
         - asset: assets/fonts/Nunito-Bold.ttf
           weight: 700
     - family: Lora
       fonts:
         - asset: assets/fonts/Lora-Regular.ttf
         - asset: assets/fonts/Lora-Italic.ttf
           style: italic
         - asset: assets/fonts/Lora-SemiBoldItalic.ttf
           weight: 600
           style: italic
     - family: CinzelDecorative
       fonts:
         - asset: assets/fonts/CinzelDecorative-Regular.ttf
   ```

4. Replace ALL `GoogleFonts.xxx()` calls project-wide:
   ```dart
   // BEFORE
   GoogleFonts.nunito(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)

   // AFTER
   TextStyle(fontFamily: 'Nunito', color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)
   ```

   ```dart
   // BEFORE (main.dart)
   textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

   // AFTER
   textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
   ```

5. Remove from `pubspec.yaml`:
   ```yaml
   google_fonts: ^6.2.1
   ```

6. Remove all `import 'package:google_fonts/google_fonts.dart';` lines.

7. Run `flutter analyze` — zero errors expected.

8. Test on device with airplane mode ON from fresh install.

**Verification:** Launch app in airplane mode after clearing app data.
All text must render in the correct fonts on every screen.

---

## Fix 2 — Release Signing Config (LAUNCH BLOCKER)

**Problem:** `android/app/build.gradle.kts` uses debug signing for
release builds. Google Play will reject this.

**Steps:**

1. Generate a release keystore (Khaled runs this locally — NOT in the
   agent, since the keystore must be kept private):
   ```bash
   keytool -genkey -v -keystore rawi-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias rawi
   ```

2. Create `android/key.properties` (Khaled fills in the values):
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=rawi
   storeFile=../rawi-release.jks
   ```

3. Update `android/app/build.gradle.kts`:
   ```kotlin
   // Add at the top, after plugins block:
   import java.util.Properties
   import java.io.FileInputStream

   val keystoreProperties = Properties()
   val keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(FileInputStream(keystorePropertiesFile))
   }

   // Replace the buildTypes block:
   android {
       // ... existing config ...

       signingConfigs {
           create("release") {
               keyAlias = keystoreProperties["keyAlias"] as String?
               keyPassword = keystoreProperties["keyPassword"] as String?
               storeFile = keystoreProperties["storeFile"]?.let { file(it) }
               storePassword = keystoreProperties["storePassword"] as String?
           }
       }

       buildTypes {
           release {
               signingConfig = signingConfigs.getByName("release")
               isMinifyEnabled = true
               isShrinkResources = true
               proguardFiles(
                   getDefaultProguardFile("proguard-android-optimize.txt"),
                   "proguard-rules.pro"
               )
           }
       }
   }
   ```

4. Create `android/app/proguard-rules.pro`:
   ```
   # Flutter
   -keep class io.flutter.** { *; }
   -keep class io.flutter.plugins.** { *; }

   # just_audio
   -keep class com.google.android.exoplayer2.** { *; }
   ```

5. Add to `.gitignore`:
   ```
   android/key.properties
   *.jks
   ```

**Note for agent:** Set up the build.gradle.kts changes and proguard
file. Khaled handles keystore generation and key.properties locally.

---

## Fix 3 — Crash Reporting (LAUNCH RISK)

**Problem:** No crash reporting. Paid app with zero visibility into
production failures.

**Steps:**

1. Add Firebase Crashlytics to the project:
   ```yaml
   # pubspec.yaml
   dependencies:
     firebase_core: ^3.12.1
     firebase_crashlytics: ^4.3.2
   ```

2. Update `lib/main.dart`:
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import 'package:firebase_crashlytics/firebase_crashlytics.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();

     // Pass all uncaught errors to Crashlytics
     FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

     await PrefsService.init();
     // ... rest of existing main
   }
   ```

3. Android setup:
   - Add `google-services.json` to `android/app/` (Khaled gets this
     from Firebase Console after creating the project).
   - Add to `android/build.gradle.kts` (project-level):
     ```kotlin
     plugins {
         id("com.google.gms.google-services") version "4.4.2" apply false
         id("com.google.firebase.crashlytics") version "3.0.3" apply false
     }
     ```
   - Add to `android/app/build.gradle.kts`:
     ```kotlin
     plugins {
         id("com.google.gms.google-services")
         id("com.google.firebase.crashlytics")
     }
     ```

**Note for agent:** Set up the Dart code and Gradle plugin references.
Khaled creates the Firebase project and provides `google-services.json`.
This requires network access for the SDK download — run `flutter pub get`
after adding the dependencies.

---

## Fix 4 — Asset Size Strategy (LAUNCH RISK)

**Problem:** 18MB for 3 events. Extrapolated to 36 events: ~150–200MB.
Play Store APK limit is 150MB.

**Steps (immediate — for existing assets):**

1. Convert all VO `.mp3` files in `assets/audio/vo/` to `.ogg` (Opus):
   ```bash
   # Run from project root (requires ffmpeg)
   for f in assets/audio/vo/*.mp3; do
     ffmpeg -i "$f" -c:a libopus -b:a 24k "${f%.mp3}.ogg"
   done
   # Then delete the .mp3 files and update all VO path references
   ```
   Expected savings: 40–60% (~3–4MB saved on current VO alone).

2. Convert companion audio similarly:
   ```bash
   for f in assets/audio/companion/*.mp3; do
     ffmpeg -i "$f" -c:a libopus -b:a 24k "${f%.mp3}.ogg"
   done
   ```

3. Update all hardcoded `.mp3` references in:
   - `lib/screens/immersive_event_screen.dart` — `_voPath()`,
     `_choiceVoPath()`, `_companionVoPath()`
   - `lib/data/scene_configs.dart` — any `sfxPath` values
   - `lib/data/companion_dialogue.dart` — if any paths there

   Change `.mp3` → `.ogg` in the path builder methods.

4. Compress scene background JPGs:
   ```bash
   # Target: 80% quality, max 1920px wide
   for f in assets/scenes/*.jpg; do
     convert "$f" -quality 80 -resize '1920x>' "$f"
   done
   ```

5. Update `pubspec.yaml` assets section if any extensions changed.

6. Verify `just_audio` plays `.ogg` files correctly on device.

**Note for agent:** The ffmpeg conversion is a local task for Khaled.
Agent should update all path references from `.mp3` to `.ogg` in the
Dart code, and verify playback still works after the swap.

---

## Fix 5 — Remove Unused `latlong2` Dependency

**Problem:** `latlong2` is imported in `journey_event.dart` and
`m1_data.dart` but `LatLng position` is never used by any screen —
no map view exists. Dead dependency.

**Steps:**

1. In `lib/models/journey_event.dart`:
   - Remove `import 'package:latlong2/latlong.dart';`
   - Change the `position` field from `LatLng` to two doubles:
     ```dart
     /// Map pin location (reserved for future map view)
     final double latitude;
     final double longitude;
     ```
   - Update the constructor accordingly.

2. In `lib/data/m1_data.dart`:
   - Remove `import 'package:latlong2/latlong.dart';`
   - Replace all `position: LatLng(21.4225, 39.8262)` with:
     ```dart
     latitude: 21.4225,
     longitude: 39.8262,
     ```

3. In `test/branching_test.dart`:
   - Remove `import 'package:latlong2/latlong.dart';`
   - Update test event constructors to use `latitude`/`longitude`.

4. Remove from `pubspec.yaml`:
   ```yaml
   latlong2: ^0.9.0
   ```

5. Run `flutter pub get` then `flutter analyze` — zero errors.

---

## Fix 6 — Delete Dead Code

**Problem:** `lib/screens/aerial_hub_screen.dart` is 425 lines with
zero imports anywhere in the project. Confirmed dead by grep.

**Steps:**

1. Delete `lib/screens/aerial_hub_screen.dart`.
2. Run `flutter analyze` — confirm no breakage.

---

## Fix 7 — Hardcoded `36` → Constant

**Problem:** `lib/services/prefs_service.dart` has `List.generate(36, ...)`
in two places in `checkAndAwardBadges()`. When events expand beyond 36,
badges silently break.

**Steps:**

1. In `lib/data/m1_data.dart`, add at the top after the list:
   ```dart
   /// Total number of events in the current module.
   final int m1EventCount = m1Events.length;
   ```

2. In `lib/services/prefs_service.dart`:
   - Add import: `import '../data/m1_data.dart';`
   - Replace both occurrences of:
     ```dart
     List.generate(36, (i) => i + 1)
     ```
     with:
     ```dart
     List.generate(m1EventCount, (i) => i + 1)
     ```

3. Run `flutter test` — all 5 tests must pass.

---

## Fix 8 — FootprintPainter Performance

**Problem:** `_FootprintPainter.shouldRepaint` always returns `true`,
causing unnecessary repaints every frame even when footprints haven't
changed.

**File:** `lib/screens/immersive_event_screen.dart` (bottom of file,
~line 1637)

**Steps:**

Replace:
```dart
@override
bool shouldRepaint(_FootprintPainter old) => true;
```

With:
```dart
@override
bool shouldRepaint(_FootprintPainter old) =>
    footprints.length != old.footprints.length ||
    sceneOffset != old.sceneOffset;
```

---

## Fix 9 — In-Scene Language Toggle Persistence

**Problem:** The EN/AR toggle in the immersive event screen header sets
`_isAr` locally but doesn't write to SharedPreferences. Language resets
on exit.

**File:** `lib/screens/immersive_event_screen.dart` (~line 974)

**Steps:**

Replace:
```dart
onTap: () => setState(() => _isAr = !_isAr),
```

With:
```dart
onTap: () {
  setState(() => _isAr = !_isAr);
  PrefsService.setLanguage(_isAr ? 'ar' : 'en');
},
```

---

## Fix 10 — Streak First-Day Edge Case

**Problem:** On the very first event completion, `updateStreak()` writes
the date but never explicitly writes the streak value of 1. The default
getter returns 1, so it works — but the value isn't persisted until
day 2. If you ever read streak from a backup or migration, it's missing.

**File:** `lib/services/prefs_service.dart` (~line 42)

**Steps:**

Replace the `updateStreak()` method:
```dart
static Future<void> updateStreak() async {
  final today = _todayStr();
  final last  = _prefs?.getString(_keyStreakDate) ?? '';
  if (last == today) return;
  if (last.isEmpty) {
    // First ever completion — initialize streak
    await _prefs?.setInt(_keyStreak, 1);
  } else {
    final diff = DateTime.now().difference(DateTime.parse(last)).inDays;
    await _prefs?.setInt(_keyStreak, diff == 1 ? streak + 1 : 1);
  }
  await _prefs?.setString(_keyStreakDate, today);
}
```

---

## Execution Order

| # | Fix | Blocker? | Estimated Effort |
|---|-----|----------|------------------|
| 2 | Release signing config | YES (Khaled + Agent) | 1 hour |
| 3 | Crash reporting | High priority | 1 hour + Khaled Firebase setup |
| 4 | Asset size (path refs) | High priority | 30 min (code), Khaled converts files |
| 5 | Remove latlong2 | Cleanup | 20 min |
| 6 | Delete dead code | Cleanup | 2 min |
| 7 | Hardcoded 36 → constant | Cleanup | 10 min |
| 8 | FootprintPainter perf | Polish | 5 min |
| 9 | Language toggle persist | Polish | 5 min |
| 10 | Streak edge case | Polish | 5 min |
| 1 | Bundle fonts offline | Pre-Play Store | 1–2 hours (deferred) |

**After all fixes:** Run `flutter analyze`, `flutter test`, and
`gradlew.bat assembleRelease` from the `android` subfolder.

**Fix 1 (fonts) trigger:** When all 36 events are built and the app is
entering Play Store submission prep, come back to Fix 1 above and
execute the full font bundling steps. Until then, `google_fonts` works
fine for development and testing.

---

## What NOT to Touch

- The branching system (Sprints 21–24) — working correctly, tested
- The completion flow (race condition fix) — confirmed working
- The audio layering architecture — solid
- The content in `m1_data.dart` — the writing is excellent
- The widget structure under `widgets/cinematic/` — clean and modular
