"""
RawiJourney - Backfill Arabic options for the M2 chapter review quiz.

Reads RAWI_M2_QUIZ_AR_FIX_1.md (10 `## Question N` blocks each with
`**A AR:** opt1 ✅ | opt2 | opt3`) and rewrites only the M2 block's
optionsAr lines in lib/data/chapter_reviews.dart.

The original M2 quiz format only listed English options, so the
generator mirrored EN into optionsAr as a placeholder. This script
replaces the placeholder.
"""
import re, sys
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')

sys.path.insert(0, str(Path(__file__).parent))
from generate_events import dart_str

FIX_FILE = Path('C:/Users/LENOVO/Downloads/RAWI_M2_QUIZ_AR_FIX_1.md')
DART = Path('d:/Rawi_Journey/lib/data/chapter_reviews.dart')


def parse_ar_options():
    text = FIX_FILE.read_text(encoding='utf-8')
    # ## Question N\n**A AR:** opt1 ✅ | opt2 | opt3
    blocks = re.findall(r'##\s*Question\s+(\d+)\s*\n\*\*A AR:\*\*\s*(.+)', text)
    out = {}
    for n, line in blocks:
        opts = [o.strip().replace('✅', '').strip() for o in line.split('|')]
        out[int(n)] = opts
    return out


def main():
    ar_options = parse_ar_options()
    print(f'Parsed {len(ar_options)} questions from {FIX_FILE.name}', file=sys.stderr)
    if len(ar_options) != 10:
        print(f'  ! expected 10 questions, got {len(ar_options)}', file=sys.stderr)
        return

    text = DART.read_text(encoding='utf-8')

    # Locate M2 block
    m2_start = text.find('afterEventOrder: 82')
    m2_end = text.find('afterEventOrder: 120')
    if m2_start < 0 or m2_end < 0:
        print('  ! M2 block not found in chapter_reviews.dart', file=sys.stderr)
        return
    m2 = text[m2_start:m2_end]

    # Find all optionsAr: lines inside M2 (in order)
    opt_pat = re.compile(r"      optionsAr: \[[^\]]*\],\n")
    matches = list(opt_pat.finditer(m2))
    if len(matches) != 10:
        print(f'  ! expected 10 optionsAr lines in M2, found {len(matches)}', file=sys.stderr)
        return

    # Replace in REVERSE order so offsets stay valid
    new_m2 = m2
    for i in range(9, -1, -1):
        opts = ar_options[i + 1]  # 1-indexed
        new_line = '      optionsAr: [' + ', '.join(dart_str(o) for o in opts) + '],\n'
        m = matches[i]
        new_m2 = new_m2[:m.start()] + new_line + new_m2[m.end():]

    new_text = text[:m2_start] + new_m2 + text[m2_end:]
    DART.write_text(new_text, encoding='utf-8')
    print(f'Wrote {DART.name}: 10 M2 optionsAr lines updated', file=sys.stderr)


if __name__ == '__main__':
    main()
