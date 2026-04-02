# Rawi — رواي
## Master Plan & Full Event Documentation

> بسم الله الرحمن الرحيم
> "Witness history. Carry the story."

**Last updated:** 2026-04-02
**Project path:** `D:\Rawi_Journey`
**App package:** `com.rawi.journey` ✅
**GitHub:** `github.com/Duwaik/rawi-journey` (private)
**Architecture:** See `ARCHITECTURE.md` for full file tree, data flow, audio layers, and nav flow

---

## 1. Brand Identity

### Name
**Rawi** (راوي) — The Narrator

In Islamic tradition, a *Rawi* is the human link in the chain of transmission (*isnad*) — the person who carries the narration forward so it reaches the next generation. In the game, the user *becomes* the Rawi: witnessing events firsthand, then carrying that knowledge forward.

### Tagline
**"Witness history. Carry the story."**
Arabic: **"كن شاهداً. احمل الرواية."**

### Volume Structure (Franchise)
| Volume | Title | Era | Status |
|---|---|---|---|
| Vol. 1 | **Rawi: The Seerah** | السيرة النبوية (570–632 CE) | In Development |
| Vol. 2 | **Rawi: The Rashidun** | الخلفاء الراشدون (632–661 CE) | Planned |
| Vol. 3 | **Rawi: The Golden Age** | العصر الذهبي — Abbasid (750–1258 CE) | Planned |
| Vol. 4 | **Rawi: The Ottoman** | الدولة العثمانية (1299–1922 CE) | Planned |

### Vol. 1 Sub-title
**Rawi: The Seerah — السيرة النبوية الشريفة**

---

## 2. Core Product Vision

A **mobile game** about the life of Prophet Muhammad ﷺ told through:
- **Immersive parallax scenes** per historical event with joystick-driven exploration (replaced 360° approach)
- **Companion mode** — the user witnesses events as a companion (image-based avatar in circle, gender-selected during onboarding). The Prophet ﷺ is never depicted visually (Islamic principle). He exists only through narration and the reactions of those around the user.
- **Diamond hotspot discovery** — explore scene to find sequential hotspots (progressive reveal)
- **Convergent branching** — 2 types:
  - *Type 1 — Action choice:* Genuine ambiguity (e.g., "Stay still" vs "Step to the cave opening")
  - *Type 2 — Focus choice:* What do you observe? (e.g., "Watch the Prophet's face" vs "Watch the crowd")
  - Both types converge at the same historical truth
- **Sequential progression** — complete event N to unlock N+1
- **3-layer audio** — ambient sound (Layer 1) + voiceover narration via Edge TTS (Layer 2) + SFX (Layer 3)
- **Bilingual** — Arabic and English throughout, switchable in settings anytime
- **Replay system** — completed events are replayable from the branch point, no XP re-award
- **Full gaming UX** — splash screen, intro cinematic, registration (name/gender/language), in-game settings overlay (pause, toggles), hub settings screen

> "The atmosphere of a film. The mechanics of a game."

---

## 3. Design System (Style C — Cinematic × Illustrated)

| Element | Spec |
|---|---|
| Color — Background | Deep navy `#0B1E2D` |
| Color — Gold accent | `#C9A84C` |
| Color — Card | `#0F2336` |
| Color — Text primary | `#F7F5F0` |
| Color — Text muted | `#8A9BB0` |
| Font — Titles | Cinzel Decorative (Google Fonts) |
| Font — Narrative text | Lora Italic (Google Fonts) |
| Font — UI / labels | Nunito (Google Fonts) |
| Border radius | 16–20px |
| Map tiles | ESRI NatGeo (free, no API key) |

---

## 4. Source Hierarchy (Content Rules — Strict)

| Tier | Sources | Usage |
|---|---|---|
| Tier 1 | القرآن الكريم | All Quranic references — exact, never paraphrased |
| Tier 2 | Sahih Bukhari + Sahih Muslim + Four Sunan | All hadith citations |
| Tier 3 | الرحيق المختوم (Mubarakpuri) + سيرة ابن هشام + البداية والنهاية | Narrative structure, event details, chronology |

**Prohibited:**
- Isra'iliyyat (unverified narrations from biblical/Israeli sources)
- The Bahira incident (excluded — unverified chain)
- Any visual depiction of the Prophet ﷺ
- Speculative dialogue attributed to the Prophet ﷺ without hadith source

---

## 5. Tech Stack

```yaml
# Current (in pubspec.yaml)
flutter: ">=3.11.1"
shared_preferences: ^2.3.2 # Local progression + user prefs
google_fonts: ^6.2.1       # Cinzel, Lora, Nunito
just_audio: ^0.9.40        # Ambient + voiceover + SFX
latlong2: ^0.9.0           # LatLng (event geo-coordinates in data model)
cupertino_icons: ^1.0.8    # iOS-style icons

# Removed (from original plan)
# flutter_map — replaced by aerial hub parallax approach
# panorama — replaced by parallax scene approach
# audioplayers — consolidated into just_audio
```

