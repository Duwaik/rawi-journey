"""
Rawi — Edge TTS Voice Over Generator
Generates MP3 files for discovery panel fragments and companion speech.
Gender-aware: male and female voice variants.

Usage: python tools/generate_vo.py
"""

import asyncio
import os
import edge_tts

# Voice pairs (gender-aware)
VOICES = {
    'en_m': 'en-GB-RyanNeural',
    'en_f': 'en-GB-SoniaNeural',
    'ar_m': 'ar-SY-LaithNeural',
    'ar_f': 'ar-SY-AmanyNeural',
}

OUT_VO = 'assets/audio/vo'
OUT_COMP = 'assets/audio/companion'

# ── Event fragments ──────────────────────────────────────────────────────────

FRAGMENTS = {
    # Event 1 — FULL text matching scene_configs.dart
    'event1_kaabah': {
        'en': "The Ka'bah stands — built by Ibrahim, peace be upon him, and his son Ismail, peace be upon him, as a house of the One God. That memory lingers in the stones, even as 360 idols press against them from every side. Something is coming. You can feel it in the desert wind.",
        'ar': 'الكعبة تقف — بناها إبراهيم عليه السلام وابنه إسماعيل عليه السلام بيتاً للإله الواحد. تلك الذكرى لا تزال حيّة في الحجارة، حتى وإن تزاحمت ثلاثمئة وستون صنماً حولها. شيء ما قادم. تحسّه في ريح الصحراء.',
    },
    'event1_idols': {
        'en': "Three hundred and sixty stone figures watch you with empty eyes. The air is thick with incense smoke drifting from the shrines that crowd around the ancient house. Each tribe has placed its god here — as if proximity to the Ka'bah could grant them truth.",
        'ar': 'ثلاثمئة وستون تمثالاً حجرياً يحدّقون فيك بعيون فارغة. الهواء ثقيل بدخان البخور المتصاعد من المعابد المتراصة حول البيت العتيق. كل قبيلة وضعت إلهها هنا — وكأن القرب من الكعبة يمنحهم الحقيقة.',
    },
    'event1_poet': {
        'en': "A poet recites verses of breathtaking beauty about honor and courage — while a few streets away, a man buries his newborn daughter in the sand without a word. The world moves in contradictions.",
        'ar': 'شاعر ينشد أبياتاً خلابة عن الشرف والشجاعة — بينما على بعد أزقة قليلة، رجل يدفن ابنته الوليدة في الرمال دون كلمة. العالم يتحرك في تناقضات.',
    },
    'event1_merchants': {
        'en': "Merchants haggle over silk and spices on trade routes stretching from Yemen to Syria — while the poor beg at the Ka'bah walls, invisible to those who pass. Wealth flows, but justice does not.",
        'ar': 'تجّار يساومون على الحرير والتوابل في طرق تجارية تمتد من اليمن إلى الشام — بينما الفقراء يستجدون عند جدران الكعبة، لا يراهم أحد. المال يتدفق، لكن العدل لا.',
    },
    # Event 2 — FULL text matching scene_configs.dart
    'event2_army': {
        'en': "The horizon to the south is dark with dust. Abraha al-Ashram — the ruler of Yemen — marches with war elephants and thousands of soldiers. His mission: destroy the Ka'bah and redirect the Arabs' pilgrimage to a grand church he built in Sana'a.",
        'ar': 'الأفق جنوباً مظلم بالغبار. أبرهة الأشرم — حاكم اليمن — يزحف بأفيال حرب وآلاف الجنود. مهمته: تدمير الكعبة وتحويل حج العرب إلى كنيسة فخمة بناها في صنعاء.',
    },
    'event2_muttalib': {
        'en': "\"I am the lord of the camels. The Ka'bah has a Lord who will protect it.\" Abd al-Muttalib stood before Abraha and asked only for his camels — not for the sacred house. He told his people to withdraw to the mountains.",
        'ar': 'أنا ربّ الإبل. وللبيت ربّ يحميه. وقف عبد المطلب أمام أبرهة ولم يطلب إلا إبله — لا البيت الحرام. وأمر قومه بالانسحاب إلى الجبال.',
    },
    'event2_elephants': {
        'en': "The elephants halt at the boundary of the sacred precinct and refuse to move forward. The great beasts kneel, no matter how hard their riders strike. Something unseen holds them back.",
        'ar': 'الأفيال تتوقف عند حدود الحرم وترفض التحرك. الحيوانات الضخمة تركع، مهما ضربها فرسانها. شيء خفي يمنعها.',
    },
    'event2_birds': {
        'en': "The sky darkens — not with clouds, but with birds. Thousands of them, resembling hawks, each carrying three stones of baked clay. The impossible unfolds before your eyes. This is divine protection.",
        'ar': 'السماء تُظلم — لا بالغيوم، بل بالطيور. آلاف منها، تشبه الصقور، كل طائر يحمل ثلاثة أحجار من سجيل. المستحيل يتكشّف أمام عينيك. هذه حماية إلهية.',
    },
    # Event 3 — FULL text matching scene_configs.dart
    'event3_flood': {
        'en': "The rains came without warning — a torrent that swept through the valley and struck the ancient house. Walls crumbled. Stones shifted. The Ka'bah, already weakened by centuries, could no longer stand as it was. The tribes of Quraysh agreed: it must be rebuilt. You watch as men carry stones from the valley, stacking them carefully. The work is slow but united — for now.",
        'ar': 'جاءت الأمطار دون سابق إنذار — سيل جارف اجتاح الوادي وضرب البيت العتيق. انهارت الجدران. تزحزحت الحجارة. الكعبة، المتهالكة بفعل القرون، لم تعد تحتمل. اتفقت قبائل قريش: يجب إعادة البناء. تراقب الرجال يحملون الحجارة من الوادي، يرصّونها بعناية. العمل بطيء لكنه موحّد — في الوقت الحالي.',
    },
    'event3_dispute': {
        'en': "The walls are nearly done. But one task remains — placing the Black Stone back in its sacred corner. And with it comes a crisis. Every tribe claims the right. You see hands gripping sword hilts. Voices rise. Four days of argument, and still no resolution. The sanctuary, meant for peace, trembles on the edge of bloodshed.",
        'ar': 'الجدران شبه مكتملة. لكن مهمة واحدة بقيت — إعادة الحجر الأسود إلى ركنه المقدس. ومعها جاءت الأزمة. كل قبيلة تطالب بالحق. ترى الأيدي تقبض على مقابض السيوف. الأصوات تعلو. أربعة أيام من الخلاف، ولا حل. الحرم، المخصص للسلام، يرتجف على حافة سفك الدماء.',
    },
    'event3_alamin': {
        'en': "At dawn, the gate of the sanctuary opens. The first man to enter is Muhammad, peace be upon him — thirty-five years old, known to every tribe yet belonging to no faction. A murmur passes through the crowd: Al-Amin. The Trustworthy. No one objects. They have already placed their trust in him — long before prophethood.",
        'ar': 'عند الفجر، يُفتح باب الحرم. أول من يدخل هو محمد صلى الله عليه وسلم — في الخامسة والثلاثين، تعرفه كل القبائل لكنه لا ينتمي لأي فريق. همسة تسري في الجمع: الأمين. لا أحد يعترض. لقد ائتمنوه — قبل النبوة بسنين.',
    },
    'event3_cloak': {
        'en': "He asks for a cloak. He spreads it on the ground and places the Black Stone upon it. Then he invites the leader of each tribe to take hold of a corner. Together, they lift. Together, they carry it to its place. He sets the Stone with his own hands. No tribe was denied. No blood was shed. Wisdom — before revelation.",
        'ar': 'يطلب رداءً. يبسطه على الأرض ويضع الحجر الأسود فوقه. ثم يدعو زعيم كل قبيلة ليمسك بطرف. معاً يرفعون. معاً يحملونه إلى مكانه. يضع الحجر بيديه الشريفتين. لم تُحرم قبيلة. لم يُسفك دم. حكمة — قبل الوحي.',
    },
}

