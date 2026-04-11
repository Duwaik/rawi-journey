"""
RawiJourney - Event content generator.

Parses Khaled's RAWI_EVENT_*.md (single) and RAWI_EVENTS_*.md (bundled-5)
files from Downloads, plus the master list for Arabic titles, and emits
Dart code blocks for:
  - tools/output/events_block.dart  (JourneyEvent entries for m1_data.dart)
  - tools/output/scenes_block.dart  (sceneConfigs map entries)
  - tools/output/dhikr_block.dart   (dhikrCards map entries)
  - tools/output/scroll_block.dart  (scrollEntries map entries)

Run:
  py tools/generate_events.py --range 21-29
  py tools/generate_events.py --range all
"""
import os, re, sys, argparse
from pathlib import Path

# Force utf-8 stdout/stderr (Windows cp1256 default mangles emoji + Arabic)
sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')

DOWNLOADS = Path('C:/Users/LENOVO/Downloads')
MASTER_LIST = Path('d:/Rawi_Journey/doc/RAWI_155_MASTER_LIST.md')
OUT_DIR = Path('d:/Rawi_Journey/tools/output')
OUT_DIR.mkdir(parents=True, exist_ok=True)

# ─── Slot ID mapping (existing IDs from m1_data.dart for events 1-27) ──────
EXISTING_SLOTS = {
    1: 'j_1_1_1', 2: 'j_1_1_2', 3: 'j_1_2_1', 4: 'j_1_2_2',
    5: 'j_m1_005', 6: 'j_m1_006', 7: 'j_m1_007', 8: 'j_1_2_3',
    9: 'j_1_2_4', 10: 'j_m1_010', 11: 'j_m1_011', 12: 'j_1_1_3',
    13: 'j_1_2_6', 14: 'j_1_2_7', 15: 'j_1_2_8', 16: 'j_m1_016',
    17: 'j_1_3_1', 18: 'j_1_3_2', 19: 'j_1_3_3', 20: 'j_1_3_4',
    21: 'j_1_3_5', 22: 'j_1_3_11', 23: 'j_1_3_6', 24: 'j_1_3_7',
    25: 'j_1_3_8', 26: 'j_1_3_9', 27: 'j_1_3_10',
}

def slot_id(order):
    if order in EXISTING_SLOTS:
        return EXISTING_SLOTS[order]
    if order <= 47: return f'j_m1_{order:03d}'
    if order <= 82: return f'j_m2_{order:03d}'
    if order <= 120: return f'j_m3_{order:03d}'
    return f'j_m4_{order:03d}'

def era_for(order):
    if order <= 2: return 'jahiliyyah'
    if order <= 15: return 'earlyLife'
    if order <= 47: return 'mecca'
    return 'medina'

BLOCKED = {25, 28, 32, 33, 35, 37, 43, 46, 53, 67, 71, 77, 83, 97, 104, 123, 128, 130}

# ─── Layout pattern → hotspot positions and walking waypoints ──────────────
LAYOUT_POSITIONS = {
    'A': [(0.50, 0.62), (0.25, 0.44), (0.72, 0.42), (0.50, 0.28)],
    'B': [(0.22, 0.52), (0.42, 0.46), (0.62, 0.40), (0.80, 0.34)],
    'C': [(0.50, 0.60), (0.22, 0.42), (0.50, 0.25), (0.78, 0.42)],
    'D': [(0.50, 0.50), (0.25, 0.40), (0.75, 0.40), (0.50, 0.28)],
    'F': [(0.30, 0.55), (0.70, 0.55), (0.30, 0.32), (0.70, 0.32)],
}
LAYOUT_WAYPOINTS = {
    'A': [(0.50, 0.80), (0.51, 0.72), (0.50, 0.62), (0.38, 0.54), (0.25, 0.44), (0.45, 0.42), (0.72, 0.42), (0.63, 0.36), (0.50, 0.28)],
    'B': [(0.12, 0.58), (0.17, 0.55), (0.22, 0.52), (0.32, 0.49), (0.42, 0.46), (0.52, 0.43), (0.62, 0.40), (0.72, 0.37), (0.80, 0.34)],
    'C': [(0.50, 0.78), (0.50, 0.72), (0.50, 0.60), (0.36, 0.52), (0.22, 0.42), (0.28, 0.32), (0.50, 0.25), (0.72, 0.32), (0.78, 0.42)],
    'D': [(0.50, 0.78), (0.50, 0.62), (0.50, 0.50), (0.36, 0.45), (0.25, 0.40), (0.50, 0.42), (0.75, 0.40), (0.62, 0.34), (0.50, 0.28)],
    'F': [(0.50, 0.78), (0.40, 0.65), (0.30, 0.55), (0.50, 0.55), (0.70, 0.55), (0.60, 0.42), (0.30, 0.32), (0.50, 0.32), (0.70, 0.32)],
}