**Audio production:** Edge TTS (free, no API key)
- Arabic voice: `ar-JO-TaimNeural` (male) / `ar-JO-SanaNeural` (female) — Jordanian dialect
- English voice: `en-GB-RyanNeural` (male) / `en-GB-SoniaNeural` (female) — British
- Pre-generated MP3s as Flutter assets, gender-aware based on user selection
- Python `edge-tts` script for batch generation

---

## 6. Audio Architecture (3 Layers)

| Layer | Type | Tool | Scale |
|---|---|---|---|
| 1 | Ambient background (per location type) | just_audio, looping | ~15 unique ambient files |
| 2 | Voiceover narration (per event, per language) | ElevenLabs pre-generated MP3 | 155 events × 2 lang = 310 files |
| 3 | UI sound effects (tap, unlock, complete) | audioplayers, Mixkit | ~10 files |

**Delivery strategy:** Era download packs (not bundled in APK)
- Download "Meccan Era" audio on first launch of M1
- Each pack ~5–8MB after compression
- Language-specific: download only the user's language

---

## 7. Milestone Summary

| Milestone | Title | Era | Events | Global Orders | Status |
|---|---|---|---|---|---|
| M1 | The Prophetic Dawn | Jahiliyyah + Early Life + Meccan Period | 47 | 1–47 | Data built (36), expanding to 47 |
| M2 | The Community Rises | Early Medinan Period (622–627 CE) | 35 | 48–82 | Planned |
| M3 | The Turning Tide | Consolidation (627–630 CE) | 38 | 83–120 | Planned |
| M4 | The Final Chapter | Tabuk + Farewell + Departure (630–632 CE) | 35 | 121–155 | Planned |
| **Total** | | | **155** | **1–155** | |

---

## 8. Full Event List

### MILESTONE 1 — The Prophetic Dawn (570–622 CE)
**47 events | Global Orders 1–47**

#### Era: Jahiliyyah (الجاهلية) — Events 1–3

| # | ID | Title (EN) | Title (AR) | Year | Location | XP |
|---|---|---|---|---|---|---|
| 1 | j_m1_001 | Arabia Before the Light | الجزيرة العربية قبل النور | 500 CE | Arabia | 20 |
| 2 | j_m1_002 | The Year of the Elephant | عام الفيل | 570 CE | Mecca | 30 |
| 3 | j_m1_003 | The Black Stone — A Wise Arbitration | الحجر الأسود — حكمة التحكيم | 605 CE | Mecca | 20 |

#### Era: Early Life (الحياة المبكرة) — Events 4–14

| # | ID | Title (EN) | Title (AR) | Year | Location | XP |
|---|---|---|---|---|---|---|
| 4 | j_m1_004 | Birth of the Prophet ﷺ | مولد النبي ﷺ | 570 CE | Mecca | 30 |
| 5 | j_m1_005 | The Nursing Years — Halimah al-Sa'diyyah | سنوات الرضاعة مع حليمة السعدية | 570 CE | Banu Sa'd | 20 |
| 6 | j_m1_006 | The Opening of the Chest | شرح الصدر | 574 CE | Banu Sa'd | 30 |
| 7 | j_m1_007 | Return to Mecca — Death of Aminah | العودة إلى مكة — وفاة آمنة | 576 CE | Abwa | 20 |
| 8 | j_m1_008 | Under the Care of Abd al-Muttalib | في كنف عبد المطلب | 576 CE | Mecca | 20 |
| 9 | j_m1_009 | Under the Guardian: Abu Talib | في كنف أبي طالب | 578 CE | Mecca | 20 |
| 10 | j_m1_010 | Hilf al-Fudul — The Pact of the Virtuous | حلف الفضول | 590 CE | Mecca | 25 |
| 11 | j_m1_011 | Al-Amin — The Trustworthy | الأمين | 595 CE | Mecca | 20 |
| 12 | j_m1_012 | Marriage to Khadijah RA | الزواج من خديجة رضي الله عنها | 595 CE | Mecca | 30 |
| 13 | j_m1_013 | Solitude in Cave Hira | الخلوة في غار حراء | 610 CE | Mecca | 25 |
| 14 | j_m1_014 | The First Revelation — اقرأ | أول الوحي — اقرأ | 610 CE | Cave Hira | **50** |

#### Era: Mecca (مكة المكرمة) — Events 15–47