# ── Companion speech lines ────────────────────────────────────────────────────

COMPANION_LINES = {
    'idle_01': {'en': 'The path awaits... try the joystick.', 'ar': 'الطريق ينتظر... جرّب عصا التحكم.'},
    'idle_02': {'en': 'Move forward, companion.', 'ar': 'تقدّم يا رفيق.'},
    'idle_03': {'en': 'History is waiting to be witnessed.', 'ar': 'التاريخ ينتظر من يشهده.'},
    'idle_04': {'en': 'Something glows nearby...', 'ar': 'شيء يتوهج بالقرب...'},
    'idle_05': {'en': 'The journey continues forward.', 'ar': 'الرحلة تستمر للأمام.'},
    'idle_06': {'en': 'There is more to witness ahead.', 'ar': 'هناك المزيد لتشهده أمامك.'},
    'post_01': {'en': 'Onward...', 'ar': 'هيا...'},
    'post_02': {'en': 'There is more to witness.', 'ar': 'هناك المزيد لتشهده.'},
    'post_03': {'en': 'The journey continues.', 'ar': 'الرحلة تستمر.'},
    'revisit_01': {'en': "You've witnessed this. The path ahead holds more...", 'ar': 'شهدت هذا. الطريق أمامك يحمل المزيد...'},
    'revisit_02': {'en': 'The journey awaits, companion.', 'ar': 'الرحلة بانتظارك يا رفيق.'},
    'alldone_01': {'en': 'A moment of reflection approaches...', 'ar': 'لحظة تأمل تقترب...'},
    'alldone_02': {'en': 'You have witnessed everything. Now — choose.', 'ar': 'شهدت كل شيء. الآن — اختر.'},
}


