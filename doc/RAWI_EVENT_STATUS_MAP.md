# RawiJourney — Event Status Map (Post-155 Restructure)

> **Updated:** 2026-04-10
> **Structure:** 155 events across 4 modules. M1 has 40 events in code.
> **Playable:** 14 events with scene configs (Events 1-14). **Content-ready:** 14 events total (Events 1-14).
> **SINGLE SOURCE OF TRUTH:** `doc/RAWI_155_MASTER_LIST.md`
> **Canonical sequence (first 15):** `doc/RAWI_UPDATED_EVENT_SEQUENCE.md`
> **Blocked events:** 18 pending Khaled's verification — see `doc/RAWI_BLOCKED_EVENTS.md`

---

## Playable Events (14 — have scene configs)

| # | ID | Title | Era | Type | DYK | SourceRef |
|---|-----|-------|-----|------|-----|-----------|
| 1 | j_1_1_1 | Arabia Before the Light | Jahiliyyah | Branching | ✅ 2/4 | ✅ 4/4 |
| 2 | j_1_1_2 | Year of the Elephant | Jahiliyyah | Branching + Video | ✅ 2/4 | ✅ 4/4 |
| 3 | j_1_2_1 | Birth of the Prophet ﷺ | Early Life | Linear | ✅ 2/4 | ✅ 4/4 |
| 4 | j_1_2_2 | Nursing Years — Halimah | Early Life | Linear | ✅ 2/4 | ✅ 4/4 |
| 5 | j_m1_005 | Opening of the Chest | Early Life | Linear | ✅ 2/4 | ✅ 4/4 |
| 6 | j_m1_006 | Death of Aminah | Early Life | Linear | ✅ 2/4 | ✅ 4/4 |
| 7 | j_m1_007 | Under Care of Abd al-Muttalib | Early Life | Linear | ✅ 2/4 | ✅ 4/4 |
| 8 | j_1_2_3 | The Guardian: Abu Talib | Early Life | Linear | ✅ 2/4 | ✅ 4/4 |
| 9 | j_1_2_4 | Hilf al-Fudul | Early Life | Linear | ✅ 4/4 | ✅ 4/4 |
| 10 | j_m1_010 | Al-Amin — The Trustworthy | Early Life | Linear | ✅ 4/4 | ✅ 4/4 |
| 11 | j_m1_011 | Marriage to Khadijah رضي الله عنها | Early Life | Linear | ✅ 4/4 | ✅ 4/4 |
| 12 | j_1_1_3 | The Black Stone: A Wise Arbitration | Early Life | Branching | ✅ 4/4 | ✅ 4/4 |
| 13 | j_1_2_6 | Solitude in Cave Hira | Early Life | Linear | ✅ 4/4 | ✅ 4/4 |
| 14 | j_1_2_7 | The First Revelation | Early Life | Linear + Witness Moment | ✅ 2/4 | ✅ 4/4 |

## Linear-Only Events (26 — need scene configs + content)

| # | ID | Title | Era |
|---|-----|-------|-----|
| 15 | j_1_2_8 | The First Believers | Early Life |
| 16-40 | Various | Mecca + Medina events | Mecca/Medina |

---

## ID Convention (LOCKED — Sprint 54)

- Legacy events: `j_1_1_1`, `j_1_2_3`, etc. — keep as-is
- New events: `j_m1_NNN` format (e.g., `j_m1_005`, `j_m1_006`)
- **NEVER overwrite an existing ID with different content** — add a new ID
- Full ID renumbering deferred until all 47 M1 events are written
- **Canonical source of truth:** `doc/RAWI_155_MASTER_LIST.md`
- First-15 sequence table: `doc/RAWI_UPDATED_EVENT_SEQUENCE.md`
- Blocked events tracker: `doc/RAWI_BLOCKED_EVENTS.md` (18 items pending Khaled verification)

---

## What Each New Event Needs

- ⬜ Content doc from Khaled (narrative + 4 hotspots + question + DYK + sourceRef)
- ⬜ Event data in `m1_data.dart` (new ID, correct globalOrder)
- ⬜ Scene config in `scene_configs.dart` (hotspots, path, sky gradient)
- ⬜ Scene BG image (placeholder until batch generation)
- ⬜ VO files (deferred to batch generation)
- ⬜ Ambient clips (deferred to batch generation)