# ─── Common location AR translations ───────────────────────────────────────
LOCATION_AR = {
    'Mecca': 'مكة المكرمة',
    'Medina': 'المدينة المنورة',
    'Mount Safa, Mecca': 'جبل الصفا، مكة المكرمة',
    'Mount Safa': 'جبل الصفا',
    'Mecca, Mount Safa': 'جبل الصفا، مكة المكرمة',
    'Cave Hira, Mecca': 'غار حراء، مكة المكرمة',
    'Cave Hira': 'غار حراء',
    'Axum, Abyssinia': 'أكسوم، الحبشة',
    'Axum, Abyssinia (Ethiopia)': 'أكسوم، الحبشة',
    'Shi\'b Abi Talib': 'شعب أبي طالب',
    'Shi\'b Abi Talib, Mecca': 'شعب أبي طالب، مكة المكرمة',
    "Ta'if": 'الطائف',
    'Mount Uhud': 'جبل أحد',
    'Mount Uhud, Medina': 'جبل أحد، المدينة المنورة',
    'Hudaybiyyah': 'الحديبية',
    'Khaybar': 'خيبر',
    'Tabuk': 'تبوك',
    'Arafah': 'عرفة',
    "Mu'tah": 'مؤتة',
    'Hunayn': 'حنين',
    'Badr': 'بدر',
    'Quba': 'قباء',
    'Banu Sa\'d': 'بني سعد',
    'Al-Abwa': 'الأبواء',
    'Jerusalem / Heavens': 'القدس / السماوات',
    'Mina': 'منى',
    'Cave Thawr': 'غار ثور',
    'Wadi Nakhlah': 'وادي نخلة',
    'Wadi Ranuna': 'وادي رانوناء',
    'Marr al-Zahran': 'مر الظهران',
    'Bi\'r Ma\'una': 'بئر معونة',
    "Raji'": 'الرجيع',
    'Ji\'ranah': 'الجعرانة',
    'Muraysi': 'المريسيع',
    'Ghadir Khumm': 'غدير خم',
    'Uhud': 'أحد',
    'Arabia': 'الجزيرة العربية',
    'Various': 'مواضع متعددة',
    'En route': 'في الطريق',
    'Near Medina': 'قرب المدينة',
    'Mecca/Medina': 'مكة / المدينة',
    'Medina/Tabuk': 'المدينة / تبوك',
    'Banu Sa\'d': 'ديار بني سعد',
}

def location_ar(loc_en):
    if not loc_en: return 'مكة المكرمة'
    if loc_en in LOCATION_AR: return LOCATION_AR[loc_en]
    # Strip prefixes
    for prefix in ['Mecca, ', 'Medina, ']:
        if loc_en.startswith(prefix):
            rest = loc_en[len(prefix):]
            if rest in LOCATION_AR:
                return f'{LOCATION_AR[prefix.rstrip(", ")]}، {LOCATION_AR[rest]}'
    return loc_en  # fallback to English (will need manual fix)

# ─── Master list parser → title_ar by globalOrder ──────────────────────────
def parse_master_list():
    """Extract title_ar by globalOrder. Only the FIRST match wins, so the
    'Items Requiring Verification' table at the bottom doesn't overwrite
    real titles from the M1-M4 module tables above."""
    titles_ar = {}
    if not MASTER_LIST.exists(): return titles_ar
    text = MASTER_LIST.read_text(encoding='utf-8')
    # Stop at verification section if present
    cutoff = text.find('Items Requiring')
    if cutoff > 0:
        text = text[:cutoff]
    for m in re.finditer(r'^\|\s*(\d+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|', text, re.M):
        try:
            order = int(m.group(1))
            if order not in titles_ar:
                titles_ar[order] = m.group(3).strip()
        except ValueError:
            pass
    return titles_ar

MASTER_TITLES_AR = parse_master_list()

# ─── Dart string escaping ──────────────────────────────────────────────────
def dart_str(s):
    """Escape a string for a single-quoted Dart literal."""
    if s is None: return "''"
    s = str(s)
    s = s.replace('\\', '\\\\')
    s = s.replace("'", "\\'")
    s = s.replace('\ufdfa', '\\uFDFA')  # ﷺ
    s = s.replace('\n', '\\n')
    return f"'{s}'"

def dart_str_or_null(s):
    if not s: return 'null'
    return dart_str(s)

# ─── Markdown parser ───────────────────────────────────────────────────────
def split_events(text):
    """Split a file into individual event text blocks."""
    headers = list(re.finditer(r'^(?:## Event\s+\d+|# RawiJourney\s*[—–-]\s*Event\s+\d+)', text, re.M))
    if not headers: return []
    blocks = []
    for i, h in enumerate(headers):
        start = h.start()
        end = headers[i+1].start() if i+1 < len(headers) else len(text)
        blocks.append(text[start:end])
    return blocks

