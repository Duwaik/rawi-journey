# RawiJourney — Seerah Event Sequence Review

> **Date:** April 3, 2026
> **Purpose:** Full chronological audit of all Seerah events against
> authenticated sources (Al-Raheeq Al-Makhtum, Sirah Ibn Hisham,
> Al-Bidaya wal-Nihaya, Sahih Bukhari, Sahih Muslim)
> **For:** Khaled + Claude Code agent — this is the single source of
> truth for event order. No event may be added, removed, or reordered
> without updating this document.

---

## Part 1 — Errors Found in Current Code (m1_data.dart, 36 events)

### ERROR 1: Event 3 — Black Stone Arbitration (605 CE) before Birth (570 CE)

**Current position:** Event 3 (Chapter: Jahiliyyah)
**Current sequence:** Arabia 500 CE → Elephant 570 CE → **Black Stone 605 CE** → Birth 570 CE

**Problem:** The Ka'bah rebuilding and Black Stone arbitration happened
when the Prophet ﷺ was 35 years old (605 CE). This is 10 years after
his marriage to Khadijah (595 CE) and 5 years before the First
Revelation (610 CE). Placing it before his birth creates a 35-year
backward jump in the timeline.

**Sources confirming 605 CE:**
- Ibn Ishaq / Ibn Hisham: "When Quraysh decided to rebuild the Ka'bah...
  Muhammad was 35 years old"