| # | ID | Title (EN) | Title (AR) | Year | Location | XP |
|---|---|---|---|---|---|---|
| 15 | j_m1_015 | The First Believers | أوائل المؤمنين | 610 CE | Mecca | 25 |
| 16 | j_m1_016 | Three Years of Secret Preaching | ثلاث سنوات من الدعوة السرية | 610 CE | Mecca | 20 |
| 17 | j_m1_017 | The Call Goes Public — Mount Safa | الإعلان على الملأ — جبل الصفا | 613 CE | Mecca | 30 |
| 18 | j_m1_018 | Quraysh React — First Persecution | ردة فعل قريش — بداية الأذى | 614 CE | Mecca | 25 |
| 19 | j_m1_019 | The Torture of the Weak | تعذيب المستضعفين | 614 CE | Mecca | 30 |
| 20 | j_m1_020 | First Migration to Abyssinia | الهجرة الأولى إلى الحبشة | 615 CE | Axum | 30 |
| 21 | j_m1_021 | The Quraysh Delegation to the Negus | وفد قريش إلى النجاشي | 615 CE | Axum | 25 |
| 22 | j_m1_022 | The Negus Protects the Muslims | النجاشي يحمي المسلمين | 615 CE | Axum | 30 |
| 23 | j_m1_023 | Hamza Accepts Islam | إسلام حمزة رضي الله عنه | 615 CE | Mecca | 30 |
| 24 | j_m1_024 | Umar Accepts Islam | إسلام عمر رضي الله عنه | 616 CE | Mecca | 30 |
| 25 | j_m1_025 | Second Migration to Abyssinia | الهجرة الثانية إلى الحبشة | 616 CE | Axum | 25 |
| 26 | j_m1_026 | The Boycott Begins | بداية الحصار في الشعب | 616 CE | Shi'b Abi Talib | 25 |
| 27 | j_m1_027 | Three Years of Siege | ثلاث سنوات في الشعب | 616 CE | Shi'b Abi Talib | 30 |
| 28 | j_m1_028 | The Boycott Ends | انتهاء الحصار | 619 CE | Mecca | 25 |
| 29 | j_m1_029 | Year of Grief — Death of Khadijah RA | عام الحزن — وفاة خديجة رضي الله عنها | 619 CE | Mecca | **40** |
| 30 | j_m1_030 | Year of Grief — Death of Abu Talib | عام الحزن — وفاة أبي طالب | 619 CE | Mecca | 30 |
| 31 | j_m1_031 | Journey to Ta'if — Rejection & Resilience | رحلة الطائف — الرفض والثبات | 619 CE | Ta'if | **40** |
| 32 | j_m1_032 | The Return — Wadi Nakhlah | العودة — وادي نخلة | 619 CE | Wadi Nakhlah | 25 |
| 33 | j_m1_033 | Seeking Help from the Tribes | طلب النصرة من القبائل | 619 CE | Various | 20 |
| 34 | j_m1_034 | Al-Isra wal-Mi'raj | الإسراء والمعراج | 620 CE | Jerusalem / Heavens | **60** |
| 35 | j_m1_035 | Abu Bakr Believes Without Hesitation | أبو بكر يصدّق بلا تردد | 620 CE | Mecca | 30 |
| 36 | j_m1_036 | The First Pledge of Aqabah | بيعة العقبة الأولى | 620 CE | Mina | 30 |
| 37 | j_m1_037 | Mus'ab ibn Umayr Sent to Medina | إرسال مصعب بن عمير إلى المدينة | 620 CE | Medina | 25 |
| 38 | j_m1_038 | The Second Pledge of Aqabah | بيعة العقبة الثانية | 621 CE | Mina | **40** |
| 39 | j_m1_039 | The Plot to Kill the Prophet ﷺ | مؤامرة الاغتيال | 622 CE | Mecca | 30 |
| 40 | j_m1_040 | The Night of the Hijrah — Ali in the Bed | ليلة الهجرة — علي في الفراش | 622 CE | Mecca | 35 |
| 41 | j_m1_041 | Suraqa ibn Malik — The Pursuit | سراقة بن مالك — المطاردة | 622 CE | Desert | 30 |
| 42 | j_m1_042 | Three Days in Cave Thawr | ثلاثة أيام في غار ثور | 622 CE | Cave Thawr | **40** |
| 43 | j_m1_043 | The Desert Journey to Medina | رحلة الهجرة في الصحراء | 622 CE | Desert route | 25 |
| 44 | j_m1_044 | Arrival in Quba | الوصول إلى قباء | 622 CE | Quba | 30 |
| 45 | j_m1_045 | Masjid Quba — First Mosque in Islam | مسجد قباء — أول مسجد في الإسلام | 622 CE | Quba | 30 |
| 46 | j_m1_046 | The First Friday Prayer | أول صلاة جمعة | 622 CE | Wadi Ranuna | 25 |
| 47 | j_m1_047 | Entry into Medina — The City Rejoices | الدخول إلى المدينة — الفرحة العارمة | 622 CE | Medina | **50** |

