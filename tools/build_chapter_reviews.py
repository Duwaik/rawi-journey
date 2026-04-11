"""
RawiJourney - Build chapter_reviews.dart from existing content packs.

Parses 4 chapter review quizzes from Khaled's content files and emits
the full lib/data/chapter_reviews.dart file.

Sources:
  - M1 (after E47): RAWI_EVENTS_048_050_REVIEW.md   (table format)
  - M2 (after E82): RAWI_EVENTS_081_085.md          (pipe format)
  - M3 (after E120): RAWI_EVENTS_116_120.md         (multiline format)
  - M4 (after E155): RAWI_EVENTS_151_155.md         (multiline format)
"""
import re, sys
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')

sys.path.insert(0, str(Path(__file__).parent))
from generate_events import dart_str

DOWNLOADS = Path('C:/Users/LENOVO/Downloads')
OUT = Path('d:/Rawi_Journey/lib/data/chapter_reviews.dart')

REVIEWS = [
    {
        'after': 47,
        'title_en': 'M1 Review — The Prophetic Dawn',
        'title_ar': 'مراجعة — الفجر النبوي',
        'file': 'RAWI_EVENTS_048_050_REVIEW.md',
        'format': 'table',
    },
    {
        'after': 82,
        'title_en': 'M2 Review — The Community Rises',
        'title_ar': 'مراجعة — ينهض المجتمع',
        'file': 'RAWI_EVENTS_081_085.md',
        'format': 'pipe',
    },
    {
        'after': 120,
        'title_en': 'M3 Review — The Turning Tide',
        'title_ar': 'مراجعة — المنعطف',
        'file': 'RAWI_EVENTS_116_120.md',
        'format': 'multiline',
    },
    {
        'after': 155,
        'title_en': 'M4 Review — The Final Chapter',
        'title_ar': 'مراجعة — الفصل الأخير',
        'file': 'RAWI_EVENTS_151_155.md',
        'format': 'multiline',
    },
]


def find_quiz_section(text):
    """Locate the section after 'CHAPTER REVIEW' or 'Chapter Review' marker."""
    m = re.search(r'(?:#{1,3}\s*[🏁\s]*)?(?:M\d+\s+)?(?:CHAPTER\s+REVIEW|Chapter\s+Review).*$', text, re.M | re.I)
    if not m: return None
    return text[m.end():]


def parse_table_format(quiz_text):
    """Format: ### Q1 / **EN:** / **AR:** / table with options."""
    questions = []
    # Split on ### Q<n>
    blocks = re.split(r'\n###\s*Q\d+\s*\n', quiz_text)
    for block in blocks[1:]:  # skip preamble before first Q
        # Stop at next major section
        m_stop = re.search(r'\n---\s*\n', block)
        if m_stop: block = block[:m_stop.start()]

        m_en = re.search(r'\*\*EN:\*\*\s*(.+)', block)
        m_ar = re.search(r'\*\*AR:\*\*\s*(.+)', block)
        if not (m_en and m_ar): continue

        rows = re.findall(r'^\|\s*\d+\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|\n]+?)\s*\|', block, re.M)
        opts_en, opts_ar, correct = [], [], -1
        for i, (en, ar, mark) in enumerate(rows):
            if en.lower() in ('en', '---'): continue
            opts_en.append(en.strip())
            opts_ar.append(ar.strip())
            if '✅' in mark: correct = len(opts_en) - 1
        if not opts_en: continue
        questions.append({
            'q_en': m_en.group(1).strip(),
            'q_ar': m_ar.group(1).strip(),
            'opts_en': opts_en,
            'opts_ar': opts_ar,
            'correct': max(0, correct),
        })
    return questions


def parse_pipe_format(quiz_text):
    """Format: ### Question N / **Q EN:** / **Q AR:** / **A:** opt1 ✅ | opt2 | opt3"""
    questions = []
    blocks = re.split(r'\n###\s*Question\s+\d+\s*\n', quiz_text)
    for block in blocks[1:]:
        m_stop = re.search(r'\n(?:---|##\s|#\s)', block)
        if m_stop: block = block[:m_stop.start()]

        m_qen = re.search(r'\*\*Q\s*EN:\*\*\s*(.+)', block)
        m_qar = re.search(r'\*\*Q\s*AR:\*\*\s*(.+)', block)
        m_a = re.search(r'\*\*A:\*\*\s*(.+)', block)
        if not (m_qen and m_qar and m_a): continue

        opts_raw = m_a.group(1).split('|')
        opts_en, opts_ar, correct = [], [], -1
        for i, opt in enumerate(opts_raw):
            opt = opt.strip()
            if '✅' in opt:
                correct = i
                opt = opt.replace('✅', '').strip()
            # In pipe format, only EN options are listed (no separate AR)
            opts_en.append(opt)
        # Pipe format does not give per-option AR — leave as a placeholder
        # by mirroring EN. Caller can backfill if needed.
        opts_ar = list(opts_en)
        if not opts_en: continue
        questions.append({
            'q_en': m_qen.group(1).strip(),
            'q_ar': m_qar.group(1).strip(),
            'opts_en': opts_en,
            'opts_ar': opts_ar,
            'correct': max(0, correct),
        })
    return questions


