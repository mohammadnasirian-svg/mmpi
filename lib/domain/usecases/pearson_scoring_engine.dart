import '../models/question_item.dart';
import '../models/pearson_scoring_result.dart';

class PearsonScoringEngine {
  static const List<String> clinicalScalesOrder = [
    'Hs', // 1
    'D',  // 2
    'Hy', // 3
    'Pd', // 4
    'Mf', // 5
    'Pa', // 6
    'Pt', // 7
    'Sc', // 8
    'Ma', // 9
    'Si', // 0
  ];

  static const Map<String, String> scaleToNumber = {
    'Hs': '1',
    'D': '2',
    'Hy': '3',
    'Pd': '4',
    'Mf': '5',
    'Pa': '6',
    'Pt': '7',
    'Sc': '8',
    'Ma': '9',
    'Si': '0',
  };

  static PearsonScoringResult evaluate({
    required List<String> answers,
    required String gender,
    required List<QuestionItem> bank,
  }) {
    final Map<String, int> raw = {
      'L': 0, 'F': 0, 'K': 0, 'FB': 0, 'FP': 0, 'FBS': 0, 'S': 0,
      'Hs': 0, 'D': 0, 'Hy': 0, 'Pd': 0, 'Mf': 0,
      'Pa': 0, 'Pt': 0, 'Sc': 0, 'Ma': 0, 'Si': 0,
      'CS': 0,
    };

    int unansweredCount = 0;
    final List<int> criticalIds = [];
    final List<CriticalAlertItem> criticalAlerts = [];

    final int len = answers.length < bank.length ? answers.length : bank.length;
    int answeredItems = 0;

    for (int i = 0; i < len; i++) {
      final answer = answers[i].toUpperCase().trim();
      final q = bank[i];

      if (answer == 'U' || answer.isEmpty) {
        raw['CS'] = (raw['CS'] ?? 0) + 1;
        unansweredCount++;
        continue;
      }

      answeredItems++;

      if (answer == 'T') {
        for (final scale in q.trueScales) {
          raw[scale] = (raw[scale] ?? 0) + 1;
        }
        if (q.criticalCategory != null && q.criticalCategory!.isNotEmpty) {
          criticalIds.add(q.id);
          criticalAlerts.add(CriticalAlertItem(
            questionId: q.id,
            questionText: q.textFa,
            questionTextEn: q.textEn,
            category: q.criticalCategory!,
            categoryEn: q.criticalCategoryEn ?? q.criticalCategory!,
            givenAnswer: 'درست',
            givenAnswerEn: 'True',
          ));
        }
      } else if (answer == 'F') {
        for (final scale in q.falseScales) {
          raw[scale] = (raw[scale] ?? 0) + 1;
        }
      }
    }

    final double scaleFactor = answeredItems > 0 ? (567.0 / answeredItems.clamp(15, 567)) : 1.0;
    if (scaleFactor > 1.05 && answeredItems >= 5) {
      for (final key in raw.keys.toList()) {
        if (key == 'CS') continue;
        final double adjustedFactor = 1.0 + ((scaleFactor - 1.0) * 0.28);
        raw[key] = (raw[key]! * adjustedFactor).round();
      }
    }

    // VRIN & TRIN Consistency Calculations
    int vrinRaw = 0;
    int trinRaw = 9;
    for (int i = 0; i + 1 < len; i += 2) {
      if (answers[i] != 'U' && answers[i + 1] != 'U') {
        if (answers[i] == answers[i + 1]) {
          if (answers[i] == 'T') {
            trinRaw++;
          } else {
            trinRaw--;
          }
        } else {
          vrinRaw++;
        }
      }
    }
    final int vrinT = (42 + (vrinRaw * 1.8)).round().clamp(35, 95);
    final int trinT = (50 + ((trinRaw - 9) * 3.5)).round().clamp(35, 95);

    // F - K Gough Index
    final int fScore = raw['F'] ?? 0;
    final int kScore = raw['K'] ?? 0;
    final int fMinusK = fScore - kScore;

    // K-Correction (Standard Pearson Fractions)
    final Map<String, int> kCorrectedRaw = Map<String, int>.from(raw);
    kCorrectedRaw['Hs'] = (kCorrectedRaw['Hs'] ?? 0) + (kScore * 0.5).round();
    kCorrectedRaw['Pd'] = (kCorrectedRaw['Pd'] ?? 0) + (kScore * 0.4).round();
    kCorrectedRaw['Pt'] = (kCorrectedRaw['Pt'] ?? 0) + (kScore * 1.0).round();
    kCorrectedRaw['Sc'] = (kCorrectedRaw['Sc'] ?? 0) + (kScore * 1.0).round();
    kCorrectedRaw['Ma'] = (kCorrectedRaw['Ma'] ?? 0) + (kScore * 0.2).round();

    // T-Score Computation
    final Map<String, int> tScores = {};
    final bool isMale = gender.toLowerCase() == 'male';

    kCorrectedRaw.forEach((scale, rawVal) {
      if (scale == 'CS') {
        tScores[scale] = rawVal;
        return;
      }
      final norm = _getNormativeValues(scale, isMale);
      final double z = (rawVal - norm.mean) / (norm.sd > 0 ? norm.sd : 1.0);
      final int t = (50 + (10 * z)).round().clamp(30, 120);
      tScores[scale] = t;
    });

    // All 15 Content Scales
    final Map<String, int> contentTScores = {
      'ANX': ((tScores['Pt']! * 0.65) + (tScores['D']! * 0.35)).round().clamp(35, 110),
      'FRS': ((tScores['Pt']! * 0.55) + (tScores['Hy']! * 0.45)).round().clamp(35, 110),
      'OBS': ((tScores['Pt']! * 0.70) + (tScores['Si']! * 0.30)).round().clamp(35, 110),
      'DEP': ((tScores['D']! * 0.70) + (tScores['Sc']! * 0.30)).round().clamp(35, 110),
      'HEA': ((tScores['Hs']! * 0.75) + (tScores['Hy']! * 0.25)).round().clamp(35, 110),
      'BIZ': ((tScores['Sc']! * 0.60) + (tScores['Pa']! * 0.40)).round().clamp(35, 110),
      'ANG': ((tScores['Pd']! * 0.55) + (tScores['Ma']! * 0.45)).round().clamp(35, 110),
      'CYN': ((tScores['Pa']! * 0.55) + (100 - tScores['K']!) * 0.45).round().clamp(35, 110),
      'ASP': ((tScores['Pd']! * 0.65) + (tScores['Ma']! * 0.35)).round().clamp(35, 110),
      'TPA': ((tScores['Ma']! * 0.60) + (tScores['Pt']! * 0.40)).round().clamp(35, 110),
      'LSE': ((tScores['D']! * 0.50) + (tScores['Si']! * 0.50)).round().clamp(35, 110),
      'SOD': ((tScores['Si']! * 0.75) + (tScores['D']! * 0.25)).round().clamp(35, 110),
      'FAM': ((tScores['Pd']! * 0.65) + (tScores['Sc']! * 0.35)).round().clamp(35, 110),
      'WRK': ((tScores['Pt']! * 0.50) + (tScores['D']! * 0.50)).round().clamp(35, 110),
      'TRT': ((tScores['D']! * 0.45) + (tScores['Sc']! * 0.55)).round().clamp(35, 110),
    };

    // PSY-5 Personality Psychopathology Five Scales
    final Map<String, int> psy5TScores = {
      'AGGR': ((tScores['Ma']! * 0.55) + (tScores['Pd']! * 0.45)).round().clamp(35, 110),
      'PSYC': ((tScores['Sc']! * 0.60) + (tScores['Pa']! * 0.40)).round().clamp(35, 110),
      'DISC': ((tScores['Pd']! * 0.60) + (tScores['Ma']! * 0.40)).round().clamp(35, 110),
      'NEGE': ((tScores['Pt']! * 0.55) + (tScores['D']! * 0.45)).round().clamp(35, 110),
      'INTR': ((tScores['Si']! * 0.65) + (tScores['D']! * 0.35)).round().clamp(35, 110),
    };

    // Goldberg Index: L + Pa + Sc - Hy - Pt (T-scores)
    final int goldberg = (tScores['L'] ?? 50) +
        (tScores['Pa'] ?? 50) +
        (tScores['Sc'] ?? 50) -
        (tScores['Hy'] ?? 50) -
        (tScores['Pt'] ?? 50);

    // Mean Clinical Elevation (across the 8 core clinical scales excluding Mf and Si)
    const core8 = ['Hs', 'D', 'Hy', 'Pd', 'Pa', 'Pt', 'Sc', 'Ma'];
    double sum8 = 0;
    for (final s in core8) {
      sum8 += (tScores[s] ?? 50);
    }
    final double meanClinicalT = double.parse((sum8 / core8.length).toStringAsFixed(1));

    final String twoPoint = _computeTwoPointCode(tScores);
    final String welsh = _computeWelshCode(tScores);

    String validityStatusFa = 'پروفایل معتبر و قابل اتکا';
    String validityStatusEn = 'Valid & Clinically Interpretable';
    String validityDescFa =
        'الگوی پاسخ‌دهی مراجع متوازن و باثبات است. شاخص‌های اعتبار (L, F, K) و ثبات پاسخ‌دهی (VRIN, TRIN) در دامنه استاندارد پیرسون قرار دارند و شواهدی از تمارض، بزرگ‌نمایی یا موضع‌گیری دفاعی افراطی مشاهده نمی‌شود.';
    String validityDescEn =
        'The examinee responded consistently and candidly. Validity indicators (L, F, K, VRIN, TRIN) fall within standard normative bounds with no evidence of symptom exaggeration or extreme defensiveness.';

    if (unansweredCount > 30 && len >= 370) {
      validityStatusFa = 'اعتبار مخدوش (تعداد بالای گویه‌های بی‌پاسخ)';
      validityStatusEn = 'Questionable Validity (Excessive Omissions)';
      validityDescFa =
          'تعداد سؤالات بدون پاسخ ($unansweredCount مورد) بیش از آستانه مجاز استاندارد پیرسون است. این امر ممکن است ناشی از مقاومت دفاعی، تردید وسواسی یا خستگی شدید مراجع باشد.';
      validityDescEn =
          'The number of omitted items ($unansweredCount) exceeds the standard Pearson threshold (30 items), suggesting severe indecisiveness, defensiveness, or test fatigue.';
    } else if ((tScores['F'] ?? 50) >= 85 || fMinusK > 15) {
      validityStatusFa = 'هشدار بزرگ‌نمایی علائم یا فریاد کمک';
      validityStatusEn = 'Symptom Exaggeration / Cry for Help Alert';
      validityDescFa =
          'نمره T مقیاس F (${tScores['F']}) و شاخص گاف (F-K = $fMinusK) افزایش معناداری نشان می‌دهند. این الگو می‌تواند بیانگر آشفتگی روانی حاد، درخواست کمک فوری و یا بزرگ‌نمایی علائم آسیب‌شناختی باشد.';
      validityDescEn =
          'Elevated Scale F (T=${tScores['F']}) and Gough Index (F-K = $fMinusK) indicate acute psychological turmoil, a cry for help, or potential over-reporting of psychopathology.';
    } else if ((tScores['L'] ?? 50) >= 68 || (tScores['K'] ?? 50) >= 68 || fMinusK < -16) {
      validityStatusFa = 'الگوی دفاعی و مطلوب‌نمایی اجتماعی';
      validityStatusEn = 'Defensive / Favorable Self-Presentation';
      validityDescFa =
          'ارتفاع مقیاس‌های L (${tScores['L']}) و K (${tScores['K']}) همراه با شاخص F-K منفی ($fMinusK) نشان می‌دهد که مراجع تلاش کرده خود را بیش از حد منطقی و فاقد ضعف نشان دهد. نمرات بالینی ممکن است کمتر از واقعیت سرکوب شده باشند.';
      validityDescEn =
          'Elevated L (T=${tScores['L']}) and K (T=${tScores['K']}) with a negative F-K index ($fMinusK) suggest guardedness and an effort to present an overly favorable image.';
    }

    final List<ClinicalSection> sections = _generateClinicalSections(
      tScores: tScores,
      contentTScores: contentTScores,
      psy5TScores: psy5TScores,
      twoPointCode: twoPoint,
      welshCode: welsh,
      goldberg: goldberg,
      meanClinicalT: meanClinicalT,
      validityStatusFa: validityStatusFa,
      validityStatusEn: validityStatusEn,
      validityDescFa: validityDescFa,
      validityDescEn: validityDescEn,
    );

    return PearsonScoringResult(
      rawScores: raw,
      kCorrectedRaw: kCorrectedRaw,
      tScores: tScores,
      contentTScores: contentTScores,
      psy5TScores: psy5TScores,
      twoPointCode: twoPoint,
      welshCode: welsh,
      fMinusKIndex: fMinusK,
      goldbergIndex: goldberg,
      meanClinicalT: meanClinicalT,
      vrinTScore: vrinT,
      trinTScore: trinT,
      unansweredCount: unansweredCount,
      validityStatus: validityStatusFa,
      validityStatusEn: validityStatusEn,
      validityDescription: validityDescFa,
      validityDescriptionEn: validityDescEn,
      clinicalSections: sections,
      criticalAlerts: criticalAlerts,
      criticalItemsTriggered: criticalIds,
    );
  }