def grab_field(text, name):
    """Find a single-line field. Handles `> **Name:** v`, `**Name:** v`, and `**Name** v`."""
    m = re.search(rf'(?:>\s*)?\*\*{re.escape(name)}:?\*\*\s*([^\n]+)', text)
    return m.group(1).strip() if m else ''

def grab_multiline_field(text, name):
    """Grab a field whose value spans multiple lines, until next ** or section break."""
    pattern = rf'\*\*{re.escape(name)}:\*\*\s*\n((?:(?!\n\s*\*\*|\n#{{2,3}}\s|\n---\s|\n>\s*\*\*).+\n?)+)'
    m = re.search(pattern, text)
    if m:
        return m.group(1).strip()
    # Inline form: **Name:** text on same line
    m = re.search(rf'\*\*{re.escape(name)}:\*\*\s*([^\n]+)', text)
    return m.group(1).strip() if m else ''

def parse_event(text, default_title_ar=''):
    """Parse a single event block. Returns dict or None."""
    ev = {}

    # Order + title from header
    m = re.search(r'(?:## Event|# RawiJourney\s*[—–-]\s*Event)\s+(\d+)\s*:\s*(.+?)$', text, re.M)
    if not m: return None
    ev['order'] = int(m.group(1))
    ev['title_en'] = m.group(2).strip()

    # Metadata
    layout = grab_field(text, 'Layout Pattern')
    m = re.match(r'([A-F])', layout) if layout else None
    ev['layout'] = m.group(1) if m else 'A'

    date = grab_field(text, 'Date')
    m = re.search(r'(\d{3,4})', date)
    ev['year'] = int(m.group(1)) if m else 0

    ev['location_en'] = grab_field(text, 'Location')

    ev['witness'] = bool(re.search(r'\*\*Witness Moment:\*\*\s*YES', text, re.I))

    # Title AR — try inline field, fall back to master list
    title_ar = grab_field(text, 'Title AR')
    if not title_ar:
        title_ar = MASTER_TITLES_AR.get(ev['order'], default_title_ar)
    ev['title_ar'] = title_ar

    # Hotspots
    hotspot_headers = list(re.finditer(r'^#{2,3}\s*Hotspot\s+(\d+)\s*[—–\-]\s*(.+?)$', text, re.M))
    hotspots = []
    for i, h in enumerate(hotspot_headers):
        start = h.end()
        end = hotspot_headers[i+1].start() if i+1 < len(hotspot_headers) else len(text)
        # Stop at next major section
        section_break = re.search(r'^#{2,3}\s*(?:Verdict|Witness Moment|Scroll Entry|Dhikr|Source Verification|Event\s+\d)', text[start:end], re.M)
        if section_break:
            end = start + section_break.start()
        block = text[start:end]

        # Header label is "Hotspot N — Some Label" — extract "Some Label"
        header_label_en = h.group(2).strip()
        hot = {
            'id': grab_field(block, 'ID'),
            'icon': grab_field(block, 'Icon') or '✦',
            'label_en': grab_field(block, 'Label EN'),
            'label_ar': grab_field(block, 'Label AR'),
            'fragment_en': grab_multiline_field(block, 'Fragment EN'),
            'fragment_ar': grab_multiline_field(block, 'Fragment AR'),
            'source': grab_field(block, 'Source'),
            'source_ar': grab_field(block, 'Source AR'),
            'dyk_en': grab_multiline_field(block, 'DYK EN'),
            'dyk_ar': grab_multiline_field(block, 'DYK AR'),
        }
        if not hot['label_en']:
            hot['label_en'] = header_label_en
        if not hot['id']:
            # Slug from English label, fallback to h{i+1}
            slug = re.sub(r'[^a-z0-9]+', '_', header_label_en.lower()).strip('_')
            hot['id'] = slug[:30] if slug else f'h{i+1}'
        hotspots.append(hot)
    ev['hotspots'] = hotspots[:4]

    # Verdict — also matches combined headers like `## Verdict + Scroll + Dhikr`
    verdict = {}
    m = re.search(r'^#{2,3}\s*Verdict\b.*$', text, re.M)
    if m:
        v_text = text[m.end():]
        m_next = re.search(r'^(?:#{2,3}\s*(?:Witness Moment|Scroll Entry|Dhikr|Source Verification)|---\s*$|## Event\s+\d)', v_text, re.M)
        if m_next: v_text = v_text[:m_next.start()]

        verdict['question_en'] = grab_field(v_text, 'Question EN')
        verdict['question_ar'] = grab_field(v_text, 'Question AR')
        verdict['explanation_en'] = grab_multiline_field(v_text, 'Explanation EN')
        verdict['explanation_ar'] = grab_multiline_field(v_text, 'Explanation AR')

        options_en, options_ar = [], []
        correct = -1

        # Table format: | 1 | EN | AR | ❌/✅ |
        rows = re.findall(r'^\|\s*\d+\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|\n]+?)\s*\|', v_text, re.M)
        if rows:
            for i, (en, ar, mark) in enumerate(rows):
                # Skip header rows
                if en.lower() in ('en', '---') or '---' in en: continue
                options_en.append(en.strip())
                options_ar.append(ar.strip())
                if '✅' in mark:
                    correct = len(options_en) - 1
        else:
            # Bundled: **Option A EN:** ... ✅
            for letter_i, letter in enumerate(['A', 'B', 'C']):
                m_en = re.search(rf'\*\*Option {letter} EN:\*\*\s*([^\n]+)', v_text)
                m_ar = re.search(rf'\*\*Option {letter} AR:\*\*\s*([^\n]+)', v_text)
                if m_en and m_ar:
                    en_t = m_en.group(1).strip()
                    ar_t = m_ar.group(1).strip()
                    if '✅' in en_t or '✅' in ar_t:
                        correct = letter_i
                    options_en.append(en_t.replace('✅', '').strip())
                    options_ar.append(ar_t.replace('✅', '').strip())

        verdict['options_en'] = options_en
        verdict['options_ar'] = options_ar
        verdict['correct'] = correct if correct >= 0 else 0
        verdict['source'] = grab_field(v_text, 'Source')
    ev['verdict'] = verdict

    # Witness Moment
    if ev['witness']:
        m = re.search(r'^#{2,3}\s*Witness Moment\s*$', text, re.M)
        if m:
            w_text = text[m.end():]
            m_next = re.search(r'^(?:#{2,3}\s|---\s*$)', w_text, re.M)
            if m_next: w_text = w_text[:m_next.start()]
            ev['witness_en'] = grab_field(w_text, 'EN')
            ev['witness_ar'] = grab_field(w_text, 'AR')

    # Scroll Entry
    scroll = {}
    m = re.search(r'^#{2,3}\s*Scroll Entry\s*$', text, re.M)
    if m:
        s_text = text[m.end():]
        m_next = re.search(r'^(?:#{2,3}\s|---\s*$)', s_text, re.M)
        if m_next: s_text = s_text[:m_next.start()]
        scroll['en'] = grab_field(s_text, 'EN')
        scroll['ar'] = grab_field(s_text, 'AR')
    ev['scroll'] = scroll

    # Dhikr
    dhikr = {}
    m = re.search(r'^#{2,3}\s*Dhikr\s*$', text, re.M)
    if m:
        d_text = text[m.end():]
        m_next = re.search(r'^(?:#{2,3}\s*(?:Source Verification|Hotspot|Verdict|Scroll|Witness)|---\s*$|## Event\s+\d)', d_text, re.M)
        if m_next: d_text = d_text[:m_next.start()]

        def df(name):
            m = re.search(rf'(?:-\s*)?\*\*{re.escape(name)}:?\*\*\s*([^\n]*)', d_text)
            return m.group(1).strip() if m else ''

        dhikr['arabic'] = df('Arabic')
        dhikr['transliteration'] = df('Transliteration')
        dhikr['english'] = df('English') or df('Meaning')
        dhikr['count'] = df('Count')
        dhikr['when'] = df('When to say it') or df('When to say')
        dhikr['promise_en'] = df('The Promise EN') or df('The Promise')
        # Promise AR has parens or " AR" suffix
        m_pa = re.search(r'(?:-\s*)?\*\*The Promise\s*\(AR\):?\*\*\s*([^\n]+)', d_text)
        if not m_pa:
            m_pa = re.search(r'(?:-\s*)?\*\*The Promise AR:?\*\*\s*([^\n]+)', d_text)
        dhikr['promise_ar'] = m_pa.group(1).strip() if m_pa else ''
        dhikr['source'] = df('Source')
    ev['dhikr'] = dhikr

    return ev

