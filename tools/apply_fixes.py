"""
RawiJourney - Apply content fixes from RAWI_CONTENT_FIXES.md format.

Handles dhikr replacements (Part 2) and missing dhikr / scroll (Part 3).
Re-uses dart_str / slot_id helpers from generate_events.py.

Run:
  py tools/apply_fixes.py "C:/Users/LENOVO/Downloads/RAWI_CONTENT_FIXES.md"
"""
import re, sys, argparse
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')

# Import helpers from generate_events
sys.path.insert(0, str(Path(__file__).parent))
from generate_events import dart_str, dart_str_or_null, slot_id, DART_FILES

def parse_dhikr_section(text):
    """Parse a dhikr block. Returns dict with all fields."""
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
    """Same format as generate_events.gen_dhikr but standalone."""
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

def parse_fixes(text):
    """Returns ({order: dhikr_dict}, {order: (en, ar)} for scrolls)."""
    dhikrs = {}
    scrolls = {}

    # Split into "## E<N> ..." or "# PART <N>" sections to avoid bleed.
    # PART 2: dhikr replacements -- sections start with `## E34 — Replace`
    # PART 3: missing dhikr/scroll -- sections start with `## E43 — Desert Journey`
    # Both use the same dhikr block format inside.
    sections = re.split(r'\n##\s+', text)
    for sec in sections:
        m_order = re.match(r'E(\d+)', sec)
        if not m_order: continue
        order = int(m_order.group(1))

        # Check for dhikr block
        if '**Arabic:**' in sec or '**Arabic:* *' in sec:
            d = parse_dhikr_section(sec)
            if d.get('arabic'):
                dhikrs[order] = d

        # Check for missing scroll entry (E43)
        m_scroll = re.search(
            r'###\s*E\d+\s*[—–\-]\s*Missing Scroll Entry\s*\n\*\*EN:\*\*\s*([^\n]+)\s*\n\*\*AR:\*\*\s*([^\n]+)',
            sec
        )
        if m_scroll:
            scrolls[order] = (m_scroll.group(1).strip(), m_scroll.group(2).strip())

    return dhikrs, scrolls

def apply_dhikr_changes(dhikrs):
    path = DART_FILES['dhikr']
    text = path.read_text(encoding='utf-8')
    replaced = inserted = 0
    for order, d in sorted(dhikrs.items()):
        sid = slot_id(order)
        block = gen_dhikr_block(sid, d)

        # Try to replace existing entry
        pat = re.compile(
            r"(?:  //[^\n]*\n)*"
            r"  '" + re.escape(sid) + r"': DhikrCard\([\s\S]*?\n  \),\n",
            re.M
        )
        m = pat.search(text)
        if m:
            text = text[:m.start()] + block + text[m.end():]
            replaced += 1
            print(f'  E{order} ({sid}): replaced dhikr', file=sys.stderr)
        else:
            # Insert before closing `};`
            insert_pat = re.compile(r"\n\};\s*$", re.M)
            m_end = list(insert_pat.finditer(text))
            if m_end:
                pos = m_end[-1].start()
                text = text[:pos] + '\n' + block + text[pos:]
                inserted += 1
                print(f'  E{order} ({sid}): inserted dhikr', file=sys.stderr)
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
            print(f'  E{order} ({sid}): replaced scroll', file=sys.stderr)
        else:
            insert_pat = re.compile(r"\n\};\s*$", re.M)
            m_end = list(insert_pat.finditer(text))
            if m_end:
                pos = m_end[-1].start()
                text = text[:pos] + '\n' + block + text[pos:]
                inserted += 1
                print(f'  E{order} ({sid}): inserted scroll', file=sys.stderr)
    path.write_text(text, encoding='utf-8')
    return replaced, inserted

def main():
    p = argparse.ArgumentParser()
    p.add_argument('fixes_file')
    args = p.parse_args()

    text = Path(args.fixes_file).read_text(encoding='utf-8')
    dhikrs, scrolls = parse_fixes(text)

    print(f'Parsed {len(dhikrs)} dhikr changes, {len(scrolls)} scroll changes', file=sys.stderr)
    print('\nDhikr changes:', file=sys.stderr)
    r, i = apply_dhikr_changes(dhikrs)
    print(f'  total: {r} replaced, {i} inserted', file=sys.stderr)

    if scrolls:
        print('\nScroll changes:', file=sys.stderr)
        r, i = apply_scroll_changes(scrolls)
        print(f'  total: {r} replaced, {i} inserted', file=sys.stderr)

if __name__ == '__main__':
    main()