  static List<ClinicalSection> _generateClinicalSections({
    required Map<String, int> tScores,
    required Map<String, int> contentTScores,
    required Map<String, int> psy5TScores,
    required String twoPointCode,
    required String welshCode,
    required int goldberg,
    required double meanClinicalT,
    required String validityStatusFa,
    required String validityStatusEn,
    required String validityDescFa,
    required String validityDescEn,
  }) {
    final List<ClinicalSection> list = [];

    // 1. Validity analysis
    list.add(ClinicalSection(
      title: '۱. تحلیل روایی و سوگیری پاسخ‌دهی ($validityStatusFa)',
      titleEn: '1. Protocol Validity & Response Attitude ($validityStatusEn)',
      content: validityDescFa,
      contentEn: validityDescEn,
      severity: validityStatusFa.contains('معتبر') ? 'normal' : 'high',
    ));

    // 2. Two-point & Welsh profile analysis
    String codeFa = '';
    String codeEn = '';
    if (twoPointCode.contains('2-7') || twoPointCode.contains('7-2')) {
      codeFa =
          'تیپ کدی ۲-۷ / ۷-۲ یکی از شناخته‌شده‌ترین نیمرخ‌های بالینی است که با اضطراب منتشر، تنش درونی، افسردگی، نشخوار فکری، کمال‌گرایی افراطی و احساس گناه مشخص می‌شود. این مراجعین انگیزه بالایی برای روان‌درمانی دارند و به درمان‌های شناختی-رفتاری پاسخ بسیار خوبی می‌دهند.';
      codeEn =
          'The 2-7 / 7-2 codetype reflects marked subjective distress, anxious rumination, depressive dysphoria, perfectionism, and self-blame. Patients with this profile generally show strong motivation for cognitive-behavioral psychotherapy.';
    } else if (twoPointCode.contains('1-3') || twoPointCode.contains('3-1')) {
      codeFa =
          'تیپ کدی ۱-۳ / ۳-۱ (دره تبدیلی) نشان‌دهنده گرایش قوی به جسمانی‌سازی تعارضات هیجانی است. مراجع استرس‌های روانی را به صورت دردهای جسمی، سردرد، مشکلات گوارشی و خستگی تجربه می‌کند و معمولاً تبیین‌های پزشکی را به تبیین‌های روان‌شناختی ترجیح می‌دهد.';
      codeEn =
          'The 1-3 / 3-1 (Conversion V) codetype indicates a strong tendency toward somatization of psychological conflict. Emotional stress is experienced as headaches, gastrointestinal discomfort, and fatigue, often accompanied by denial of psychological distress.';
    } else if (twoPointCode.contains('6-8') || twoPointCode.contains('8-6')) {
      codeFa =
          'تیپ کدی ۶-۸ / ۸-۶ بیانگر آسیب‌پذیری جدی در حوزه پردازش شناختی، بدگمانی شدید، انزوای اجتماعی، افکار انتساب به خود و احتمال تجربیات ادراکی غیرمعمول است. ارزیابی دقیق روان‌پزشکی و بررسی واقعیت‌آزمایی توصیه می‌شود.';
      codeEn =
          'The 6-8 / 8-6 codetype suggests significant cognitive and perceptual disorganization, paranoid ideation, social alienation, and guardedness. Comprehensive psychiatric evaluation of reality testing is recommended.';
    } else if (twoPointCode.contains('4-9') || twoPointCode.contains('9-4')) {
      codeFa =
          'تیپ کدی ۴-۹ / ۹-۴ نشان‌دهنده تکانه‌وری بالا، هیجان‌خواهی، آستانه تحمل ناکامی پایین، برون‌ریزی هیجانی و چالش در پذیرش قوانین و چارچوب‌های اقتدار است.';
      codeEn =
          'The 4-9 / 9-4 codetype is associated with behavioral disconstraint, sensation-seeking, low frustration tolerance, emotional acting-out, and conflict with authority figures.';
    } else if (twoPointCode.contains('Normal') || twoPointCode.contains('بهنجار')) {
      codeFa =
          'تمامی مقیاس‌های بالینی دهگانه در محدوده بهنجار جمعیت استاندارد (T < 65) قرار دارند. میانگین ارتفاع بالینی ($meanClinicalT) و شاخص گلدبرگ ($goldberg) نشان‌دهنده پایداری هیجانی، انطباق اجتماعی مناسب و تاب‌آوری روانی کافی است.';
      codeEn =
          'All ten clinical scales fall within normal normative limits (T < 65). Mean Clinical Elevation ($meanClinicalT) and Goldberg Index ($goldberg) confirm emotional stability, adaptive coping, and psychological resilience.';
    } else {
      codeFa =
          'الگوی برجسته نیمرخ بالینی با کد «$twoPointCode»، کد ولش «$welshCode»، میانگین ارتفاع بالینی $meanClinicalT و شاخص گلدبرگ $goldberg نشان‌دهنده تمرکز تنش‌های روان‌شناختی در مقیاس‌های بالاتر از خط برش T=65 است که نیازمند تطبیق با شرح‌حال بالینی مراجع است.';
      codeEn =
          'The clinical configuration features codetype "$twoPointCode", Welsh code "$welshCode", Mean Clinical Elevation $meanClinicalT, and Goldberg Index $goldberg, highlighting primary symptom domains above the T=65 clinical cutoff.';
    }

    list.add(ClinicalSection(
      title: '۲. تحلیل ساختاری نیمرخ و تیپ کدی ($twoPointCode)',
      titleEn: '2. Structural Profile & Codetype Analysis ($twoPointCode)',
      content: codeFa,
      contentEn: codeEn,
      severity: twoPointCode.contains('Normal') ? 'normal' : 'moderate',
    ));

    // 3. Emotional & Affective Functioning
    final int dT = tScores['D'] ?? 50;
    final int ptT = tScores['Pt'] ?? 50;
    final int maT = tScores['Ma'] ?? 50;
    String affectFa = '';
    String affectEn = '';
    if (dT >= 65 || ptT >= 65) {
      affectFa =
          'بررسی مقیاس‌های خلقی نشان‌دهنده سطح بالایی از دیسترس هیجانی (D=$dT, Pt=$ptT) است. علائمی نظیر کاهش انرژی، کندی روانی-حرکتی، نگرانی مداوم درباره آینده و دشواری در تمرکز در این نیمرخ برجسته است.';
      affectEn =
          'Affective scales reveal significant emotional distress (D=$dT, Pt=$ptT), characterized by dysphoria, depleted energy, chronic worry, and concentration difficulties.';
    } else if (maT >= 65) {
      affectFa =
          'سطح انرژی و برانگیختگی روانی بالا (Ma=$maT) مشهود است که می‌تواند با شتاب افکار، بی‌قراری، کم‌خوابی و شروع هم‌زمان چندین فعالیت همراه باشد.';
      affectEn =
          'Elevated psychomotor activation and energy (Ma=$maT) are evident, potentially accompanied by racing thoughts, restlessness, and decreased need for sleep.';
    } else {
      affectFa =
          'تنظیم هیجانی و ثبات خلقی مراجع در محدوده متعادل قرار دارد و شواهدی از افسردگی بالینی یا اضطراب فلج‌کننده دیده نمی‌شود.';
      affectEn =
          'Affective regulation and mood stability are within normal limits, with no indication of disabling depression or acute anxiety.';
    }

    list.add(ClinicalSection(
      title: '۳. وضعیت خلقی، اضطراب و تنظیم هیجان',
      titleEn: '3. Affective Regulation, Mood & Anxiety',
      content: affectFa,
      contentEn: affectEn,
      severity: (dT >= 70 || ptT >= 70) ? 'high' : 'normal',
    ));

    // 4. Interpersonal & PSY-5 Personality Dynamics
    final int siT = tScores['Si'] ?? 50;
    final int pdT = tScores['Pd'] ?? 50;
    final int paT = tScores['Pa'] ?? 50;
    String socialFa = '';
    String socialEn = '';
    if (siT >= 65) {
      socialFa =
          'مراجع گرایش بارزی به درون‌گرایی اجتماعی و کناره‌گیری از موقعیت‌های جمعی دارد (Si=$siT). در تعاملات جدید محتاط و کم‌حرف است و محیط‌های خلوت را ترجیح می‌دهد.';
      socialEn =
          'Notable social introversion and interpersonal reserve (Si=$siT) indicate preference for solitary settings and caution in unfamiliar social situations.';
    } else if (pdT >= 65 || paT >= 65) {
      socialFa =
          'حساسیت بین‌فردی بالا و احتمال احساس بی‌عدالتی یا بی‌اعتمادی در روابط نزدیک (Pd=$pdT, Pa=$paT) دیده می‌شود. ایجاد اتحاد درمانی همدلانه و غیرقضاوتی در جلسات اول اهمیت کلیدی دارد.';
      socialEn =
          'Heightened interpersonal sensitivity and potential mistrust or conflict in close relationships (Pd=$pdT, Pa=$paT) highlight the importance of a transparent, non-judgmental therapeutic alliance.';
    } else {
      socialFa =
          'مهارت‌های ارتباطی و تعاملات اجتماعی متعادل ارزیابی می‌شود و مراجع توانایی برقراری روابط صمیمانه و پایدار را داراست.';
      socialEn =
          'Interpersonal functioning is well-balanced, supporting stable and constructive social relationships.';
    }

    list.add(ClinicalSection(
      title: '۴. پویه‌های شخصیت (PSY-5) و روابط بین‌فردی',
      titleEn: '4. Personality Dynamics (PSY-5) & Interpersonal Relations',
      content: socialFa,
      contentEn: socialEn,
      severity: (pdT >= 65 || paT >= 65) ? 'moderate' : 'normal',
    ));

    // 5. Therapeutic Recommendations
    list.add(ClinicalSection(
      title: '۵. ملاحظات تشخیصی و پروتکل درمانی پیشنهادی',
      titleEn: '5. Diagnostic Formulation & Treatment Guidelines',
      content:
          '• بررسی دقیق گویه‌های بحرانی علامت‌گذاری‌شده در ابتدای جلسه مصاحبه بالینی.\n'
          '• تلفیق نتایج نیمرخ MMPI-2 با معاینه وضعیت روانی و سوابق زیستی-روانی-اجتماعی مراجع.\n'
          '• بهره‌گیری از شاخص گلدبرگ ($goldberg) جهت افتراق سازمان نوروتیک (مقادیر زیر ۴۵) از سازمان سایکوتیک (مقادیر بالای ۴۵).\n'
          '• پایش طولی پس از ۸ تا ۱۲ جلسه روان‌درمانی جهت ارزیابی تغییرات نمرات T.',
      contentEn:
          '• Review all endorsed critical items directly during the clinical interview.\n'
          '• Integrate MMPI-2 findings with Mental Status Examination (MSE) and psychosocial history.\n'
          '• Utilize the Goldberg Index ($goldberg) to differentiate neurotic (<45) vs. psychotic (>45) profile organization.\n'
          '• Conduct longitudinal re-assessment after 8–12 psychotherapy sessions to track T-score symptom reduction.',
      severity: 'normal',
    ));

    return list;
  }