- Al-Raheeq Al-Makhtum (Chapter: Rebuilding of the Ka'bah): 605 CE
- Sahih al-Bukhari confirms participation in the rebuilding

**Correct position:** After Marriage to Khadijah (595 CE), before
Solitude in Cave Hira (605–610 CE). In the current 36-event structure,
this means Event 3 should move to after current Event 8.

### ERROR 2: Event 22 — Journey to Ta'if (619 CE) after Cave Thawr (622 CE)

**Current position:** Event 22 (Chapter: Mecca)
**Current sequence:** ...Plot to Kill 622 CE → Cave Thawr 622 CE →
**Ta'if 619 CE** → Arrival in Medina 622 CE

**Problem:** The Journey to Ta'if happened immediately after the Year
of Grief (619 CE), when the Prophet ﷺ lost both Khadijah and Abu Talib.
He went to Ta'if seeking support and was rejected. Al-Isra' wal-Mi'raj
(620 CE) came after as consolation. The current code places Ta'if
AFTER the Hijrah events (622 CE) — a 3-year backward jump.

**Sources confirming 619 CE:**
- Al-Raheeq Al-Makhtum: Ta'if journey in Shawwal, 10th year of
  Prophethood (619 CE), immediately after Abu Talib's death
- Ibn Hisham: Places Ta'if between Year of Grief and Al-Isra'
- Ibn Kathir (Al-Bidaya wal-Nihaya): Same chronology

**Correct position:** Immediately after Year of Grief (Event 16),
before Al-Isra' wal-Mi'raj (Event 17).

---

## Part 2 — Corrected 36-Event Sequence (for m1_data.dart)

This is the corrected order. Changes marked with ⚠️.

### Chapter 1 — Jahiliyyah (Pre-Islamic Arabia)

| # | Title (EN) | Title (AR) | Year | Notes |
|---|-----------|-----------|------|-------|
| 1 | Arabia Before the Light | الجزيرة العربية قبل النور | 500 CE | Scene-setting ✓ |
| 2 | The Year of the Elephant | عام الفيل | 570 CE | ✓ |

⚠️ **Event 3 (Black Stone) REMOVED from this chapter — moved to Early Life.**
Jahiliyyah now has 2 events, not 3. Both are pre-birth scene-setting.

### Chapter 2 — Early Life (النشأة)

| # | Title (EN) | Title (AR) | Year | Notes |
|---|-----------|-----------|------|-------|
| 3 | The Birth of the Prophet ﷺ | مولد النبي ﷺ | 570 CE | Was Event 4 |
| 4 | Under the Care of Abd al-Muttalib | في كنف عبد المطلب | 575 CE | Was Event 5 |
| 5 | The Guardian: Abu Talib | الكافل: أبو طالب | 578 CE | Was Event 6 |
| 6 | Hilf al-Fudul — The Pact of the Virtuous | حلف الفضول | 590 CE | Was Event 7 |
| 7 | Marriage to Khadijah RA | الزواج من خديجة رضي الله عنها | 595 CE | Was Event 8 |
| 8 | The Black Stone — A Wise Arbitration | الحجر الأسود — حكمة التحكيم | 605 CE | ⚠️ MOVED here from Event 3 |
| 9 | Solitude in Cave Hira | الخلوة في غار حراء | 605 CE | Was Event 9 |
| 10 | The First Revelation | نزول الوحي | 610 CE | Was Event 10 |
| 11 | The First Believers | أوائل المؤمنين | 610 CE | Was Event 11 |

### Chapter 3 — Mecca (العهد المكي)

| # | Title (EN) | Title (AR) | Year | Notes |
|---|-----------|-----------|------|-------|
| 12 | The Call Goes Public | الدعوة العلنية | 613 CE | Was Event 12 ✓ |
| 13 | Persecution Begins | بداية الاضطهاد | 614 CE | Was Event 13 ✓ |
| 14 | Migration to Abyssinia | الهجرة إلى الحبشة | 615 CE | Was Event 14 ✓ |
| 15 | The Boycott — Three Years of Siege | المقاطعة — حصار الشعب | 616 CE | Was Event 15 ✓ |
| 16 | Year of Grief — Khadijah and Abu Talib | عام الحزن | 619 CE | Was Event 16 ✓ |
| 17 | The Journey to Ta'if | رحلة الطائف — الرفض والثبات | 619 CE | ⚠️ MOVED here from Event 22 |
| 18 | Al-Isra' wal-Mi'raj — The Night Journey | الإسراء والمعراج | 620 CE | Was Event 17 |
| 19 | The Pledge of Aqabah — First | بيعة العقبة الأولى | 620 CE | Was Event 18 |
| 20 | The Second Pledge of Aqabah | بيعة العقبة الثانية | 621 CE | Was Event 19 |
| 21 | The Plot to Kill the Prophet ﷺ | مؤامرة الاغتيال | 622 CE | Was Event 20 |
| 22 | Cave Thawr — Three Days in Hiding | غار ثور | 622 CE | Was Event 21 |

### Chapter 4 — Medina (العهد المدني)

| # | Title (EN) | Title (AR) | Year | Notes |
|---|-----------|-----------|------|-------|
| 23 | Arrival in Medina — The Hijrah | الوصول إلى المدينة | 622 CE | ✓ |
| 24 | Building the Prophet's Mosque | بناء المسجد النبوي | 622 CE | ✓ |
| 25 | The Brotherhood — Muakhah | المؤاخاة | 622 CE | ✓ |
| 26 | The Battle of Badr | غزوة بدر | 624 CE | ✓ |
| 27 | The Battle of Uhud | غزوة أحد | 625 CE | ✓ |
| 28 | The Battle of the Trench | غزوة الخندق | 627 CE | ✓ |
| 29 | Treaty of Hudaybiyyah | صلح الحديبية | 628 CE | ✓ |
| 30 | Letters to the Kings | رسائل الملوك | 628 CE | ✓ |
| 31 | The Conquest of Mecca | فتح مكة | 630 CE | ✓ |
| 32 | The Battle of Hunayn | غزوة حنين | 630 CE | ✓ |
| 33 | The Expedition to Tabuk | غزوة تبوك | 630 CE | ✓ |
| 34 | Year of Delegations | عام الوفود | 631 CE | ✓ |
| 35 | The Farewell Pilgrimage | حجة الوداع | 632 CE | ✓ |
| 36 | The Final Illness and Departure | المرض الأخير والوفاة | 632 CE | ✓ |

---

## Part 3 — Impact on Existing Code

### What changes in m1_data.dart:
1. **Event 3 (Black Stone)** moves to position 8 (after Marriage, before Hira)
2. **Event 22 (Ta'if)** moves to position 17 (after Year of Grief, before Isra')
3. All `globalOrder` values must be renumbered to match the new sequence
4. Chapter/era assignments: Black Stone changes from `jahiliyyah` to `earlyLife`
5. Jahiliyyah chapter shrinks from 3 events to 2

### What changes in scene_configs.dart:
- Event IDs for Events 1–3 (`j_1_1_1`, `j_1_1_2`, `j_1_1_3`) have
  scene configs with branching. **The Black Stone event (j_1_1_3) moves
  to a new position** — its scene config, VO files, and branching data
  all travel with it. The ID can stay the same but `globalOrder` changes.

### What changes in branching content:
- Events 1 and 2 keep their branching (Jahiliyyah chapter, positions 1–2)
- Event 3 (Black Stone) keeps its branching but is now in Early Life
  at position 8. Its scene, VO, hotspots, and branch paths are unchanged —
  only the `globalOrder` and `era` fields change.

### What changes in PrefsService:
- `journey_completed_prefix_N` keys are tied to `globalOrder`. Users who
  have completed events in the old order will have stale keys. Since this
  is still in testing (not shipped), this is acceptable — add a note to
  clear test data after the reorder.

### What changes in badges:
- Badge trigger ranges (e.g., "Witness of the Dawn" for Events 1–3)
  need updating. Jahiliyyah is now Events 1–2. The Black Stone event
  is now part of Early Life.

---

## Part 4 — Master Plan (RAWI_MASTER_PLAN.md) Corrections

The Master Plan has the **same Black Stone error** at Event 3.
It must be corrected there too.

### Corrected M1 Event List (47 events)

#### Era: Jahiliyyah — Events 1–2 (was 1–3)

| # | Title (EN) | Title (AR) | Year | Location |
|---|-----------|-----------|------|----------|
| 1 | Arabia Before the Light | الجزيرة العربية قبل النور | 500 CE | Arabia |
| 2 | The Year of the Elephant | عام الفيل | 570 CE | Mecca |

#### Era: Early Life — Events 3–15 (was 4–14)

| # | Title (EN) | Title (AR) | Year | Location |
|---|-----------|-----------|------|----------|
| 3 | Birth of the Prophet ﷺ | مولد النبي ﷺ | 570 CE | Mecca |
| 4 | The Nursing Years — Halimah al-Sa'diyyah | سنوات الرضاعة مع حليمة السعدية | 570 CE | Banu Sa'd |
| 5 | The Opening of the Chest | شرح الصدر | 574 CE | Banu Sa'd |
| 6 | Return to Mecca — Death of Aminah | العودة إلى مكة — وفاة آمنة | 576 CE | Abwa |
| 7 | Under the Care of Abd al-Muttalib | في كنف عبد المطلب | 576 CE | Mecca |
| 8 | The Guardian: Abu Talib | في كنف أبي طالب | 578 CE | Mecca |
| 9 | Hilf al-Fudul — The Pact of the Virtuous | حلف الفضول | 590 CE | Mecca |
| 10 | Al-Amin — The Trustworthy | الأمين | 595 CE | Mecca |
| 11 | Marriage to Khadijah RA | الزواج من خديجة رضي الله عنها | 595 CE | Mecca |
| 12 | The Black Stone — A Wise Arbitration | الحجر الأسود — حكمة التحكيم | 605 CE | Mecca |
| 13 | Solitude in Cave Hira | الخلوة في غار حراء | 610 CE | Mecca |
| 14 | The First Revelation — اقرأ | أول الوحي — اقرأ | 610 CE | Cave Hira |

⚠️ Black Stone moved from Jahiliyyah Event 3 → Early Life Event 12.
Early Life now has 12 events (was 11).

#### Era: Mecca — Events 15–47 (was 15–47, renumbered)

No changes to the internal order of the Mecca era events. The only
change is that all globalOrder values shift by -1 because Jahiliyyah
lost one event and Early Life gained one. The total is still 47.

| # | Title (EN) | Title (AR) | Year | Location |
|---|-----------|-----------|------|----------|
| 15 | The First Believers | أوائل المؤمنين | 610 CE | Mecca |
| 16 | Three Years of Secret Preaching | ثلاث سنوات من الدعوة السرية | 610 CE | Mecca |
| 17 | The Call Goes Public — Mount Safa | الإعلان على الملأ — جبل الصفا | 613 CE | Mecca |
| 18 | Quraysh React — First Persecution | ردة فعل قريش — بداية الأذى | 614 CE | Mecca |
| 19 | The Torture of the Weak | تعذيب المستضعفين | 614 CE | Mecca |
| 20 | First Migration to Abyssinia | الهجرة الأولى إلى الحبشة | 615 CE | Axum |
| 21 | The Quraysh Delegation to the Negus | وفد قريش إلى النجاشي | 615 CE | Axum |
| 22 | The Negus Protects the Muslims | النجاشي يحمي المسلمين | 615 CE | Axum |
| 23 | Hamza Accepts Islam | إسلام حمزة رضي الله عنه | 615 CE | Mecca |
| 24 | Umar Accepts Islam | إسلام عمر رضي الله عنه | 616 CE | Mecca |
| 25 | Second Migration to Abyssinia | الهجرة الثانية إلى الحبشة | 616 CE | Axum |
| 26 | The Boycott Begins | بداية الحصار في الشعب | 616 CE | Shi'b Abi Talib |
| 27 | Three Years of Siege | ثلاث سنوات في الشعب | 616 CE | Shi'b Abi Talib |
| 28 | The Boycott Ends | انتهاء الحصار | 619 CE | Mecca |
| 29 | Year of Grief — Death of Khadijah RA | عام الحزن — وفاة خديجة | 619 CE | Mecca |
| 30 | Year of Grief — Death of Abu Talib | عام الحزن — وفاة أبي طالب | 619 CE | Mecca |
| 31 | Journey to Ta'if — Rejection & Resilience | رحلة الطائف — الرفض والثبات | 619 CE | Ta'if |
| 32 | The Return — Wadi Nakhlah | العودة — وادي نخلة | 619 CE | Wadi Nakhlah |
| 33 | Seeking Help from the Tribes | طلب النصرة من القبائل | 619 CE | Various |
| 34 | Al-Isra wal-Mi'raj | الإسراء والمعراج | 620 CE | Jerusalem / Heavens |
| 35 | Abu Bakr Believes Without Hesitation | أبو بكر يصدّق بلا تردد | 620 CE | Mecca |
| 36 | The First Pledge of Aqabah | بيعة العقبة الأولى | 620 CE | Mina |
| 37 | Mus'ab ibn Umayr Sent to Medina | إرسال مصعب بن عمير إلى المدينة | 620 CE | Medina |
| 38 | The Second Pledge of Aqabah | بيعة العقبة الثانية | 621 CE | Mina |
| 39 | The Plot to Kill the Prophet ﷺ | مؤامرة الاغتيال | 622 CE | Mecca |
| 40 | The Night of the Hijrah — Ali in the Bed | ليلة الهجرة — علي في الفراش | 622 CE | Mecca |
| 41 | Suraqa ibn Malik — The Pursuit | سراقة بن مالك — المطاردة | 622 CE | Desert |
| 42 | Three Days in Cave Thawr | ثلاثة أيام في غار ثور | 622 CE | Cave Thawr |
| 43 | The Desert Journey to Medina | رحلة الهجرة في الصحراء | 622 CE | Desert route |
| 44 | Arrival in Quba | الوصول إلى قباء | 622 CE | Quba |
| 45 | Masjid Quba — First Mosque in Islam | مسجد قباء — أول مسجد في الإسلام | 622 CE | Quba |
| 46 | The First Friday Prayer | أول صلاة جمعة | 622 CE | Wadi Ranuna |
| 47 | Entry into Medina — The City Rejoices | الدخول إلى المدينة — الفرحة العارمة | 622 CE | Medina |

**M1 total: 47 events (unchanged). Ta'if was already correctly placed
in the Master Plan at Event 31 — the error was only in the condensed
36-event code version.**

---

## Part 5 — M2, M3, M4 Chronological Verification

M2 (Events 48–82), M3 (Events 83–120), and M4 (Events 121–155) were
reviewed against Al-Raheeq Al-Makhtum's chronological chapter order.

### M2 — The Community Rises (622–627 CE): ✓ CORRECT
All 35 events are in correct chronological order. Key sequence verified:
- Building Mosque → Brotherhood → Constitution → Adhan → Qibla change
- Badr sequence (road → battle → angels → prisoners) ✓
- Banu Qaynuqa after Badr ✓
- Uhud sequence (Quraysh return → march → battle → archers → Hamza) ✓
- Raji' and Bi'r Ma'una after Uhud ✓
- Banu Nadir → Badr al-Maw'id → Banu Mustaliq → Al-Ifk ✓
- Trench sequence (dig → siege → Nu'aym → duel → wind → Qurayza → Sa'd) ✓

### M3 — The Turning Tide (627–630 CE): ✓ CORRECT
All 38 events are in correct chronological order. Key sequence verified:
- Hudaybiyyah sequence (journey → she-camel → Bay'ah → treaty → Surah Al-Fath) ✓
- Letters to kings (Heraclius, Chosroes, Negus, Muqawqis) grouped ✓
- Khaybar sequence (march → battle → Ali → poisoned lamb) ✓
- Umrat al-Qada → Khalid/Amr accept Islam ✓
- Mu'tah sequence (battle → three commanders → Khalid) ✓
- Conquest of Mecca sequence (treaty broken → Abu Sufyan → march → conquest → amnesty → Bilal's adhan) ✓
- Hunayn → Siege of Ta'if (different from 619 CE Ta'if!) → spoils ✓

**Note:** Event 120 (Arabian Peninsula Transforms) dated 630 CE could
be argued as 630–631 CE since the transformation was gradual. Not an
error — acceptable simplification.

### M4 — The Final Chapter (630–632 CE): ✓ CORRECT
All 35 events are in correct chronological order. Key sequence verified:
- Tabuk sequence (call → hypocrites → Abu Khaythamah → battle → Dirar mosque → three who stayed) ✓
- Year of Delegations (Banu Tamim, Thaqif, Najran) ✓
- Abu Bakr's Hajj → Ali proclaims Tawbah ✓
- Farewell Pilgrimage sequence (preparations → procession → entry → Arafah → sermon → "Today I have perfected" → Ghadir Khumm) ✓
- Final period (Usama's expedition → illness → Uhud visit → Abu Bakr leads prayer → final appearance → departure → Umar's grief → Abu Bakr's address → funeral → burial) ✓
- Event 155 (The Story Continues) is a narrative closing ✓

---

## Part 6 — Summary of Required Actions

### Immediate (m1_data.dart — current 36 events):
1. Move Black Stone event from globalOrder 3 to globalOrder 8
2. Change its era from `jahiliyyah` to `earlyLife`
3. Move Ta'if event from globalOrder 22 to globalOrder 17
4. Renumber all globalOrder values to match Part 2 sequence above
5. Update badge trigger ranges (Jahiliyyah now Events 1–2, not 1–3)
6. Update chapter header definitions in event_list_screen.dart
7. Run all tests — branching tests reference event IDs not globalOrder,
   so they should still pass

### Master Plan (RAWI_MASTER_PLAN.md):
1. Move Black Stone from Jahiliyyah Event 3 to Early Life Event 12
2. Update era distribution table (Jahiliyyah: 2, Early Life: 12)
3. Renumber all M1 globalOrders accordingly
4. M2, M3, M4 are correct — no changes needed

### Before any new content is written:
- Every new event must specify its year and be placed in strict
  chronological order within its era
- Cross-reference against Al-Raheeq Al-Makhtum chapter order
- No thematic grouping that breaks chronological sequence

---

## Part 7 — Source Hierarchy (Reminder)

Per RAWI_MASTER_PLAN.md Section 4 — this is law:

| Tier | Sources | Usage |
|------|---------|-------|
| Tier 1 | القرآن الكريم | Exact, never paraphrased |
| Tier 2 | Sahih Bukhari + Sahih Muslim + Four Sunan | All hadith citations |
| Tier 3 | الرحيق المختوم + سيرة ابن هشام + البداية والنهاية | Narrative, chronology |

**Prohibited:** Isra'iliyyat, Bahira incident, visual depiction of
the Prophet ﷺ, speculative dialogue without hadith source.