**M1 Total XP:** ~1,455 XP

---

### MILESTONE 2 — The Community Rises (622–627 CE)
**35 events | Global Orders 48–82**

#### Era: Medina (المدينة المنورة) — Events 48–82

| # | ID | Title (EN) | Title (AR) | Year | Location | XP |
|---|---|---|---|---|---|---|
| 48 | j_m2_048 | Building the Prophet's Mosque | بناء المسجد النبوي الشريف | 622 CE | Medina | **40** |
| 49 | j_m2_049 | The Brotherhood — Muakhah | المؤاخاة بين المهاجرين والأنصار | 622 CE | Medina | 30 |
| 50 | j_m2_050 | The Constitution of Medina | صحيفة المدينة | 622 CE | Medina | 30 |
| 51 | j_m2_051 | The Adhan — The Call to Prayer | تشريع الأذان | 623 CE | Medina | 30 |
| 52 | j_m2_052 | Change of Qibla — Toward Mecca | تحويل القبلة نحو مكة | 624 CE | Medina | **40** |
| 53 | j_m2_053 | The First Expeditions — Saraya of Hamza & Ubaidah | أوائل السرايا | 623 CE | Coast | 20 |
| 54 | j_m2_054 | Expedition of Abdullah ibn Jahsh | سرية عبد الله بن جحش | 623 CE | Nakhla | 25 |
| 55 | j_m2_055 | The Road to Badr — Abu Sufyan's Caravan | الطريق إلى بدر | 624 CE | Arabia | 25 |
| 56 | j_m2_056 | Battle of Badr — The March to the Well | مسير بدر | 624 CE | Badr | 30 |
| 57 | j_m2_057 | Battle of Badr — The Battle | يوم بدر الكبرى | 624 CE | Badr | **60** |
| 58 | j_m2_058 | The Angels of Badr | ملائكة بدر | 624 CE | Badr | 30 |
| 59 | j_m2_059 | Prisoners of Badr — The Question of Ransom | أسرى بدر — مسألة الفداء | 624 CE | Medina | 25 |
| 60 | j_m2_060 | Banu Qaynuqa — Expulsion | إجلاء بني قينقاع | 624 CE | Medina | 25 |
| 61 | j_m2_061 | The Traitor's End — Ka'b ibn al-Ashraf | نهاية الخائن — كعب بن الأشرف | 624 CE | Medina | 25 |
| 62 | j_m2_062 | Battle of Uhud — The Quraysh Return | غزوة أحد — عودة قريش | 625 CE | Medina | 25 |
| 63 | j_m2_063 | Battle of Uhud — The March Out | الخروج إلى أحد | 625 CE | Medina | 25 |
| 64 | j_m2_064 | Battle of Uhud — The Battle | يوم أحد | 625 CE | Uhud | **50** |
| 65 | j_m2_065 | The Archers' Fateful Choice | قرار الرماة المصيري | 625 CE | Uhud | **40** |
| 66 | j_m2_066 | The Aftermath — Hamza's Martyrdom | شهادة أسد الله — حمزة | 625 CE | Uhud | **40** |
| 67 | j_m2_067 | Battle of Hamra al-Asad — The Pursuit | حمراء الأسد | 625 CE | Near Medina | 25 |
| 68 | j_m2_068 | Treachery at Raji' | حادثة الرجيع | 625 CE | Raji' | 25 |
| 69 | j_m2_069 | Tragedy of Bi'r Ma'una — 70 Reciters | مأساة بئر معونة | 625 CE | Bi'r Ma'una | 30 |
| 70 | j_m2_070 | Banu Nadir — Expulsion | إجلاء بني النضير | 625 CE | Medina | 25 |
| 71 | j_m2_071 | Battle of Badr al-Maw'id | بدر الموعد | 626 CE | Badr | 20 |
| 72 | j_m2_072 | Expedition of Banu Mustaliq | غزوة بني المصطلق | 627 CE | Muraysi | 25 |
| 73 | j_m2_073 | The Slander — Al-Ifk | حادثة الإفك وبراءة أم المؤمنين | 627 CE | Medina | **40** |
| 74 | j_m2_074 | Digging the Trench | حفر الخندق | 627 CE | Medina | 30 |
| 75 | j_m2_075 | Battle of the Trench — The Siege | الخندق — الحصار الكبير | 627 CE | Medina | **50** |
| 76 | j_m2_076 | Nu'aym ibn Mas'ud — The Stratagem | نعيم بن مسعود — المكيدة | 627 CE | Medina | 30 |
| 77 | j_m2_077 | Amr ibn Abd Wudd — The Duel | عمرو بن عبد ود — البراز | 627 CE | Khandaq | **40** |
| 78 | j_m2_078 | The Wind of Victory | ريح النصر — انسحاب الأحزاب | 627 CE | Medina | 30 |
| 79 | j_m2_079 | Banu Qurayza — The Siege | حصار بني قريظة | 627 CE | Medina | 25 |
| 80 | j_m2_080 | The Judgment of Sa'd ibn Mu'adh | حكم سعد بن معاذ | 627 CE | Medina | 30 |
| 81 | j_m2_081 | Sa'd ibn Mu'adh — The Martyrdom | شهادة سعد بن معاذ | 627 CE | Medina | 30 |
| 82 | j_m2_082 | The Throne of Allah Shook | اهتز عرش الرحمن | 627 CE | Medina | **40** |

