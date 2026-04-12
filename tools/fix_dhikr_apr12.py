"""Replace 8 duplicate dhikr from RAWI_CONTENT_FIXES_APR12.md."""
import re, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from generate_events import slot_id, DART_FILES

fixes = {
    15: ("رَبَّنَا آتِنَا مِنْ لَدُنْكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا", "Rabbana atina min ladunka rahmatan wa hayyi' lana min amrina rashada", "Our Lord, grant us mercy from Yourself and prepare for us right guidance in our affair.", "ربنا آتنا من لدنك رحمة وهيّئ لنا من أمرنا رشداً", "When seeking guidance", "عند طلب الهداية", "When making important decisions", "عند اتخاذ قرارات مهمة", "The du'a of the People of the Cave \u2014 Allah guided them and covered them with mercy and safety.", "دعاء أهل الكهف \u2014 أكرمهم الله بالهداية والرحمة والسلامة.", "Quran 18:10", "القرآن ١٨:١٠"),
    24: ("رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي", "Rabbi-shrah li sadri wa yassir li amri", "My Lord, expand my chest and ease my affair for me.", "ربِّ اشرح لي صدري ويسّر لي أمري", "Before any task", "قبل كل مهمة", "Before speaking or acting for truth", "قبل الكلام أو العمل من أجل الحق", "Musa (peace be upon him) made this du'a before facing Pharaoh. Allah granted him eloquence and ease.", "دعا موسى عليه السلام بهذا الدعاء قبل مواجهة فرعون. فمنحه الله الفصاحة والتيسير.", "Quran 20:25-26", "القرآن ٢٠:٢٥-٢٦"),
    31: ("اللَّهُمَّ لَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ وَأَصْلِحْ لِي شَأْنِي كُلَّهُ لَا إِلَٰهَ إِلَّا أَنْتَ", "Allahumma la takilni ila nafsi tarfata ayn, wa aslih li sha'ni kullahu, la ilaha illa Ant", "O Allah, do not leave me to myself even for the blink of an eye, and set right all my affairs. There is no god but You.", "اللهم لا تكلني إلى نفسي طرفة عين وأصلح لي شأني كله لا إله إلا أنت", "Morning and evening", "صباحاً ومساءً", "When feeling alone or overwhelmed", "عند الشعور بالوحدة أو الإرهاق", "The Prophet \uFDFA taught this to one of his family members who was in distress. Allah sets right all affairs for whoever relies on Him.", "علّم النبي \uFDFA هذا الدعاء لأحد أهله في كرب. الله يصلح كل شأن لمن توكّل عليه.", "Musnad Ahmad 20430 (Sahih)", "مسند أحمد ٢٠٤٣٠ (صحيح)"),
    37: ("اللَّهُمَّ انْفَعْنِي بِمَا عَلَّمْتَنِي وَعَلِّمْنِي مَا يَنْفَعُنِي وَزِدْنِي عِلْمًا", "Allahumma-nfa'ni bima 'allamtani wa 'allimni ma yanfa'uni wa zidni 'ilma", "O Allah, benefit me with what You have taught me, teach me what will benefit me, and increase me in knowledge.", "اللهم انفعني بما علّمتني وعلّمني ما ينفعني وزدني علماً", "After every prayer", "بعد كل صلاة", "When seeking or sharing knowledge", "عند طلب العلم أو نشره", "The Prophet \uFDFA used to say this after Fajr prayer. Beneficial knowledge is among the best things one can ask for.", "كان النبي \uFDFA يقولها بعد صلاة الفجر. العلم النافع من أفضل ما يُسأل.", "Ibn Majah 251 (Hasan)", "ابن ماجه ٢٥١ (حسن)"),
    43: ("اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ", "Allahumma bika asbahna wa bika amsayna wa bika nahya wa bika namutu wa ilaykal-maseer", "O Allah, by You we enter the morning and by You we enter the evening. By You we live and by You we die, and to You is the final return.", "اللهم بك أصبحنا وبك أمسينا وبك نحيا وبك نموت وإليك المصير", "Every morning", "كل صباح", "Upon waking up", "عند الاستيقاظ", "The Prophet \uFDFA said this every morning, entrusting the entire day to Allah from its very first moment.", "كان النبي \uFDFA يقولها كل صباح مودعاً يومه لله من أول لحظة.", "Abu Dawud 5068 (Sahih)", "أبو داود ٥٠٦٨ (صحيح)"),
    45: ("اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا وَفِي بَصَرِي نُورًا وَفِي سَمْعِي نُورًا", "Allahumma-j'al fi qalbi nuran wa fi basari nuran wa fi sam'i nuran", "O Allah, place light in my heart, light in my sight, and light in my hearing.", "اللهم اجعل في قلبي نوراً وفي بصري نوراً وفي سمعي نوراً", "When going to the mosque", "عند الذهاب للمسجد", "When walking to prayer", "عند المشي إلى الصلاة", "The Prophet \uFDFA said this du'a when going to the mosque. He asked for light in every aspect of himself.", "كان النبي \uFDFA يدعو بهذا عند ذهابه للمسجد. سأل النور في كل جانب من ذاته.", "Sahih Muslim 763", "صحيح مسلم ٧٦٣"),
    46: ("رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ", "Rabbana taqabbal minna innaka Antas-Samee'ul-Aleem", "Our Lord, accept from us. Indeed, You are the All-Hearing, the All-Knowing.", "ربنا تقبّل منا إنك أنت السميع العليم", "After every good deed", "بعد كل عمل صالح", "After prayer or any act of worship", "بعد الصلاة أو أي عبادة", "Ibrahim and Ismail (peace be upon them both) made this du'a when building the Ka'bah. It is the du'a of acceptance.", "دعا إبراهيم وإسماعيل عليهما السلام بهذا عند بناء الكعبة. إنه دعاء القبول.", "Quran 2:127", "القرآن ٢:١٢٧"),
    53: ("اللَّهُمَّ مُنْزِلَ الْكِتَابِ سَرِيعَ الْحِسَابِ اهْزِمِ الْأَحْزَابَ اللَّهُمَّ اهْزِمْهُمْ وَزَلْزِلْهُمْ", "Allahumma munzilal-kitabi saree'al-hisab, ihzimil-ahzab. Allahumma ihzimhum wa zalzilhum", "O Allah, Revealer of the Book, Swift in reckoning, defeat the confederates. O Allah, defeat them and shake them.", "اللهم منزل الكتاب سريع الحساب اهزم الأحزاب اللهم اهزمهم وزلزلهم", "When facing a threat", "عند مواجهة تهديد", "When the community faces danger", "عند تعرض الأمة للخطر", "The Prophet \uFDFA said this du'a against enemy forces. Allah promised to defeat and shake those who oppose the believers.", "دعا النبي \uFDFA بهذا ضد قوى العدو. وعد الله بهزيمة من يعادي المؤمنين وزلزلتهم.", "Sahih Muslim 1742", "صحيح مسلم ١٧٤٢"),
}

