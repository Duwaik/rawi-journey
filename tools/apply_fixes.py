"""
RawiJourney - Apply content fixes from RAWI_*_FIXES_*.md files.

Handles all known fix-pack formats:
  - Section D: missing verdict questions       (D EN / D AR / Option X EN+AR / Explanation)
  - Section E: missing DYK entries             (DYK 1 EN / DYK 2 EN per event)
  - Section F: dhikr replacements              (Arabic / Transliteration / Meaning / ...)
  - Missing scroll entries                     (### E<N> - Missing Scroll Entry)
  - PART 2/3 from RAWI_CONTENT_FIXES.md        (legacy format, still supported)

Also: hotspot DYK insertion targets the empty hotspot positions in
scene_configs.dart, following the established pattern (slots 2 and 4
for events with no DYK; the lone empty slot for 1-DYK events).

Run:
  py tools/apply_fixes.py "C:/Users/LENOVO/Downloads/RAWI_AUDIT_FIXES_PART2.md"
"""
import re, sys, argparse
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')

sys.path.insert(0, str(Path(__file__).parent))
from generate_events import dart_str, dart_str_or_null, slot_id, DART_FILES


# ───────── Dhikr block helpers (unchanged from before) ─────────────────────
def parse_dhikr_section(text):
    def f(name):
        m = re.search(rf'\*\*{re.escape(name)}:?\*\*\s*([^\n]+)', text)
        return m.group(1).strip() if m else ''
    return {
        'arabic': f('Arabic'),
        'transliteration': f('Transliteration'),
        'english': f('Meaning') or f('English'),
        'count': f('Count'),
        'when': f('When to say it') or f('When to say'),
        'promise_en': f('The Promise EN') or f('The Promise'),
        'promise_ar': f('The Promise AR'),
        'source': f('Source'),
    }