**M2 Total XP:** ~1,110 XP

---

### MILESTONE 3 — The Turning Tide (627–630 CE)
**38 events | Global Orders 83–120**

#### Era: Medina — Continued (المدينة المنورة — تابع) — Events 83–120

| # | ID | Title (EN) | Title (AR) | Year | Location | XP |
|---|---|---|---|---|---|---|
| 83 | j_m3_083 | Post-Khandaq Expeditions | السرايا بعد الخندق | 627 CE | Various | 20 |
| 84 | j_m3_084 | The Journey to Hudaybiyyah | السفر إلى الحديبية | 628 CE | Mecca outskirts | 25 |
| 85 | j_m3_085 | The She-Camel Kneels | القصواء تبرك | 628 CE | Hudaybiyyah | 25 |
| 86 | j_m3_086 | Bay'at al-Ridwan — Under the Tree | بيعة الرضوان تحت الشجرة | 628 CE | Hudaybiyyah | **50** |
| 87 | j_m3_087 | Treaty of Hudaybiyyah | صلح الحديبية | 628 CE | Hudaybiyyah | **50** |
| 88 | j_m3_088 | Surah Al-Fath — A Clear Victory | سورة الفتح — إنا فتحنا لك فتحاً مبيناً | 628 CE | Road to Medina | **40** |
| 89 | j_m3_089 | Letter to Heraclius | رسالة هرقل قيصر الروم | 628 CE | Byzantium | 25 |
| 90 | j_m3_090 | Letter to Chosroes — The Torn Letter | رسالة كسرى — الرسالة الممزقة | 628 CE | Persia | 25 |
| 91 | j_m3_091 | Letter to Negus of Abyssinia | رسالة النجاشي | 628 CE | Abyssinia | 20 |
| 92 | j_m3_092 | Letter to Muqawqis of Egypt | رسالة المقوقس | 628 CE | Egypt | 20 |
| 93 | j_m3_093 | March to Khaybar | المسير إلى خيبر | 628 CE | Khaybar | 25 |
| 94 | j_m3_094 | Battle of Khaybar | غزوة خيبر | 628 CE | Khaybar | **50** |
| 95 | j_m3_095 | Ali's Triumph — The Gate of Khaybar | علي وباب خيبر | 628 CE | Khaybar | **40** |
| 96 | j_m3_096 | The Poisoned Lamb | الشاة المسمومة | 628 CE | Khaybar | 25 |
| 97 | j_m3_097 | Return of the Abyssinian Emigrants | عودة مهاجري الحبشة | 628 CE | Medina | 25 |
| 98 | j_m3_098 | Umrat al-Qada — Entering Mecca | عمرة القضاء — دخول مكة | 629 CE | Mecca | 30 |
| 99 | j_m3_099 | Khalid ibn al-Walid Accepts Islam | إسلام خالد بن الوليد | 629 CE | Medina | **40** |
| 100 | j_m3_100 | Amr ibn al-As Accepts Islam | إسلام عمرو بن العاص | 629 CE | Medina | 30 |
| 101 | j_m3_101 | Battle of Mu'tah | غزوة مؤتة | 629 CE | Mu'tah, Jordan | **40** |
| 102 | j_m3_102 | Three Commanders Fall — Zayd, Ja'far, Ibn Rawaha | استشهاد القادة الثلاثة | 629 CE | Mu'tah | **50** |
| 103 | j_m3_103 | Khalid Takes Command — Sword of Allah | خالد يقود وسيف من سيوف الله | 629 CE | Mu'tah | 30 |
| 104 | j_m3_104 | Expedition of Dhat al-Salasil | سرية ذات السلاسل | 629 CE | Syria border | 20 |
| 105 | j_m3_105 | The Conquest of Mecca — Quraysh Breaks the Treaty | قريش تنقض العهد | 629 CE | Mecca | 25 |
| 106 | j_m3_106 | Abu Sufyan's Last Journey to Medina | أبو سفيان في المدينة | 630 CE | Medina | 25 |
| 107 | j_m3_107 | The Secret March — Ten Thousand | المسيرة السرية — عشرة آلاف | 630 CE | Arabia | 30 |
| 108 | j_m3_108 | Abu Sufyan Witnesses the Army | أبو سفيان يشهد الجيش | 630 CE | Outside Mecca | 25 |
| 109 | j_m3_109 | Abu Sufyan Accepts Islam | إسلام أبي سفيان | 630 CE | Outside Mecca | 30 |
| 110 | j_m3_110 | Conquest of Mecca | فتح مكة المكرمة | 630 CE | Mecca | **60** |
| 111 | j_m3_111 | Cleansing the Kaaba — 360 Idols Fall | تطهير الكعبة — سقوط الأصنام | 630 CE | Mecca | **50** |
| 112 | j_m3_112 | The General Amnesty | العفو العام — من أنتم؟ | 630 CE | Mecca | **50** |
| 113 | j_m3_113 | Bilal Calls Adhan from the Kaaba | بلال يؤذن فوق الكعبة | 630 CE | Mecca | **40** |
| 114 | j_m3_114 | Battle of Hunayn — The Ambush | غزوة حنين — الكمين | 630 CE | Hunayn | **50** |
| 115 | j_m3_115 | The Turning Point — Muslims Rally | الانتفاضة — عودة المسلمين | 630 CE | Hunayn | **40** |
| 116 | j_m3_116 | Siege of Ta'if | حصار الطائف | 630 CE | Ta'if | 25 |
| 117 | j_m3_117 | Division of Hunayn Spoils | تقسيم غنائم حنين | 630 CE | Ji'ranah | 25 |
| 118 | j_m3_118 | Umrah from Ji'ranah | عمرة الجعرانة | 630 CE | Mecca | 25 |
| 119 | j_m3_119 | Ta'if Accepts Islam | الطائف تدخل الإسلام | 631 CE | Ta'if | 25 |
| 120 | j_m3_120 | The Arabian Peninsula Transforms | الجزيرة العربية تتغير | 630 CE | Arabia | 30 |