async def generate_one(text: str, voice: str, output_path: str):
    """Generate a single MP3 file using Edge TTS."""
    if os.path.exists(output_path):
        print(f'  SKIP {output_path} (exists)')
        return
    tts = edge_tts.Communicate(text, voice)
    await tts.save(output_path)
    print(f'  OK   {output_path}')


async def main():
    os.makedirs(OUT_VO, exist_ok=True)
    os.makedirs(OUT_COMP, exist_ok=True)

    # Generate fragment VO (4 variants per fragment: en_m, en_f, ar_m, ar_f)
    print('=== Generating Fragment VO ===')
    tasks = []
    for frag_id, texts in FRAGMENTS.items():
        for lang in ('en', 'ar'):
            for gender in ('m', 'f'):
                voice_key = f'{lang}_{gender}'
                voice = VOICES[voice_key]
                text = texts[lang]
                filename = f'vo_{frag_id}_{lang}_{gender}.mp3'
                path = os.path.join(OUT_VO, filename)
                tasks.append(generate_one(text, voice, path))

    # Generate companion speech VO
    print('=== Generating Companion Speech VO ===')
    for line_id, texts in COMPANION_LINES.items():
        for lang in ('en', 'ar'):
            for gender in ('m', 'f'):
                voice_key = f'{lang}_{gender}'
                voice = VOICES[voice_key]
                text = texts[lang]
                filename = f'comp_{line_id}_{lang}_{gender}.mp3'
                path = os.path.join(OUT_COMP, filename)
                tasks.append(generate_one(text, voice, path))

    # Run all in batches of 10 to avoid rate limiting
    batch_size = 10
    for i in range(0, len(tasks), batch_size):
        batch = tasks[i:i + batch_size]
        await asyncio.gather(*batch)

    print(f'\nDone! Generated {len(tasks)} audio files.')


if __name__ == '__main__':
    asyncio.run(main())