def dart_s(s):
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"

path = DART_FILES['dhikr']
text = path.read_text(encoding='utf-8')
replaced = 0

for order, vals in sorted(fixes.items()):
    sid = slot_id(order)
    (arabic, trans, en, ar_m, cnt, cnt_ar, when, when_ar,
     prom_en, prom_ar, src, src_ar) = vals

    block = (
        f"  '{sid}': DhikrCard(\n"
        f"    id: '{sid}',\n"
        f"    arabicText: {dart_s(arabic)},\n"
        f"    transliteration: {dart_s(trans)},\n"
        f"    meaningEn: {dart_s(en)},\n"
        f"    meaningAr: {dart_s(ar_m)},\n"
        f"    count: {dart_s(cnt)},\n"
        f"    countAr: {dart_s(cnt_ar)},\n"
        f"    whenToSay: {dart_s(when)},\n"
        f"    whenToSayAr: {dart_s(when_ar)},\n"
        f"    promiseEn: {dart_s(prom_en)},\n"
        f"    promiseAr: {dart_s(prom_ar)},\n"
        f"    sourceRef: {dart_s(src)},\n"
        f"    sourceRefAr: {dart_s(src_ar)},\n"
        "  ),\n"
    )

    pat = re.compile(
        r"(?:  //[^\n]*\n)*  '" + re.escape(sid) + r"': DhikrCard\([\s\S]*?\n  \),\n",
        re.M
    )
    m = pat.search(text)
    if m:
        text = text[:m.start()] + block + text[m.end():]
        replaced += 1
        print(f"  E{order} ({sid}): replaced")
    else:
        print(f"  ! E{order} ({sid}): NOT FOUND")

path.write_text(text, encoding='utf-8')
print(f"\nTotal: {replaced} dhikr replaced")