**M3 Total XP:** ~1,390 XP

---

### MILESTONE 4 — The Final Chapter (630–632 CE)
**35 events | Global Orders 121–155**

#### Era: Medina — Final Period (المدينة — الفصل الأخير) — Events 121–155

| # | ID | Title (EN) | Title (AR) | Year | Location | XP |
|---|---|---|---|---|---|---|
| 121 | j_m4_121 | Call to Tabuk — The Hard March | الدعوة إلى تبوك — الساعة العسرة | 630 CE | Medina | 25 |
| 122 | j_m4_122 | The Hypocrites' Excuses | أعذار المنافقين | 630 CE | Medina | 25 |
| 123 | j_m4_123 | Abu Khaythamah — The Race to Catch Up | أبو خيثمة يلحق بالجيش | 630 CE | Desert | 30 |
| 124 | j_m4_124 | Battle of Tabuk — Bloodless Victory | غزوة تبوك — الانتصار بلا قتال | 630 CE | Tabuk | **50** |
| 125 | j_m4_125 | Destruction of Masjid al-Dirar | هدم مسجد الضرار | 630 CE | Medina | 25 |
| 126 | j_m4_126 | The Three Who Stayed Behind | الثلاثة الذين خلفوا | 630 CE | Medina | **40** |
| 127 | j_m4_127 | The Repentance of the Three | توبة الثلاثة قُبلت | 630 CE | Medina | **40** |
| 128 | j_m4_128 | Death of Abdullah ibn Ubayy | وفاة رأس النفاق | 630 CE | Medina | 25 |
| 129 | j_m4_129 | Year of Delegations Begins | عام الوفود | 631 CE | Medina | 25 |
| 130 | j_m4_130 | Delegation of Banu Tamim | وفد بني تميم | 631 CE | Medina | 20 |
| 131 | j_m4_131 | Delegation of Thaqif — Ta'if Submits | وفد ثقيف | 631 CE | Medina | 25 |
| 132 | j_m4_132 | Delegation of Najrani Christians — Mubahala | وفد نجران — المباهلة | 631 CE | Medina | **40** |
| 133 | j_m4_133 | Abu Bakr Leads the First Hajj | أبو بكر يقود أول حج | 631 CE | Mecca | 30 |
| 134 | j_m4_134 | Ali Proclaims Surah Al-Tawbah | علي يبلّغ سورة التوبة | 631 CE | Mecca | 25 |
| 135 | j_m4_135 | Arabia Enters Islam | الجزيرة كلها تدخل في الإسلام | 631 CE | Arabia | 30 |
| 136 | j_m4_136 | Preparations for the Farewell Pilgrimage | التحضير لحجة الوداع | 632 CE | Medina | 25 |
| 137 | j_m4_137 | The Great Procession — 100,000 Depart | الخروج العظيم — مائة ألف | 632 CE | Medina | 30 |
| 138 | j_m4_138 | Entry into Mecca — The Talbiyah Rises | دخول مكة — لبيك اللهم لبيك | 632 CE | Mecca | 30 |
| 139 | j_m4_139 | The Day of Arafah | يوم عرفة — اليوم الأعظم | 632 CE | Arafah | **60** |
| 140 | j_m4_140 | The Farewell Sermon | خطبة الوداع | 632 CE | Arafah | **60** |
| 141 | j_m4_141 | "Today I Have Perfected Your Religion" | اليومَ أكملتُ لكم دينكم | 632 CE | Arafah | **60** |
| 142 | j_m4_142 | The Rituals Completed — Ghadir Khumm | إتمام المناسك — غدير خم | 632 CE | Ghadir Khumm | **40** |
| 143 | j_m4_143 | Return to Medina | العودة إلى المدينة | 632 CE | Medina | 25 |
| 144 | j_m4_144 | Usama's Expedition Ordered | تجهيز جيش أسامة | 632 CE | Medina | 25 |
| 145 | j_m4_145 | The Illness Begins | بداية المرض الشريف | 632 CE | Medina | 25 |
| 146 | j_m4_146 | Visiting the Graves of Uhud | زيارة شهداء أحد — الوداع الأخير | 632 CE | Uhud | **40** |
| 147 | j_m4_147 | Abu Bakr Leads the Prayer | أبو بكر يؤم المصلين | 632 CE | Medina | 30 |
| 148 | j_m4_148 | The Final Appearance in the Mosque | آخر ظهور في المسجد | 632 CE | Medina | **40** |
| 149 | j_m4_149 | The Final Days — The Curtain Parts | الأيام الأخيرة — ما وراء الستارة | 632 CE | Medina | 30 |
| 150 | j_m4_150 | The Departure — 12 Rabi al-Awwal | الوفاة الشريفة — ١٢ ربيع الأول | 632 CE | Medina | **60** |
| 151 | j_m4_151 | The Moment After — Umar's Grief | اللحظة التي تلت — حزن عمر | 632 CE | Medina | 30 |
| 152 | j_m4_152 | Abu Bakr's Address — "Whoever Worshipped Muhammad..." | خطاب أبي بكر الصديق | 632 CE | Medina | **50** |
| 153 | j_m4_153 | The Funeral Prayer — The Ummah Prays Alone | صلاة الجنازة — الأمة تصلي وحدها | 632 CE | Medina | 30 |
| 154 | j_m4_154 | The Burial — In the House of Aisha RA | الدفن في حجرة عائشة رضي الله عنها | 632 CE | Medina | 30 |
| 155 | j_m4_155 | The Story Continues — You Are the Rawi | الرواية تكمل — أنتَ الراوي | 632 CE | — | **60** |