def parse_multiline_format(quiz_text):
    """Format: ### Question N / **EN:** / **AR:** /
    **A EN:** ... | **A AR:** ...
    **B EN:** ... | **B AR:** ...
    **C EN:** ... | **C AR:** ..."""
    questions = []
    blocks = re.split(r'\n###\s*Question\s+\d+\s*\n', quiz_text)
    for block in blocks[1:]:
        m_stop = re.search(r'\n(?:---|##\s|#\s)', block)
        if m_stop: block = block[:m_stop.start()]

        m_en = re.search(r'\*\*EN:\*\*\s*(.+)', block)
        m_ar = re.search(r'\*\*AR:\*\*\s*(.+)', block)
        if not (m_en and m_ar): continue

        opts_en, opts_ar, correct = [], [], -1
        for i, letter in enumerate(['A', 'B', 'C']):
            m_oen = re.search(rf'\*\*{letter}\s*EN:\*\*\s*([^|]+?)\s*\|', block)
            m_oar = re.search(rf'\*\*{letter}\s*AR:\*\*\s*(.+)', block)
            if not (m_oen and m_oar): continue
            en_t = m_oen.group(1).strip()
            ar_t = m_oar.group(1).strip()
            if '✅' in en_t or '✅' in ar_t:
                correct = i
            opts_en.append(en_t.replace('✅', '').strip())
            opts_ar.append(ar_t.replace('✅', '').strip())
        if not opts_en: continue
        questions.append({
            'q_en': m_en.group(1).strip(),
            'q_ar': m_ar.group(1).strip(),
            'opts_en': opts_en,
            'opts_ar': opts_ar,
            'correct': max(0, correct),
        })
    return questions


PARSERS = {
    'table': parse_table_format,
    'pipe': parse_pipe_format,
    'multiline': parse_multiline_format,
}


def gen_review_dart(review, questions):
    qs_dart = []
    for q in questions:
        opts_en_str = '[' + ', '.join(dart_str(o) for o in q['opts_en']) + ']'
        opts_ar_str = '[' + ', '.join(dart_str(o) for o in q['opts_ar']) + ']'
        qs_dart.append(
            '    ReviewQuestion(\n'
            f'      question: {dart_str(q["q_en"])},\n'
            f'      questionAr: {dart_str(q["q_ar"])},\n'
            f'      options: {opts_en_str},\n'
            f'      optionsAr: {opts_ar_str},\n'
            f'      correctIndex: {q["correct"]},\n'
            f"      explanation: '',\n"
            f"      explanationAr: '',\n"
            f"      sourceRef: '',\n"
            f"      sourceRefAr: '',\n"
            '    ),\n'
        )
    return (
        '  ChapterReview(\n'
        f'    afterEventOrder: {review["after"]},\n'
        f'    eraTitle: {dart_str(review["title_en"])},\n'
        f'    eraTitleAr: {dart_str(review["title_ar"])},\n'
        '    questions: [\n'
        + ''.join(qs_dart) +
        '    ],\n'
        '  ),\n'
    )


def main():
    all_reviews = []
    for review in REVIEWS:
        path = DOWNLOADS / review['file']
        if not path.exists():
            print(f'  ! {path.name} not found, skipping E{review["after"]}', file=sys.stderr)
            continue
        text = path.read_text(encoding='utf-8')
        quiz_text = find_quiz_section(text)
        if not quiz_text:
            print(f'  ! No quiz section in {path.name}', file=sys.stderr)
            continue
        parser = PARSERS[review['format']]
        questions = parser(quiz_text)
        print(f'  E{review["after"]} ({review["format"]}): {len(questions)} questions', file=sys.stderr)
        all_reviews.append((review, questions))

    # Emit chapter_reviews.dart
    out = (
        "import '../models/chapter_review.dart';\n\n"
        "/// Chapter review quizzes — appear after the final event of each era.\n"
        "/// Generated by tools/build_chapter_reviews.py from Khaled's content packs.\n"
        "///\n"
        "/// Reviews appear after Events: 14 (TBD), 47, 82, 120, 155\n"
        "const List<ChapterReview> chapterReviews = [\n"
    )
    for review, questions in all_reviews:
        out += gen_review_dart(review, questions)
    out += (
        "];\n\n"
        "/// Get the chapter review for a given event, if any.\n"
        "ChapterReview? getChapterReviewAfter(int globalOrder) {\n"
        "  for (final r in chapterReviews) {\n"
        "    if (r.afterEventOrder == globalOrder) return r;\n"
        "  }\n"
        "  return null;\n"
        "}\n"
    )
    OUT.write_text(out, encoding='utf-8')
    total = sum(len(qs) for _, qs in all_reviews)
    print(f'\nWrote {OUT.name}: {len(all_reviews)} reviews, {total} questions total', file=sys.stderr)


if __name__ == '__main__':
    main()