# ─── Dart code generation ──────────────────────────────────────────────────
def gen_journey_event(ev):
    sid = slot_id(ev['order'])
    era = era_for(ev['order'])
    blocked = ev['order'] in BLOCKED

    title_ar = ev['title_ar'] or 'TODO_AR'
    loc_en = ev['location_en'] or 'Mecca'
    loc_ar = location_ar(loc_en)

    # XP
    xp = 35

    # Verdict
    v = ev.get('verdict', {})
    opts_en = v.get('options_en', [])
    opts_ar = v.get('options_ar', [])
    has_question = bool(v.get('question_en') and opts_en and opts_ar)
    if has_question:
        opts_en_str = '[\n          ' + ',\n          '.join(dart_str(o) for o in opts_en) + ',\n        ]'
        opts_ar_str = '[\n          ' + ',\n          '.join(dart_str(o) for o in opts_ar) + ',\n        ]'

    src_ref = v.get('source', '') or (ev.get('hotspots', [{}])[0].get('source', '') if ev.get('hotspots') else '')

    witness_block = ''
    if ev.get('witness'):
        we = ev.get('witness_en', '')
        wa = ev.get('witness_ar', '')
        # Split into ~3 lines on sentence boundaries
        we_lines = re.split(r'(?<=[.!?])\s+', we)[:3] if we else [we]
        wa_lines = re.split(r'(?<=[.؟!])\s+', wa)[:3] if wa else [wa]
        # Pad to 3
        while len(we_lines) < 3: we_lines.append('')
        while len(wa_lines) < 3: wa_lines.append('')
        witness_block = (
            '    witnessIntro: const WitnessIntro(\n'
            '      lines: [\n'
            + ''.join(f'        {dart_str(l)},\n' for l in we_lines if l) +
            '      ],\n'
            '      linesAr: [\n'
            + ''.join(f'        {dart_str(l)},\n' for l in wa_lines if l) +
            '      ],\n'
            '    ),\n'
        )

    flag_comment = ''
    if blocked:
        flag_comment = (
            '  // ⚠️ NEEDS REVIEW — Event #{} flagged in RAWI_BLOCKED_EVENTS.md.\n'
            '  // Content implemented from master list; awaiting Khaled\'s confirmation.\n'
        ).format(ev['order'])

    questions_block = ''
    if has_question:
        questions_block = (
            '    questions: [\n'
            '      JourneyQuestion(\n'
            f'        id: {dart_str("q_" + sid.replace("j_", ""))},\n'
            f'        question: {dart_str(v.get("question_en", ""))},\n'
            f'        questionAr: {dart_str(v.get("question_ar", ""))},\n'
            f'        options: {opts_en_str},\n'
            f'        optionsAr: {opts_ar_str},\n'
            f'        correctIndex: {v.get("correct", 0)},\n'
            f'        explanation: {dart_str(v.get("explanation_en", ""))},\n'
            f'        explanationAr: {dart_str(v.get("explanation_ar", ""))},\n'
            f'        sourceRef: {dart_str(v.get("source", src_ref))},\n'
            f'        sourceRefAr: {dart_str(v.get("source", src_ref))},\n'
            '      ),\n'
            '    ],\n'
        )
    else:
        questions_block = '    questions: const [],\n'

    return (
        flag_comment +
        '  JourneyEvent(\n'
        f'    id: {dart_str(sid)},\n'
        f'    era: JourneyEra.{era},\n'
        f'    globalOrder: {ev["order"]},\n'
        f'    latitude: 21.4225, longitude: 39.8262,\n'
        f'    year: {ev["year"]},\n'
        f'    title: {dart_str(ev["title_en"])},\n'
        f'    titleAr: {dart_str(title_ar)},\n'
        f'    location: {dart_str(loc_en)},\n'
        f'    locationAr: {dart_str(loc_ar)},\n'
        f"    narrative: '',\n"
        f"    narrativeAr: '',\n"
        f'    source: {dart_str(src_ref)},\n'
        f'    xpReward: {xp},\n'
        + witness_block +
        questions_block +
        '  ),\n'
    )

