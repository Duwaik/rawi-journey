# RawiJourney — Updated Event Sequence (155 Events)

> **IMPORTANT:** The old 36-event structure is being replaced by
> 155 events. This document is the single source of truth for
> event ordering. Do NOT reference the old globalOrder values.

---

## The Project is 155 Events, Not 36

| Module | Events | Range |
|--------|--------|-------|
| M1 — The Prophetic Dawn | 47 | 1–47 |
| M2 — The Community Rises | 35 | 48–82 |
| M3 — The Turning Tide | 38 | 83–120 |
| M4 — The Final Chapter | 35 | 121–155 |

Current events 23–36 in m1_data.dart (Medina onward) will
eventually move to M2–M4. Do NOT restructure yet. Just follow
the sequence below for new events.

---

## First 15 Events — Correct Sequence

| New # | Title EN | Title AR | Status | Old ID |
|-------|----------|----------|--------|--------|
| 1 | Arabia Before the Light | الجزيرة العربية قبل النور | ✅ Playable | j_1_1_1 |
| 2 | The Year of the Elephant | عام الفيل | ✅ Playable | j_1_1_2 |
| 3 | The Birth of the Prophet ﷺ | مولد النبي ﷺ | ✅ Playable | j_1_2_1 |
| 4 | The Nursing Years — Halimah | سنوات الرضاعة — حليمة | ✅ Playable | j_1_2_2 (was Abd al-Muttalib, replaced) |
| 5 | The Opening of the Chest | شرح الصدر | NEW — no old equivalent |
| 6 | Return to Mecca — Death of Aminah | العودة إلى مكة — وفاة آمنة | NEW — no old equivalent |
| 7 | Under the Care of Abd al-Muttalib | في كنف عبد المطلب | NEW — old content was replaced by Event 4 |
| 8 | The Guardian: Abu Talib | في كنف أبي طالب | Exists as j_1_2_3 (old position 5) |
| 9 | Hilf al-Fudul — The Pact of the Virtuous | حلف الفضول | Exists as j_1_2_4 (old position 6) |
| 10 | Al-Amin — The Trustworthy | الأمين | NEW — no old equivalent |
| 11 | Marriage to Khadijah | الزواج من خديجة رضي الله عنها | Exists as j_1_2_5 (old position 7) |
| 12 | The Black Stone — A Wise Arbitration | الحجر الأسود — حكمة التحكيم | ✅ Playable | j_1_1_3 (old position 8) |
| 13 | Solitude in Cave Hira | الخلوة في غار حراء | Exists as j_1_2_6 (old position 9) |
| 14 | The First Revelation | نزول الوحي الأول | Exists as j_1_2_7 (old position 10) |
| 15 | The First Believers | أوائل المؤمنين | Exists as j_1_2_8 (old position 11) |

---

## What This Means for the Agent

1. **Events 1–4 are built and playable** with scene configs
2. **Events 5, 6, 7** are entirely NEW. Content docs provided.
   Build scene configs using the same pattern as Events 3–4.
3. **Event 8 (Abu Talib)** exists in old code as j_1_2_3 at
   old position 5. Content is being REPLACED with new content
   doc. Build new scene config.
4. **Events 9–15** are a mix of existing (need new scene configs)
   and new (need everything).
5. **The Black Stone is now Event 12, not Event 8.** Its scene
   config (j_1_1_3) stays untouched.
6. **Do NOT renumber existing events yet.** Add new events with
   new IDs. The full renumbering happens after all M1 content
   (47 events) is written.

---

## New Event ID Convention

For new events that don't exist in old code, use:
```
j_m1_005  (Event 5 — Opening of the Chest)
j_m1_006  (Event 6 — Death of Aminah)
j_m1_007  (Event 7 — Abd al-Muttalib)
j_m1_010  (Event 10 — Al-Amin)
```

For existing events getting new content, keep old IDs for now:
```
j_1_2_3   (Event 8 — Abu Talib, old position 5)
j_1_2_4   (Event 9 — Hilf al-Fudul, old position 6)
```

---

## Scene Config Keys

Scene configs in scene_configs.dart use the event ID as the key.
New scene configs use new IDs:
```dart
'j_m1_005': SceneConfig(...)  // Event 5
'j_m1_006': SceneConfig(...)  // Event 6
'j_m1_007': SceneConfig(...)  // Event 7
```

Existing events keep their old keys until the full renumber.