**M4 Total XP:** ~1,320 XP

---

## 9. XP Summary

| Milestone | Events | Total XP | Avg XP/Event |
|---|---|---|---|
| M1 | 47 | ~1,455 | ~31 |
| M2 | 35 | ~1,110 | ~32 |
| M3 | 38 | ~1,390 | ~37 |
| M4 | 35 | ~1,320 | ~38 |
| **Grand Total** | **155** | **~5,275** | **~34** |

---

## 10. Era Distribution

| Era (JourneyEra) | Events | Global Orders |
|---|---|---|
| jahiliyyah | 3 | 1–3 |
| earlyLife | 11 | 4–14 |
| mecca | 33 | 15–47 |
| medina | 108 | 48–155 |

> Note: The Medinan era is by far the largest. Future versions may split it into sub-eras (Early Medina, Consolidation, Final Chapter) for UI display purposes, but the JourneyEra enum currently groups all under `medina`. Consider adding `medinaEarly`, `medinaConsolidation`, `medinaFinal` sub-eras in a future data model update.

---

## 11. Content Production Plan

### Current State (2026-04-02)
- **Dart code:** 41 files, ~11,000 lines
- **M1 data:** 36 events in `m1_data.dart`, Events 1-3 with branching
- **Scene configs:** 3 complete (Events 1-3) with alt paths for branching
- **Branching system:** Gate → Crossroads → Paths → Gathering → Verdict
- **Images:** 16 scene/bubble JPGs, 4 companion figures, 1 app icon
- **Audio:** 150 files (14 WAV SFX + 84 VO MP3 + 52 companion MP3)
- **VO voices:** Syrian Arabic (`ar-SY-LaithNeural`/`AmanyNeural`) + British English (`en-GB-RyanNeural`/`SoniaNeural`)
- **Screens built:** Splash, intro cinematic, registration (4-step), event list (timeline), cinematic transition, immersive event (branching + linear), flat event, settings (page + overlay), era complete, tutorial
- **Event list:** Timeline journey view with chapter headers, gold thread, progress dots
- **Testing:** 3 rounds, 31+ bugs fixed, 5 branching safety tests
- **Frameworks ready:** Go Deeper (content pending), Collections (metadata pending)