def gen_scene_config(ev):
    sid = slot_id(ev['order'])
    layout = ev.get('layout', 'A')
    positions = LAYOUT_POSITIONS.get(layout, LAYOUT_POSITIONS['A'])
    waypoints = LAYOUT_WAYPOINTS.get(layout, LAYOUT_WAYPOINTS['A'])
    blocked = ev['order'] in BLOCKED

    flag = ''
    if blocked:
        flag = f'  // ⚠️ NEEDS REVIEW — Event #{ev["order"]} (see RAWI_BLOCKED_EVENTS.md)\n'

    hotspots_dart = ''
    for i, h in enumerate(ev.get('hotspots', [])):
        if i >= 4: break
        x, y = positions[i] if i < len(positions) else (0.5, 0.5)
        dyk_block = ''
        if h.get('dyk_en'):
            dyk_block = (
                f',\n        didYouKnow: {dart_str(h["dyk_en"])}'
                f',\n        didYouKnowAr: {dart_str(h.get("dyk_ar", ""))}'
            )
        src_ar = h.get('source_ar') or h.get('source', '')
        hotspots_dart += (
            f'      SceneHotspot(id: {dart_str(h["id"])}, x: {x}, y: {y}, icon: {dart_str(h.get("icon", "✦"))}, '
            f'label: {dart_str(h.get("label_en", ""))}, labelAr: {dart_str(h.get("label_ar", ""))},\n'
            f'        fragment: {dart_str(h.get("fragment_en", ""))},\n'
            f'        fragmentAr: {dart_str(h.get("fragment_ar", ""))},\n'
            f"        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',\n"
            f'        sourceRef: {dart_str(h.get("source", ""))},\n'
            f'        sourceRefAr: {dart_str(src_ar)}'
            + dyk_block + '),\n'
        )

    waypoints_str = '[' + ', '.join(f'Offset({x}, {y})' for x, y in waypoints) + ']'

    return (
        flag +
        f'  // ── Event {ev["order"]}: {ev["title_en"]} ({ev["year"]} CE) — Pattern {layout} ─\n'
        f'  {dart_str(sid)}: SceneConfig(\n'
        '    hubLayers: _meccaHubLayers,\n'
        '    groundLayers: const [],\n'
        '    hotspots: const [\n'
        + hotspots_dart +
        '    ],\n'
        f'    pathWaypoints: const {waypoints_str},\n'
        '    skyGradient: const [Color(0xFF000000), Color(0xFF000000)],\n'
        '    particleType: ParticleType.dust, particleCount: 20, particleColor: const Color(0x40C9A84C), showGrain: true,\n'
        '  ),\n'
    )