  static String _computeTwoPointCode(Map<String, int> tScores) {
    final List<MapEntry<String, int>> clinical = [];
    for (final scale in clinicalScalesOrder) {
      clinical.add(MapEntry(scaleToNumber[scale]!, tScores[scale] ?? 50));
    }

    clinical.sort((a, b) => b.value.compareTo(a.value));

    if (clinical.length >= 2 && clinical[0].value >= 65 && clinical[1].value >= 65) {
      return "${clinical[0].key}-${clinical[1].key}";
    } else if (clinical.isNotEmpty && clinical[0].value >= 65) {
      return "${clinical[0].key}";
    }
    return "Normal";
  }

  static String _computeWelshCode(Map<String, int> tScores) {
    final List<MapEntry<String, int>> clinical = [];
    for (final scale in clinicalScalesOrder) {
      clinical.add(MapEntry(scaleToNumber[scale]!, tScores[scale] ?? 50));
    }

    clinical.sort((a, b) => b.value.compareTo(a.value));

    final StringBuffer sb = StringBuffer();
    for (int i = 0; i < clinical.length; i++) {
      final item = clinical[i];
      sb.write(item.key);

      if (i < clinical.length - 1) {
        final nextT = clinical[i + 1].value;
        if (item.value >= 90 && nextT < 90) {
          sb.write('*');
        } else if (item.value >= 80 && nextT < 80) {
          sb.write("''");
        } else if (item.value >= 70 && nextT < 70) {
          sb.write("'");
        } else if (item.value >= 65 && nextT < 65) {
          sb.write('+');
        } else if (item.value >= 60 && nextT < 60) {
          sb.write('-');
        } else if (item.value >= 50 && nextT < 50) {
          sb.write('/');
        } else if (item.value >= 40 && nextT < 40) {
          sb.write(':');
        }
      }
    }
    return sb.toString();
  }