### MVP (v0.6) — See `MVP_PLAN.md`
3 fully playable branching events + complete gaming UX + VO + RTL

### Post-MVP Roadmap
1. Expand M1 to 47 events (11 more event data + scene configs)
2. M2 data — 35 events in `m2_data.dart`
3. M3 data — 38 events in `m3_data.dart`
4. M4 data — 35 events in `m4_data.dart`
5. Era-pack download system (audio not bundled in APK)

---

## 12. File Structure (Current — Post-Cleanup)

```
d:\Rawi_Journey\lib\
├── main.dart                              # App entry — Rawi brand
├── app_colors.dart                        # Style C palette
├── transitions.dart                       # Page transitions
├── models\
│   ├── journey_event.dart                 # JourneyEra, JourneyQuestion, JourneyEvent
│   └── scene_config.dart                  # SceneConfig, SceneHotspot, ParticleType
├── data\
│   ├── m1_data.dart                       # 36 events (target: 47)
│   └── scene_configs.dart                 # 2 scene configs (E1, E2)
├── services\
│   ├── audio_service.dart                 # 3-layer audio (ambient, VO, SFX)
│   └── prefs_service.dart                 # Lang, XP, streak, progression
├── screens\
│   ├── welcome_screen.dart                # First-launch splash (to be replaced)
│   ├── aerial_hub_screen.dart             # Main hub
│   ├── immersive_event_screen.dart        # Full-screen cinematic exploration
│   ├── journey_event_screen.dart          # Flat fallback for events without scene config
│   ├── journey_quiz_screen.dart           # Standalone quiz (future use)
│   └── era_complete_screen.dart           # Era celebration
└── widgets\cinematic\
    ├── birds_overlay.dart                 # Animated bird swarm
    ├── companion_figure.dart              # Companion (to rewrite: image-based circle)
    ├── crescent_moon.dart                 # Moon with glow
    ├── discovery_panel.dart               # Hotspot fragment panel
    ├── discovery_progress.dart            # Progress dots
    ├── fly_transition.dart                # Zoom+fade transition (to replace)
    ├── grain_overlay.dart                 # Film grain
    ├── parallax_scene.dart                # Parallax layer viewer
    ├── particle_painter.dart              # Smoke/dust particles
    ├── path_route_painter.dart            # Walking route (gold → silver pending)
    ├── scene_hotspot_marker.dart          # Hotspot marker (circle → diamond pending)
    ├── sky_gradient.dart                  # Sky gradient
    ├── starfield_layer.dart               # Twinkling stars
    └── virtual_joystick.dart              # On-screen joystick

d:\Rawi_Journey\assets\
├── audio\          # 10 WAV (1 ambient + 9 SFX)
├── figures\        # companion_male.jpg, companion_female.jpg
├── icon\           # app_icon.jpg
└── scenes\         # 17 JPG (3 scenes + 13 bubbles + 1 welcome)
```

**Deleted 2026-04-01:** `journey_map_screen.dart`, `companion_marker.dart`, `hotspot_marker.dart`, `narrative_overlay.dart`, 4 legacy images, `assets/panoramas/`, `assets/textures/`

---

## 13. Decisions Log

| # | Decision | Choice | Date |
|---|----------|--------|------|
| 1 | App package name | `com.rawi.journey` | 2026-04-01 |
| 2 | Path route color | Silver `#B8C4CC` | 2026-04-01 |
| 3 | Event transition style | Fade-to-black + title card | 2026-04-01 |
| 4 | TTS voices | Jordanian + gender-aware (Edge TTS) | 2026-04-01 |
| 5 | App icon | Concept C — bilingual wordmark | 2026-04-01 |
| 6 | Companion figure | Image-based in circle (not CustomPainter) | 2026-04-01 |

### Still Pending
1. **App store name:** "Rawi" only, or "Rawi: The Seerah"?
2. **Era sub-division for UI:** Split Medina into sub-eras?
3. **Scholarly review:** Who reviews content before publishing?

---

*"Witness history. Carry the story."*
*رواي — كن شاهداً. احمل الرواية.*
