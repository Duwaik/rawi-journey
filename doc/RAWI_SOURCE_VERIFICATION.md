# RawiJourney — Source Verification & In-App References

---

## Part 1: In-App Source Display (Implementation Spec)

### Concept

Every piece of content in the app carries its source reference.
Users (especially parents, teachers, scholars) can see exactly
where each fact comes from. This builds trust and educational value.

No other Seerah app does this.

### Where Sources Appear

**1. Hotspot card — bottom of fragment:**
Small muted text, one line: `📖 Al-Raheeq Al-Makhtum, Ch. 3`

**2. Verdict explanation — after "The Rawi reflects...":**
`📖 Sahih Bukhari, #3 | Quran 96:1-5`

**3. "Did You Know?" card — below the fact:**
`📖 Sahih Muslim, #2699`

**4. "Go Deeper" section (Phase 2) — full citations list**

### Display Rules
- Small muted text (#8A9BB0), not gold — never interrupts narrative
- Abbreviated on hotspot cards, full in "Go Deeper"
- Arabic version uses Arabic book names, same reference numbers

### Data Model Addition

```dart
// Add to SceneHotspot
final String? sourceRef;    // "Al-Raheeq Al-Makhtum, Ch. 3"
final String? sourceRefAr;  // "الرحيق المختوم، الفصل ٣"

// Add to JourneyQuestion
final String? sourceRef;
final String? sourceRefAr;

// JourneyEvent already has 'source' — add Arabic
final String? sourceRefAr;
```

### Critical Rule
**Write the source reference AT THE SAME TIME as the content.**
Do not plan to "add sources later." Retrofitting 155 events × 4
hotspots = 620 lookups. Writing it live = 0 extra work.

**Implementation effort:** ~1 sprint (model + UI). Zero extra if
sources are captured during content writing.

---

## Part 2: Source Hierarchy (From Master Plan)

| Tier | Sources | Usage |
|------|---------|-------|
| Tier 1 | القرآن الكريم | Exact, never paraphrased |
| Tier 2 | Sahih Bukhari + Sahih Muslim + Four Sunan | All hadith citations |
| Tier 3 | الرحيق المختوم + سيرة ابن هشام + البداية والنهاية | Narrative, chronology |

**Prohibited:** Isra'iliyyat, Bahira incident, unverified chains,
speculative dialogue without hadith source.

**Rule:** If it's not in Al-Raheeq Al-Makhtum, it doesn't go in the app.

### Abbreviations
- **RM** = Al-Raheeq Al-Makhtum (الرحيق المختوم)
- **SB** = Sahih Bukhari (صحيح البخاري)
- **SM** = Sahih Muslim (صحيح مسلم)
- **IH** = Seerah Ibn Hisham (سيرة ابن هشام)
- **BN** = Al-Bidayah wal-Nihayah (البداية والنهاية)

---

## Part 3: Verification Table (155 Events)

### M1 — The Prophetic Dawn (47 events)

| # | Event | RM Ch. | Hadith | Quran | Status |
|---|-------|--------|--------|-------|--------|
| 1 | Arabia Before the Light | Ch. 1-2 | — | — | ✅ |
| 2 | Year of the Elephant | Ch. 5 | — | 105:1-5 | ✅ |
| 3 | Birth of the Prophet ﷺ | Ch. 5 | — | — | ✅ |
| 4 | Nursing Years — Halimah | Ch. 5 | — | — | ⬜ verify detail |
| 5 | Opening of the Chest | Ch. 5 | SM #162 | — | ⬜ KEEP or REMOVE? |
| 6 | Death of Aminah | Ch. 5 | — | — | ⬜ verify detail |
| 7 | Care of Abd al-Muttalib | Ch. 5 | — | — | ✅ |
| 8 | Guardian: Abu Talib | Ch. 5-6 | — | — | ✅ |
| 9 | Hilf al-Fudul | Ch. 6 | — | — | ✅ |
| 10 | Al-Amin — The Trustworthy | Ch. 6 | — | — | ⬜ standalone or merge? |
| 11 | Marriage to Khadijah | Ch. 6 | — | — | ✅ |
| 12 | The Black Stone | Ch. 6 | SB | — | ✅ |
| 13 | Cave Hira | Ch. 7 | SB #3 | — | ✅ |
| 14 | The First Revelation | Ch. 7 | SB #3 | 96:1-5 | ✅ |
| 15 | The First Believers | Ch. 8 | — | — | ✅ |
| 16 | Secret Preaching | Ch. 8 | — | — | ✅ |
| 17 | Call Goes Public — Safa | Ch. 9 | SB #4971 | 26:214 | ✅ |
| 18 | Quraysh React | Ch. 9 | — | — | ✅ |
| 19 | Torture of the Weak | Ch. 9 | SB (Bilal) | — | ✅ |
| 20 | First Migration to Abyssinia | Ch. 10 | — | — | ✅ |
| 21 | Quraysh Delegation to Negus | Ch. 10 | — | — | ✅ |
| 22 | Negus Protects Muslims | Ch. 10 | — | 19:16-33 | ✅ |
| 23 | Hamza Accepts Islam | Ch. 10 | — | — | ✅ |
| 24 | Umar Accepts Islam | Ch. 10 | — | 20:1-8 | ✅ |
| 25 | Second Migration to Abyssinia | Ch. 10 | — | — | ⬜ verify detail |
| 26 | Boycott Begins | Ch. 11 | — | — | ✅ |
| 27 | Three Years of Siege | Ch. 11 | — | — | ✅ |
| 28 | Boycott Ends | Ch. 11 | — | — | ⬜ verify detail |
| 29 | Death of Khadijah | Ch. 12 | — | — | ✅ |
| 30 | Death of Abu Talib | Ch. 12 | — | 28:56 | ✅ |
| 31 | Journey to Ta'if | Ch. 12 | — | — | ✅ |
| 32 | Wadi Nakhlah | Ch. 12 | — | 72:1-2 | ⬜ standalone or merge? |
| 33 | Seeking Help from Tribes | Ch. 12 | — | — | ⬜ standalone or merge? |
| 34 | Al-Isra' wal-Mi'raj | Ch. 13 | SB #3887 | 17:1, 53:1-18 | ✅ |
| 35 | Abu Bakr Believes | Ch. 13 | — | — | ⬜ standalone or merge? |
| 36 | First Pledge of Aqabah | Ch. 14 | — | — | ✅ |
| 37 | Mus'ab Sent to Medina | Ch. 14 | — | — | ⬜ verify detail |
| 38 | Second Pledge of Aqabah | Ch. 14 | — | — | ✅ |
| 39 | Plot to Kill the Prophet ﷺ | Ch. 15 | — | 8:30 | ✅ |
| 40 | Night of Hijrah — Ali in Bed | Ch. 15 | — | — | ✅ |
| 41 | Suraqa ibn Malik | Ch. 15 | SB #3906 | — | ✅ |
| 42 | Three Days in Cave Thawr | Ch. 15 | SB #3922 | 9:40 | ✅ |
| 43 | Desert Journey to Medina | Ch. 15 | — | — | ⬜ verify detail |
| 44 | Arrival in Quba | Ch. 15-16 | — | — | ✅ |
| 45 | Masjid Quba — First Mosque | Ch. 16 | — | 9:108 | ✅ |
| 46 | First Friday Prayer | Ch. 16 | — | — | ⬜ verify detail |
| 47 | Entry into Medina | Ch. 16 | — | — | ✅ |

### M2 — The Community Rises (35 events)

| # | Event | RM Ch. | Hadith | Quran | Status |
|---|-------|--------|--------|-------|--------|
| 48 | Building the Mosque | Ch. 16 | — | — | ✅ |
| 49 | Brotherhood — Muakhah | Ch. 16 | — | — | ✅ |
| 50 | Constitution of Medina | Ch. 16 | — | — | ✅ |
| 51 | The Adhan | Ch. 16 | SB #604 | — | ✅ |
| 52 | Change of Qibla | Ch. 16 | SB #4486 | 2:144 | ✅ |
| 53 | First Expeditions | Ch. 17 | — | — | ⬜ verify detail |
| 54 | Abdullah ibn Jahsh | Ch. 17 | — | 2:217 | ✅ |
| 55 | Road to Badr | Ch. 18 | — | — | ✅ |
| 56 | Badr — March to Well | Ch. 18 | — | — | ✅ |
| 57 | Badr — The Battle | Ch. 18 | SB #3953 | 3:123-125, 8:9-12 | ✅ |
| 58 | Angels of Badr | Ch. 18 | SM #1763 | 8:9 | ✅ |
| 59 | Prisoners of Badr | Ch. 18 | — | 8:67-69 | ✅ |
| 60 | Banu Qaynuqa | Ch. 19 | — | — | ✅ |
| 61 | Ka'b ibn al-Ashraf | Ch. 19 | SB #4037 | — | ✅ (frame carefully) |
| 62 | Uhud — Quraysh Return | Ch. 20 | — | — | ✅ |
| 63 | Uhud — March Out | Ch. 20 | — | — | ✅ |
| 64 | Uhud — The Battle | Ch. 20 | — | 3:121-129 | ✅ |
| 65 | Archers' Choice | Ch. 20 | SB #4043 | 3:152 | ✅ |
| 66 | Hamza's Martyrdom | Ch. 20 | — | — | ✅ |
| 67 | Hamra al-Asad | Ch. 20 | — | 3:172-174 | ⬜ verify detail |
| 68 | Raji' | Ch. 21 | SB #3045 | — | ✅ |
| 69 | Bi'r Ma'una | Ch. 21 | SB #4088 | — | ✅ |
| 70 | Banu Nadir | Ch. 21 | — | 59:2-5 | ✅ |
| 71 | Badr al-Maw'id | Ch. 21 | — | — | ⬜ standalone or merge? |
| 72 | Banu Mustaliq | Ch. 22 | — | — | ✅ |
| 73 | The Slander — Al-Ifk | Ch. 22 | SB #4141 | 24:11-20 | ✅ |
| 74 | Digging the Trench | Ch. 23 | — | — | ✅ |
| 75 | Trench — Siege | Ch. 23 | — | 33:9-27 | ✅ |
| 76 | Nu'aym ibn Mas'ud | Ch. 23 | — | — | ✅ |
| 77 | Amr ibn Abd Wudd Duel | Ch. 23 | — | — | ⬜ verify details |
| 78 | Wind of Victory | Ch. 23 | — | 33:9 | ✅ |
| 79 | Banu Qurayza Siege | Ch. 23 | — | 33:26-27 | ✅ |
| 80 | Judgment of Sa'd | Ch. 23 | SB #4121 | — | ✅ |
| 81 | Sa'd — Martyrdom | Ch. 23 | — | — | ✅ |
| 82 | Throne Shook | Ch. 23 | SB #3803, SM #2466 | — | ✅ |

### M3 — The Turning Tide (38 events)

| # | Event | RM Ch. | Hadith | Quran | Status |
|---|-------|--------|--------|-------|--------|
| 83 | Post-Khandaq Expeditions | Ch. 24 | — | — | ⬜ standalone or merge? |
| 84 | Journey to Hudaybiyyah | Ch. 25 | — | — | ✅ |
| 85 | She-Camel Kneels | Ch. 25 | — | — | ✅ |
| 86 | Bay'at al-Ridwan | Ch. 25 | — | 48:18 | ✅ |
| 87 | Treaty of Hudaybiyyah | Ch. 25 | SB #2731 | — | ✅ |
| 88 | Surah Al-Fath | Ch. 25 | — | 48:1-3 | ✅ |
| 89 | Letter to Heraclius | Ch. 26 | SB #7 | — | ✅ |
| 90 | Letter to Chosroes | Ch. 26 | — | — | ✅ |
| 91 | Letter to Negus | Ch. 26 | — | — | ✅ |
| 92 | Letter to Muqawqis | Ch. 26 | — | — | ✅ |
| 93 | March to Khaybar | Ch. 27 | — | — | ✅ |
| 94 | Battle of Khaybar | Ch. 27 | SB #4210 | — | ✅ |
| 95 | Ali — Gate of Khaybar | Ch. 27 | SM #2405 | — | ✅ |
| 96 | Poisoned Lamb | Ch. 27 | SB #4249 | — | ✅ (factual only) |
| 97 | Abyssinian Emigrants Return | Ch. 27 | — | — | ⬜ verify detail |
| 98 | Umrat al-Qada | Ch. 28 | — | — | ✅ |
| 99 | Khalid Accepts Islam | Ch. 28 | — | — | ✅ |
| 100 | Amr Accepts Islam | Ch. 28 | — | — | ✅ |
| 101 | Mu'tah | Ch. 29 | — | — | ✅ |
| 102 | Three Commanders Fall | Ch. 29 | SB #4262 | — | ✅ |
| 103 | Khalid Takes Command | Ch. 29 | — | — | ✅ |
| 104 | Dhat al-Salasil | Ch. 29 | — | — | ⬜ standalone or merge? |
| 105 | Quraysh Breaks Treaty | Ch. 30 | — | — | ✅ |
| 106 | Abu Sufyan's Journey | Ch. 30 | — | — | ✅ |
| 107 | Secret March | Ch. 30 | — | — | ✅ |
| 108 | Abu Sufyan Witnesses Army | Ch. 30 | — | — | ✅ |
| 109 | Abu Sufyan Accepts Islam | Ch. 30 | — | — | ✅ |
| 110 | Conquest of Mecca | Ch. 30 | SB #4280 | 110:1-3 | ✅ |
| 111 | Cleansing the Kaaba | Ch. 30 | SB #4288 | 17:81 | ✅ |
| 112 | General Amnesty | Ch. 30 | — | — | ✅ |
| 113 | Bilal's Adhan | Ch. 30 | — | — | ✅ |
| 114 | Hunayn — Ambush | Ch. 31 | — | 9:25-26 | ✅ |
| 115 | Muslims Rally | Ch. 31 | — | 9:26 | ✅ |
| 116 | Siege of Ta'if | Ch. 31 | — | — | ✅ |
| 117 | Hunayn Spoils | Ch. 31 | — | — | ✅ |
| 118 | Umrah Ji'ranah | Ch. 31 | — | — | ✅ |
| 119 | Ta'if Accepts Islam | Ch. 32 | — | — | ✅ |
| 120 | Peninsula Transforms | Ch. 32 | — | 110:1-3 | ✅ |

### M4 — The Final Chapter (35 events)

| # | Event | RM Ch. | Hadith | Quran | Status |
|---|-------|--------|--------|-------|--------|
| 121 | Call to Tabuk | Ch. 33 | — | 9:38-39 | ✅ |
| 122 | Hypocrites' Excuses | Ch. 33 | — | 9:43-48 | ✅ |
| 123 | Abu Khaythamah | Ch. 33 | — | — | ⬜ verify detail |
| 124 | Tabuk — Bloodless Victory | Ch. 33 | — | — | ✅ |
| 125 | Masjid al-Dirar | Ch. 33 | — | 9:107-108 | ✅ |
| 126 | Three Who Stayed | Ch. 33 | SB #4418 | 9:118 | ✅ |
| 127 | Repentance of Three | Ch. 33 | SB #4418 | 9:118 | ✅ |
| 128 | Death of Ibn Ubayy | Ch. 33 | SB #1269 | — | ⬜ verify detail |
| 129 | Delegations Begin | Ch. 34 | — | — | ✅ |
| 130 | Banu Tamim | Ch. 34 | — | 49:1-5 | ⬜ verify detail |
| 131 | Thaqif | Ch. 34 | — | — | ✅ |
| 132 | Najran — Mubahala | Ch. 34 | — | 3:61 | ✅ |
| 133 | Abu Bakr Leads Hajj | Ch. 35 | — | — | ✅ |
| 134 | Ali Proclaims Tawbah | Ch. 35 | — | 9:1-5 | ✅ |
| 135 | Arabia Enters Islam | Ch. 35 | — | 110:1-3 | ✅ |
| 136 | Farewell Preparations | Ch. 36 | — | — | ✅ |
| 137 | Great Procession | Ch. 36 | — | — | ✅ |
| 138 | Entry — Talbiyah | Ch. 36 | SM #1218 | — | ✅ |
| 139 | Day of Arafah | Ch. 36 | SM #1218 | — | ✅ |
| 140 | Farewell Sermon | Ch. 36 | SB #1739 | — | ✅ |
| 141 | "Perfected Your Religion" | Ch. 36 | SB #45 | 5:3 | ✅ |
| 142 | Ghadir Khumm | Ch. 36 | SM #2408 | — | ✅ (factual, no interpretation) |
| 143 | Return to Medina | Ch. 36 | — | — | ✅ |
| 144 | Usama's Expedition | Ch. 37 | — | — | ✅ |
| 145 | Illness Begins | Ch. 37 | SB #4442 | — | ✅ |
| 146 | Visiting Uhud Graves | Ch. 37 | SM #974 | — | ✅ |
| 147 | Abu Bakr Leads Prayer | Ch. 37 | SB #713 | — | ✅ |
| 148 | Final Appearance | Ch. 37 | SB #681 | — | ✅ |
| 149 | The Final Days | Ch. 37 | — | — | ✅ |
| 150 | The Departure | Ch. 37 | SB #4449 | — | ✅ |
| 151 | Umar's Grief | Ch. 37 | SB #3668 | — | ✅ |
| 152 | Abu Bakr's Address | Ch. 37 | SB #3668 | 3:144 | ✅ |
| 153 | Funeral Prayer | Ch. 37 | — | — | ✅ |
| 154 | The Burial | Ch. 37 | — | — | ✅ |
| 155 | You Are the Rawi | — | — | — | ✅ (narrative closing) |

---

## Part 4: Verification Workflow (Locked)

**Decision: Verify each event at the moment of writing, not upfront.**

When writing any event's content:
1. Search IslamWeb for the event's primary sources
2. Confirm it exists in Al-Raheeq Al-Makhtum
3. Note the specific hadith/Quran references
4. Write the source reference alongside the content
5. If an event is too thin → merge with adjacent event and
   renumber only the events AFTER it

**Pre-verified:**
- [x] #5 — Opening of the Chest: ✅ KEEP (Sahih Muslim #162)
- [x] #4 — Nursing Years — Halimah: ✅ KEEP (all Seerah books)
- [x] #6 — Death of Aminah: ✅ KEEP (Ibn Hisham, Al-Bidayah)

**Remaining 17 items resolved during content writing:**
#10, #25, #28, #32, #33, #35, #37, #43, #46, #53, #67, #71,
#77, #83, #97, #104, #123, #128, #130

These are not source-authentication concerns — they are
detail-level questions (standalone vs merge) that get answered
naturally when writing the content for that event.