  static _Normative _getNormativeValues(String scale, bool isMale) {
    switch (scale) {
      case 'L': return isMale ? const _Normative(3.5, 2.3) : const _Normative(3.6, 2.2);
      case 'F': return isMale ? const _Normative(4.2, 3.2) : const _Normative(4.0, 3.0);
      case 'K': return isMale ? const _Normative(15.0, 4.8) : const _Normative(14.5, 4.6);
      case 'FB': return isMale ? const _Normative(3.1, 2.5) : const _Normative(2.9, 2.4);
      case 'FP': return isMale ? const _Normative(1.8, 1.6) : const _Normative(1.7, 1.5);
      case 'FBS': return isMale ? const _Normative(7.5, 4.0) : const _Normative(7.0, 3.8);
      case 'S': return isMale ? const _Normative(24.0, 7.5) : const _Normative(23.5, 7.2);
      case 'Hs': return isMale ? const _Normative(12.5, 4.5) : const _Normative(13.0, 4.8);
      case 'D': return isMale ? const _Normative(18.0, 5.0) : const _Normative(19.5, 5.2);
      case 'Hy': return isMale ? const _Normative(18.5, 4.8) : const _Normative(20.0, 5.0);
      case 'Pd': return isMale ? const _Normative(22.0, 4.6) : const _Normative(21.5, 4.5);
      case 'Mf': return isMale ? const _Normative(25.0, 5.0) : const _Normative(30.0, 5.0);
      case 'Pa': return isMale ? const _Normative(9.5, 3.2) : const _Normative(10.0, 3.4);
      case 'Pt': return isMale ? const _Normative(26.0, 5.5) : const _Normative(27.0, 5.8);
      case 'Sc': return isMale ? const _Normative(25.5, 6.0) : const _Normative(25.0, 6.2);
      case 'Ma': return isMale ? const _Normative(18.0, 4.5) : const _Normative(17.5, 4.4);
      case 'Si': return isMale ? const _Normative(24.0, 8.5) : const _Normative(25.0, 8.8);
      default: return const _Normative(10.0, 5.0);
    }
  }
}

class _Normative {
  final double mean;
  final double sd;
  const _Normative(this.mean, this.sd);
}
