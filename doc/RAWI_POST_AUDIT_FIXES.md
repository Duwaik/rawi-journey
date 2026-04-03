# RawiJourney — Post-Audit Fixes (3 Items)

> **Date:** April 3, 2026
> **Source:** Full re-audit of latest repo (commit af6b59c)
> **Context:** 22+ items verified correct. These 3 remain.

---

## Fix 1 — Master Plan: Black Stone Row Missing from Event Table

**File:** `RAWI_MASTER_PLAN.md` — Section 8, Milestone 1

**Problem:** The note at line 166 says "Black Stone (605 CE) moved to
Early Life position 8" but the Black Stone event (j_m1_003) is not
actually listed in the Early Life table. The table rows jump from
Event 2 (Year of the Elephant) straight to Event 4 (Birth). The note
also says "position 8" which is wrong — in the 47-event Master Plan
list, it should be position 12 (after Marriage to Khadijah at 595 CE
and before Cave Hira at 610 CE).

**Fix:**

1. Remove the note at line 166 ("Black Stone moved to position 8")

2. Insert the Black Stone row into the Early Life table between
   Marriage to Khadijah (595 CE) and Solitude in Cave Hira (610 CE):

   ```
   | 12 | j_m1_012 | Marriage to Khadijah RA | ... | 595 CE | Mecca | 30 |
   | 12b | j_m1_003 | The Black Stone — A Wise Arbitration | الحجر الأسود — حكمة التحكيم | 605 CE | Mecca | 20 |
   | 13 | j_m1_013 | Solitude in Cave Hira | ... | 610 CE | Mecca | 25 |
   ```

   OR — cleaner: renumber the entire Early Life section to be
   sequential (3–15 instead of 3–14, since it now has one more event).
   This means Mecca events shift to 16–48 and M1 total becomes 48.

   **Recommended approach:** Since the 47-event Master Plan was written
   before the reorder, and the actual app code uses a separate
   numbering (36 events, globalOrder 1–36), the simplest fix is:
   - Insert the Black Stone row at its correct chronological position
     (between Marriage 595 CE and Hira 610 CE)
   - Renumber Early Life as Events 3–15 (13 events)
   - Renumber Mecca as Events 16–48 (33 events)
   - Update M1 total from 47 to 48 events
   - Update the era distribution table in Section 10
   - Update the note at line 391 to remove "position 8" reference

3. Update the era distribution table (Section 10):
   ```
   | jahiliyyah | 2 | 1–2 |
   | earlyLife | 13 | 3–15 |
   | mecca | 33 | 16–48 |
   | medina | 108 | 49–156 |
   ```
   (Grand total becomes 156 instead of 155)

**Priority:** High — the Master Plan is the single source of truth
for content. A missing event row is a documentation integrity issue.

---

## Fix 2 — Android 12+ Splash Screen White Background

**Problem:** On Android 12+ (API 31+), the system ignores the
`LaunchTheme` window background for the splash screen and instead
uses the new `SplashScreen` API. It takes the adaptive icon and
renders it inside a system-controlled container with a default white
background. The current `values/styles.xml` changes work for pre-12
but not for the new splash system.

**Files to create/modify:**

1. Create `android/app/src/main/res/values-v31/styles.xml`:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <resources>
       <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
           <item name="android:windowBackground">@color/navy_bg</item>
           <item name="android:windowSplashScreenBackground">@color/navy_bg</item>
           <item name="android:windowSplashScreenIconBackgroundColor">@color/navy_bg</item>
       </style>
       <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
           <item name="android:windowBackground">@color/navy_bg</item>
       </style>
   </resources>
   ```

2. Verify that `android/app/src/main/res/values/colors.xml` exists
   with:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <resources>
       <color name="navy_bg">#FF0B1E2D</color>
   </resources>
   ```

3. Also check `values-night/styles.xml` — if it exists, apply the
   same navy background there too.

**Testing:** After applying, uninstall the app completely from the
test device (Samsung A56, Android 15), reinstall, and verify:
- Cold launch: navy background, icon centered, no white squircle
- App resume after backgrounding: navy background, no flash

**Note:** On some Samsung devices (One UI), the system may still
briefly show the adaptive icon container. If the white persists after
the `values-v31` fix, the adaptive icon itself may need a navy
background layer. Check `android/app/src/main/res/mipmap-*/` for
`ic_launcher_background` — if it exists, it should be navy. If using
`flutter_launcher_icons`, set `adaptive_icon_background` to
`"#0B1E2D"` in pubspec.yaml.

**Priority:** High — reported twice by Khaled, visible on every
app resume.

---

## Fix 3 — Clean Up Duplicate Doc Files

**Problem:** The `/doc/` directory contains multiple versions of the
same document:
- `RAWI_ISSUES_AND_ENHANCEMENTS_3.md`
- `RAWI_ISSUES_AND_ENHANCEMENTS_5.md`
- `RAWI_ISSUES_AND_ENHANCEMENTS_7.md`

Only the latest version should exist. Old versions create confusion
for anyone reading the project.

**Fix:**
1. Delete `doc/RAWI_ISSUES_AND_ENHANCEMENTS_3.md`
2. Delete `doc/RAWI_ISSUES_AND_ENHANCEMENTS_5.md`
3. Rename `doc/RAWI_ISSUES_AND_ENHANCEMENTS_7.md` to
   `doc/RAWI_ISSUES_AND_ENHANCEMENTS.md` (no version suffix)

**Priority:** Low — housekeeping.

---

## Verification Checklist (After All 3 Fixes)

- [ ] Black Stone row visible in Master Plan Early Life table
- [ ] Early Life event count updated (13 events in 48-event M1)
- [ ] Era distribution table updated
- [ ] No "position 8" references remain
- [ ] `values-v31/styles.xml` created with splash background
- [ ] Cold launch on Android 12+ shows navy, no white
- [ ] App resume shows navy, no white squircle
- [ ] Only one version of issues doc in `/doc/`
- [ ] `flutter analyze` — zero errors
- [ ] `flutter test` — all tests pass