def gen_dhikr_block(sid, d):
    return (
        f'  {dart_str(sid)}: DhikrCard(\n'
        f'    id: {dart_str(sid)},\n'
        f'    arabicText: {dart_str(d.get("arabic", ""))},\n'
        f'    transliteration: {dart_str(d.get("transliteration", ""))},\n'
        f'    meaningEn: {dart_str(d.get("english", ""))},\n'
        f'    meaningAr: {dart_str(d.get("arabic", ""))},\n'
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


def gen_scroll_block(sid, order, en, ar):
    return (
        f'  {dart_str(sid)}: ScrollEntry(\n'
        f'    eventId: {dart_str(sid)},\n'
        f'    globalOrder: {order},\n'
        f'    lineEn: {dart_str(en)},\n'
        f'    lineAr: {dart_str(ar)},\n'
        '  ),\n'
    )


# ───────── Pack-level parser ───────────────────────────────────────────────
def split_event_sections(text):
    """Yield (order, body_text) pairs for each `## E<N>` block in any section.
    Honors `# SECTION X:` boundaries and `---` separators."""
    sections = re.split(r'\n##\s+', text)
    for sec in sections:
        m_order = re.match(r'E(\d+)\b', sec)
        if not m_order: continue
        yield int(m_order.group(1)), sec


def parse_dhikrs(text):
    """Returns {order: dhikr_dict}. Used for Section F replacements and
    legacy PART 2/3 dhikr blocks."""
    out = {}
    for order, sec in split_event_sections(text):
        # Only consider dhikr blocks where Arabic + Transliteration both present
        if '**Arabic:**' in sec and '**Transliteration:**' in sec:
            d = parse_dhikr_section(sec)
            if d.get('arabic'):
                out[order] = d
    return out


def parse_scrolls(text):
    """Returns {order: (en, ar)} for missing scroll entries (legacy format)."""
    out = {}
    for order, sec in split_event_sections(text):
        m = re.search(
            r'###\s*E\d+\s*[—–\-]\s*Missing Scroll Entry\s*\n\*\*EN:\*\*\s*([^\n]+)\s*\n\*\*AR:\*\*\s*([^\n]+)',
            sec
        )
        if m:
            out[order] = (m.group(1).strip(), m.group(2).strip())
    return out


def parse_questions(text):
    """Section D format:
        ## E44 — Title
        **Question EN:** ...
        **Question AR:** ...
        **Option A EN:** opt | **Option A AR:** opt
        **Option B EN:** opt ✅ | **Option B AR:** opt ✅
        **Option C EN:** opt | **Option C AR:** opt
        **Explanation EN:** ...
        **Explanation AR:** ...
        **Source:** ...
    """
    out = {}
    for order, sec in split_event_sections(text):
        m_qen = re.search(r'\*\*Question EN:\*\*\s*(.+)', sec)
        m_qar = re.search(r'\*\*Question AR:\*\*\s*(.+)', sec)
        if not (m_qen and m_qar): continue

        opts_en, opts_ar, correct = [], [], -1
        for i, letter in enumerate(['A', 'B', 'C']):
            m_oen = re.search(rf'\*\*Option {letter} EN:\*\*\s*([^|]+?)\s*\|', sec)
            m_oar = re.search(rf'\*\*Option {letter} AR:\*\*\s*(.+)', sec)
            if not (m_oen and m_oar): continue
            en_t = m_oen.group(1).strip()
            ar_t = m_oar.group(1).strip()
            if '✅' in en_t or '✅' in ar_t:
                correct = i
            opts_en.append(en_t.replace('✅', '').strip())
            opts_ar.append(ar_t.replace('✅', '').strip())
        if not opts_en: continue

        m_exp_en = re.search(r'\*\*Explanation EN:\*\*\s*(.+)', sec)
        m_exp_ar = re.search(r'\*\*Explanation AR:\*\*\s*(.+)', sec)
        m_src = re.search(r'\*\*Source:\*\*\s*(.+)', sec)
        out[order] = {
            'q_en': m_qen.group(1).strip(),
            'q_ar': m_qar.group(1).strip(),
            'opts_en': opts_en,
            'opts_ar': opts_ar,
            'correct': max(0, correct),
            'exp_en': m_exp_en.group(1).strip() if m_exp_en else '',
            'exp_ar': m_exp_ar.group(1).strip() if m_exp_ar else '',
            'source': m_src.group(1).strip() if m_src else '',
        }
    return out


def parse_dyks(text):
    """Section E format:
        ## E30 — Title
        **DYK 1 EN:** ...
        **DYK 1 AR:** ...
        **Source:** ...    <- shared or per-DYK
        **DYK 2 EN:** ...
        **DYK 2 AR:** ...
        **Source:** ...
    Returns {order: [(en, ar, source), (en, ar, source)?]}.
    """
    out = {}
    for order, sec in split_event_sections(text):
        # Find each "DYK <n> EN" and the AR + source that follow
        dyks = []
        for n in [1, 2]:
            m_en = re.search(rf'\*\*DYK\s*{n}\s*EN:\*\*\s*(.+)', sec)
            m_ar = re.search(rf'\*\*DYK\s*{n}\s*AR:\*\*\s*(.+)', sec)
            if not (m_en and m_ar): continue
            # Source line that follows this DYK pair (closest **Source:** after m_ar)
            tail = sec[m_ar.end():]
            m_src = re.search(r'\*\*Source:\*\*\s*([^\n]+)', tail)
            src = m_src.group(1).strip() if m_src else ''
            dyks.append((m_en.group(1).strip(), m_ar.group(1).strip(), src))
        if dyks:
            out[order] = dyks
    return out


# ───────── Apply functions ─────────────────────────────────────────────────
def apply_dhikr_changes(dhikrs):
    path = DART_FILES['dhikr']
    text = path.read_text(encoding='utf-8')
    replaced = inserted = 0
    for order, d in sorted(dhikrs.items()):
        sid = slot_id(order)
        block = gen_dhikr_block(sid, d)
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
    return replaced, inserted


def apply_scroll_changes(scrolls):
    path = DART_FILES['scroll']
    text = path.read_text(encoding='utf-8')
    replaced = inserted = 0
    for order, (en, ar) in sorted(scrolls.items()):
        sid = slot_id(order)
        block = gen_scroll_block(sid, order, en, ar)
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
    return replaced, inserted


def apply_question_changes(questions):
    """Replaces `questions: const []` with a full JourneyQuestion block in m1_data.dart."""
    path = DART_FILES['events']
    text = path.read_text(encoding='utf-8')
    fixed = 0
    for order, q in sorted(questions.items()):
        sid = slot_id(order)
        opts_en_str = '[\n          ' + ',\n          '.join(dart_str(o) for o in q['opts_en']) + ',\n        ]'
        opts_ar_str = '[\n          ' + ',\n          '.join(dart_str(o) for o in q['opts_ar']) + ',\n        ]'
        new_questions = (
            '    questions: [\n'
            '      JourneyQuestion(\n'
            f'        id: {dart_str("q_" + sid.replace("j_", ""))},\n'
            f'        question: {dart_str(q["q_en"])},\n'
            f'        questionAr: {dart_str(q["q_ar"])},\n'
            f'        options: {opts_en_str},\n'
            f'        optionsAr: {opts_ar_str},\n'
            f'        correctIndex: {q["correct"]},\n'
            f'        explanation: {dart_str(q["exp_en"])},\n'
            f'        explanationAr: {dart_str(q["exp_ar"])},\n'
            f'        sourceRef: {dart_str(q["source"])},\n'
            f'        sourceRefAr: {dart_str(q["source"])},\n'
            '      ),\n'
            '    ],'
        )

        # Find this event's JourneyEvent block, then replace its `questions: const []` line
        pat = re.compile(
            r"(  JourneyEvent\(\s*\n\s*id: '" + re.escape(sid) + r"',[\s\S]*?)"
            r"    questions: const \[\],",
            re.M
        )
        m = pat.search(text)
        if m:
            text = text[:m.start()] + m.group(1) + new_questions + text[m.end():]
            fixed += 1
        else:
            print(f'  ! E{order} ({sid}): no `questions: const []` found', file=sys.stderr)
    path.write_text(text, encoding='utf-8')
    return fixed


def apply_dyk_changes(dyks):
    """Insert didYouKnow + didYouKnowAr into hotspots that lack them.

    Strategy:
      - For each event, locate its SceneConfig in scene_configs.dart.
      - Walk its hotspots. Build a list of (start, end, has_dyk) per hotspot.
      - For events with 2 DYKs: target hotspots 2 and 4 (1-indexed).
      - For events with 1 DYK: target the first hotspot WITHOUT a DYK.
      - Insertion appends `,\n        didYouKnow: '...',\n        didYouKnowAr: '...'`
        right before the hotspot's closing `)`.
    """
    path = DART_FILES['scenes']
    text = path.read_text(encoding='utf-8')
    fixed = 0

    for order, dyk_list in sorted(dyks.items()):
        sid = slot_id(order)

        # Locate the SceneConfig block
        cfg_pat = re.compile(
            r"^(  '" + re.escape(sid) + r"': SceneConfig\()([\s\S]*?)(\n  \),)",
            re.M
        )
        m_cfg = cfg_pat.search(text)
        if not m_cfg:
            print(f'  ! E{order} ({sid}): SceneConfig not found', file=sys.stderr)
            continue
        cfg_body = m_cfg.group(2)

        # Find each hotspot block: `      SceneHotspot(...)`. We need each
        # hotspot's full extent (multi-line until closing `)`) and whether it
        # already has didYouKnow.
        hotspot_starts = [(m.start(), m.end()) for m in re.finditer(r'      SceneHotspot\(', cfg_body)]
        if not hotspot_starts:
            print(f'  ! E{order}: no hotspots in SceneConfig', file=sys.stderr)
            continue

        # Compute each hotspot's full body using paren depth tracking
        hotspots = []  # list of (start_in_cfg, end_in_cfg, has_dyk)
        for hs_start, _ in hotspot_starts:
            depth = 0
            i = hs_start
            in_string = False
            esc = False
            while i < len(cfg_body):
                c = cfg_body[i]
                if esc:
                    esc = False
                elif c == '\\':
                    esc = True
                elif c == "'" and not esc:
                    in_string = not in_string
                elif not in_string:
                    if c == '(':
                        depth += 1
                    elif c == ')':
                        depth -= 1
                        if depth == 0:
                            i += 1
                            break
                i += 1
            hs_end = i
            body = cfg_body[hs_start:hs_end]
            has_dyk = bool(re.search(r"didYouKnow:\s*'[^']", body))
            hotspots.append((hs_start, hs_end, has_dyk))

        # Pick target hotspot indices for the new DYKs.
        # Convention: DYK lives on hotspots 2 and 4 (1-indexed).
        # Preference order for filling a single empty slot: 4, 2, 3, 1.
        n_dyks = len(dyk_list)
        target_indices = []
        empty_indices = [i for i, (_, _, has_dyk) in enumerate(hotspots) if not has_dyk]
        if n_dyks == 2 and len(hotspots) >= 4:
            target_indices = [1, 3]  # hotspots 2 and 4
        elif n_dyks == 1:
            preferred_order = [3, 1, 2, 0]  # 4, 2, 3, 1 (1-indexed)
            for idx in preferred_order:
                if idx in empty_indices:
                    target_indices = [idx]
                    break
        else:
            target_indices = empty_indices[:n_dyks]

        if len(target_indices) != n_dyks:
            print(f'  ! E{order}: needed {n_dyks} slots, found {len(target_indices)}', file=sys.stderr)
            continue

        # Insert DYKs in REVERSE order so earlier offsets stay valid
        new_cfg_body = cfg_body
        pairs = sorted(zip(target_indices, dyk_list), key=lambda p: -p[0])
        for tgt_idx, (en, ar, _src) in pairs:
            hs_start, hs_end, has_dyk = hotspots[tgt_idx]
            if has_dyk:
                print(f'  ! E{order}: hotspot {tgt_idx+1} already has DYK, skipping', file=sys.stderr)
                continue
            # Build the DYK insertion. Comma + indented fields, before the closing `)`.
            insertion = (
                ',\n        didYouKnow: ' + dart_str(en) +
                ',\n        didYouKnowAr: ' + dart_str(ar)
            )
            # Find the closing `)` of this hotspot in the CURRENT body
            # (offsets still valid because we go reverse)
            # The hotspot ends at hs_end-1 == ')'
            new_cfg_body = new_cfg_body[:hs_end - 1] + insertion + new_cfg_body[hs_end - 1:]

        # Replace cfg_body in the full text
        text = text[:m_cfg.start()] + m_cfg.group(1) + new_cfg_body + m_cfg.group(3) + text[m_cfg.end():]
        fixed += 1

    path.write_text(text, encoding='utf-8')
    return fixed


def main():
    p = argparse.ArgumentParser()
    p.add_argument('fixes_file')
    args = p.parse_args()

    text = Path(args.fixes_file).read_text(encoding='utf-8')

    # Parse all sections (the same file may contain any subset)
    questions = parse_questions(text)
    dyks = parse_dyks(text)
    dhikrs = parse_dhikrs(text)
    scrolls = parse_scrolls(text)

    print(f'Parsed: {len(questions)} questions, {len(dyks)} DYK events, {len(dhikrs)} dhikr, {len(scrolls)} scrolls', file=sys.stderr)

    if questions:
        print('\nVerdict questions:', file=sys.stderr)
        n = apply_question_changes(questions)
        print(f'  {n} questions filled', file=sys.stderr)

    if dyks:
        print('\nDYK insertions:', file=sys.stderr)
        n = apply_dyk_changes(dyks)
        total_dyks = sum(len(v) for v in dyks.values())
        print(f'  {n} events updated ({total_dyks} DYK entries)', file=sys.stderr)

    if dhikrs:
        print('\nDhikr changes:', file=sys.stderr)
        r, i = apply_dhikr_changes(dhikrs)
        print(f'  {r} replaced, {i} inserted', file=sys.stderr)

    if scrolls:
        print('\nScroll changes:', file=sys.stderr)
        r, i = apply_scroll_changes(scrolls)
        print(f'  {r} replaced, {i} inserted', file=sys.stderr)


if __name__ == '__main__':
    main()