def gen_dhikr(ev):
    sid = slot_id(ev['order'])
    d = ev.get('dhikr', {})
    if not d.get('arabic'): return ''
    blocked = ev['order'] in BLOCKED
    flag = f'  // ⚠️ NEEDS REVIEW — Event #{ev["order"]}\n' if blocked else ''
    return (
        flag +
        f'  // ── Event {ev["order"]}: {ev["title_en"]} ─\n'
        f'  {dart_str(sid)}: DhikrCard(\n'
        f'    id: {dart_str(sid)},\n'
        f'    arabicText: {dart_str(d.get("arabic", ""))},\n'
        f'    transliteration: {dart_str(d.get("transliteration", ""))},\n'
        f'    meaningEn: {dart_str(d.get("english", ""))},\n'
        f'    meaningAr: {dart_str(d.get("arabic", ""))},\n'  # use arabic as meaning_ar fallback
        f'    count: {dart_str_or_null(d.get("count", ""))},\n'
        f'    countAr: null,\n'
        f'    whenToSay: {dart_str(d.get("when", ""))},\n'
        f"    whenToSayAr: '',\n"
        f'    promiseEn: {dart_str(d.get("promise_en", ""))},\n'
        f'    promiseAr: {dart_str(d.get("promise_ar", ""))},\n'
        f'    sourceRef: {dart_str(d.get("source", ""))},\n'
        f"    sourceRefAr: '',\n"
        '  ),\n'
    )

def gen_scroll(ev):
    sid = slot_id(ev['order'])
    s = ev.get('scroll', {})
    if not s.get('en'): return ''
    return (
        f'  {dart_str(sid)}: ScrollEntry(\n'
        f'    eventId: {dart_str(sid)},\n'
        f'    globalOrder: {ev["order"]},\n'
        f'    lineEn: {dart_str(s.get("en", ""))},\n'
        f'    lineAr: {dart_str(s.get("ar", ""))},\n'
        '  ),\n'
    )

# ─── Main ──────────────────────────────────────────────────────────────────
def collect_all_events():
    """Walk Downloads, parse every event file, return {order: ev_dict}."""
    events = {}
    files = sorted(DOWNLOADS.glob('RAWI_EVENT*.md'))
    # Skip status map and `_1.md` duplicate variants (single-digit suffix only)
    files = [f for f in files if 'STATUS_MAP' not in f.name and not re.search(r'_1\.md$', f.name)]
    for f in files:
        try:
            text = f.read_text(encoding='utf-8')
        except Exception as e:
            print(f'  ! Failed to read {f.name}: {e}', file=sys.stderr)
            continue
        for block in split_events(text):
            ev = parse_event(block)
            if ev and ev.get('order') and ev['order'] not in events:
                events[ev['order']] = ev
                ev['_source_file'] = f.name
    return events

DART_FILES = {
    'events': Path('d:/Rawi_Journey/lib/data/m1_data.dart'),
    'scenes': Path('d:/Rawi_Journey/lib/data/scene_configs.dart'),
    'dhikr':  Path('d:/Rawi_Journey/lib/data/dhikr_data.dart'),
    'scroll': Path('d:/Rawi_Journey/lib/data/scroll_entries.dart'),
}

def apply_to_dart(events, orders):
    """Splice script-generated blocks into the four dart files in place.

    Strategy:
      - m1_data.dart: replace existing JourneyEvent blocks whose `id` matches
        a generated slot id; insert new ones before the closing `];` of m1Events.
      - scene_configs.dart, dhikr_data.dart, scroll_entries.dart: same strategy,
        keyed off the slot id at the start of each map entry.

    Returns a summary dict.
    """
    summary = {}

    # Build per-event blocks
    blocks_events = {}  # sid -> dart text for JourneyEvent
    blocks_scenes = {}
    blocks_dhikr = {}
    blocks_scroll = {}
    for o in orders:
        ev = events[o]
        sid = slot_id(o)
        blocks_events[sid] = gen_journey_event(ev).rstrip() + '\n'
        blocks_scenes[sid] = gen_scene_config(ev).rstrip() + '\n'
        d = gen_dhikr(ev)
        if d: blocks_dhikr[sid] = d.rstrip() + '\n'
        s = gen_scroll(ev)
        if s: blocks_scroll[sid] = s.rstrip() + '\n'

    # ── m1_data.dart ──────────────────────────────────────────────────────
    path = DART_FILES['events']
    text = path.read_text(encoding='utf-8')

    # First: delete any old wrong-content shells from j_1_4_1 through j_1_4_14.
    # These are misplaced "Medina/Battle/etc." shells that were repurposed
    # at globalOrders 28-41 but actually belong to later master-list positions.
    # Their slot IDs are not in EXISTING_SLOTS — script generates new IDs for
    # those positions, so the shells are dead weight.
    needed_old_ids = set(EXISTING_SLOTS.values())
    shell_ids_to_delete = [f'j_1_4_{n}' for n in range(1, 15) if f'j_1_4_{n}' not in needed_old_ids]
    deleted_shells = 0
    for shell_id in shell_ids_to_delete:
        pat = re.compile(
            r"(?:  //[^\n]*\n)*"
            r"  JourneyEvent\(\s*\n"
            r"    id: '" + re.escape(shell_id) + r"',[\s\S]*?"
            r"^  \),\n",
            re.M
        )
        new_text, n = pat.subn('', text)
        if n > 0:
            text = new_text
            deleted_shells += n

    # Now replace existing JourneyEvent blocks (events 17-27 keep their slot IDs)
    replaced = 0
    inserted = 0
    insert_marker = '\n]; // end m1Events'
    for sid, block in blocks_events.items():
        pat = re.compile(
            r"(?:  //[^\n]*\n)*"
            r"  JourneyEvent\(\s*\n"
            r"    id: '" + re.escape(sid) + r"',[\s\S]*?"
            r"^  \),\n",
            re.M
        )
        m = pat.search(text)
        if m:
            text = text[:m.start()] + block + text[m.end():]
            replaced += 1
        else:
            # Insert before `]; // end m1Events`
            pos = text.find(insert_marker)
            if pos < 0:
                # Fallback: any closing `];` near end of file
                pos = text.rfind('\n];')
            if pos >= 0:
                text = text[:pos] + '\n' + block + text[pos:]
                inserted += 1
            else:
                print(f'  ! No insertion point for {sid} in {path.name}', file=sys.stderr)
    path.write_text(text, encoding='utf-8')
    summary['events'] = (replaced, inserted)
    summary['shells_deleted'] = (deleted_shells, 0)

    # ── scene_configs.dart ────────────────────────────────────────────────
    path = DART_FILES['scenes']
    text = path.read_text(encoding='utf-8')
    replaced = inserted = 0
    for sid, block in blocks_scenes.items():
        # Match: optional comment + `  'sid': SceneConfig(` ... up to closing `  ),\n`
        pat = re.compile(
            r"(?:  //[^\n]*\n)*"
            r"  '" + re.escape(sid) + r"': SceneConfig\([\s\S]*?\n  \),\n",
            re.M
        )
        m = pat.search(text)
        if m:
            text = text[:m.start()] + block + text[m.end():]
            replaced += 1
        else:
            # Insert before closing `};` of sceneConfigs map
            insert_pat = re.compile(r"\n\};\s*$", re.M)
            m_end = list(insert_pat.finditer(text))
            if m_end:
                pos = m_end[-1].start()
                text = text[:pos] + '\n' + block + text[pos:]
                inserted += 1
    path.write_text(text, encoding='utf-8')
    summary['scenes'] = (replaced, inserted)

    # ── dhikr_data.dart ───────────────────────────────────────────────────
    path = DART_FILES['dhikr']
    text = path.read_text(encoding='utf-8')
    replaced = inserted = 0
    for sid, block in blocks_dhikr.items():
        pat = re.compile(
            r"(?:  //[^\n]*\n)*"
            r"  '" + re.escape(sid) + r"': DhikrCard\([\s\S]*?\n  \),\n",
            re.M
        )
        m = pat.search(text)
        if m:
            text = text[:m.start()] + block + text[m.end():]
            replaced += 1
        else:
            insert_pat = re.compile(r"\n\};\s*$", re.M)
            m_end = list(insert_pat.finditer(text))
            if m_end:
                pos = m_end[-1].start()
                text = text[:pos] + '\n' + block + text[pos:]
                inserted += 1
    path.write_text(text, encoding='utf-8')
    summary['dhikr'] = (replaced, inserted)

    # ── scroll_entries.dart ───────────────────────────────────────────────
    path = DART_FILES['scroll']
    text = path.read_text(encoding='utf-8')
    replaced = inserted = 0
    for sid, block in blocks_scroll.items():
        pat = re.compile(
            r"  '" + re.escape(sid) + r"': ScrollEntry\([\s\S]*?\n  \),\n",
            re.M
        )
        m = pat.search(text)
        if m:
            text = text[:m.start()] + block + text[m.end():]
            replaced += 1
        else:
            insert_pat = re.compile(r"\n\};\s*$", re.M)
            m_end = list(insert_pat.finditer(text))
            if m_end:
                pos = m_end[-1].start()
                text = text[:pos] + '\n' + block + text[pos:]
                inserted += 1
    path.write_text(text, encoding='utf-8')
    summary['scroll'] = (replaced, inserted)

    return summary

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--range', default='all', help='e.g., 21-29 or all')
    p.add_argument('--summary', action='store_true', help='Just print parsed event summary')
    p.add_argument('--apply', action='store_true', help='Splice generated blocks into the dart files')
    p.add_argument('--stubs', action='store_true', help='Insert stub events for any 1-155 gap with no .md content')
    args = p.parse_args()

    events = collect_all_events()
    print(f'Parsed {len(events)} events from Downloads', file=sys.stderr)

    if args.range == 'all':
        orders = sorted(events.keys())
    else:
        a, b = args.range.split('-')
        orders = [o for o in sorted(events.keys()) if int(a) <= o <= int(b)]

    if args.summary:
        for o in orders:
            ev = events[o]
            blocked = ' ⚠️BLOCKED' if o in BLOCKED else ''
            print(f'  {o:3d}: {ev["title_en"][:55]:<55} | {len(ev["hotspots"])}h | layout {ev["layout"]} | {ev["_source_file"]}{blocked}')
        return

    events_out = []
    scenes_out = []
    dhikr_out = []
    scroll_out = []
    for o in orders:
        ev = events[o]
        events_out.append(gen_journey_event(ev))
        scenes_out.append(gen_scene_config(ev))
        d = gen_dhikr(ev)
        if d: dhikr_out.append(d)
        s = gen_scroll(ev)
        if s: scroll_out.append(s)

    (OUT_DIR / 'events_block.dart').write_text('\n'.join(events_out), encoding='utf-8')
    (OUT_DIR / 'scenes_block.dart').write_text('\n'.join(scenes_out), encoding='utf-8')
    (OUT_DIR / 'dhikr_block.dart').write_text('\n'.join(dhikr_out), encoding='utf-8')
    (OUT_DIR / 'scroll_block.dart').write_text('\n'.join(scroll_out), encoding='utf-8')

    print(f'Wrote {len(orders)} events to tools/output/', file=sys.stderr)
    print(f'  events_block.dart: {len(events_out)} entries', file=sys.stderr)
    print(f'  scenes_block.dart: {len(scenes_out)} entries', file=sys.stderr)
    print(f'  dhikr_block.dart:  {len(dhikr_out)} entries', file=sys.stderr)
    print(f'  scroll_block.dart: {len(scroll_out)} entries', file=sys.stderr)

    if args.apply:
        print('\nApplying to dart files...', file=sys.stderr)
        summary = apply_to_dart(events, orders)
        for k, (r, i) in summary.items():
            print(f'  {k:7}: {r} replaced, {i} inserted', file=sys.stderr)

    if args.stubs:
        # Insert stub events ONLY for known content gaps (37, 45, 46) where
        # Khaled has not written .md content yet. We do NOT touch events 1-14
        # which exist in the dart files but were hand-built (not in Downloads).
        KNOWN_GAPS = {37, 45, 46}
        existing_orders = set(events.keys())
        gaps = sorted(KNOWN_GAPS - existing_orders)
        if not gaps:
            print('No gaps to fill', file=sys.stderr)
            return
        print(f'\nGenerating stubs for {len(gaps)} gap orders: {gaps}', file=sys.stderr)
        # Build minimal stub event objects
        STUB_TITLES = {
            37: ('Mus\'ab ibn Umayr Sent to Medina', 'إرسال مصعب بن عمير إلى المدينة', 620, 'Medina'),
            45: ('Masjid Quba — First Mosque in Islam', 'مسجد قباء — أول مسجد في الإسلام', 622, 'Quba'),
            46: ('The First Friday Prayer', 'أول صلاة جمعة', 622, 'Wadi Ranuna'),
        }
        stubs = {}
        for o in gaps:
            title_en, title_ar, year, loc = STUB_TITLES.get(o, (f'Event {o}', f'الحدث {o}', 622, 'Mecca'))
            stubs[o] = {
                'order': o,
                'title_en': title_en,
                'title_ar': title_ar,
                'year': year,
                'location_en': loc,
                'layout': 'A',
                'witness': False,
                'hotspots': [],
                'verdict': {},
                'scroll': {},
                'dhikr': {},
                '_source_file': 'STUB',
            }
        summary = apply_to_dart(stubs, sorted(stubs.keys()))
        for k, (r, i) in summary.items():
            print(f'  {k:7}: {r} replaced, {i} inserted', file=sys.stderr)

if __name__ == '__main__':
    main()
