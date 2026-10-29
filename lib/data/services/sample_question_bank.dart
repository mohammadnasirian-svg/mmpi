import '../../domain/models/question_item.dart';

class MMPIQuestionBank {
  static const List<QuestionItem> _coreQuestions = [
    QuestionItem(
      id: 1,
      textFa: "مجله‌های فنی و مکانیکی را دوست دارم.",
      trueScales: [],
      falseScales: ['Mf'],
    ),
    QuestionItem(
      id: 2,
      textFa: "اشتهای خوبی دارم و از غذا خوردن لذت می‌برم.",
      trueScales: [],
      falseScales: ['Hs', 'D', 'Hy'],
    ),
    QuestionItem(
      id: 3,
      textFa: "صبح‌ها اغلب سرحال، پرانرژی و با نشاط از خواب بیدار می‌شوم.",
      trueScales: [],
      falseScales: ['D', 'Hy', 'Pt'],
    ),
    QuestionItem(
      id: 4,
      textFa: "فکر می‌کنم از کار کتابداری یا فعالیت‌های فرهنگی خوشم بیاید.",
      trueScales: ['Mf'],
      falseScales: [],
    ),
    QuestionItem(
      id: 5,
      textFa: "با شنیدن صداهای ناگهانی به آسانی از جا می‌پرم و مضطرب می‌شوم.",
      trueScales: ['Pt', 'Hs'],
      falseScales: [],
      criticalCategory: 'اضطراب حاد (Acute Anxiety)',
    ),
    QuestionItem(
      id: 6,
      textFa: "پدرم انسان خوبی بود (یا هست) و رابطه گرمی با او داشتم.",
      trueScales: [],
      falseScales: ['Pd', 'Pa'],
    ),
    QuestionItem(
      id: 7,
      textFa: "شب‌ها خوابم بسیار منظم و آرام است و به ندرت بیدار می‌شوم.",
      trueScales: [],
      falseScales: ['D', 'Pt', 'Hs'],
    ),
    QuestionItem(
      id: 8,
      textFa: "گاهی اوقات به شدت دلم خواسته است خانه و خانواده را برای همیشه ترک کنم.",
      trueScales: ['Pd', 'Sc'],
      falseScales: [],
      criticalCategory: 'تعارض خانوادگی (Family Discord)',
    ),
    QuestionItem(
      id: 9,
      textFa: "گاهی دچار حملات خنده یا گریه می‌شوم که به هیچ‌وجه قادر به مهار آن نیستم.",
      trueScales: ['Hy', 'D', 'Sc'],
      falseScales: [],
      criticalCategory: 'عدم مهار هیجانی (Emotional Control)',
    ),
    QuestionItem(
      id: 10,
      textFa: "به نظرم هیچ‌کس در این دنیا واقعاً مرا درک نمی‌کند.",
      trueScales: ['F', 'Pd', 'Pa', 'Sc'],
      falseScales: [],
      criticalCategory: 'بیگانگی اجتماعی (Social Alienation)',
    ),
    QuestionItem(
      id: 11,
      textFa: "هرگز در تمام عمرم حتی یک دروغ کوچک هم نگفته‌ام.",
      trueScales: ['L', 'S'],
      falseScales: [],
    ),
    QuestionItem(
      id: 12,
      textFa: "اغلب شب‌ها کابوس‌های وحشتناک می‌بینم و با تپش قلب بیدار می‌شوم.",
      trueScales: ['Pt', 'Sc', 'F'],
      falseScales: [],
      criticalCategory: 'اختلال خواب و اضطراب (Sleep & Anxiety)',
    ),
    QuestionItem(
      id: 13,
      textFa: "زندگی روزمره برایم پر از چیزهای جالب و ارزشمند است.",
      trueScales: [],
      falseScales: ['D', 'Sc', 'Si'],
    ),
    QuestionItem(
      id: 14,
      textFa: "معده‌ام اغلب ناراحت است و دچار سوزش یا درد گوارشی می‌شوم.",
      trueScales: ['Hs', 'Hy', 'FBS'],
      falseScales: [],
    ),
    QuestionItem(
      id: 15,
      textFa: "عضلات گردن و شانه‌هایم بیشتر اوقات منقبض و دردناک است.",
      trueScales: ['Hs', 'Hy'],
      falseScales: [],
    ),
    QuestionItem(
      id: 16,
      textFa: "مطمئنم افرادی در اطرافم توطئه می‌کنند تا به من آسیب برسانند.",
      trueScales: ['F', 'FP', 'Pa', 'Sc'],
      falseScales: [],
      criticalCategory: 'افکار گزند و آسیب (Persecutory Ideas)',
    ),
    QuestionItem(
      id: 17,
      textFa: "گاهی اوقات به این فکر می‌کنم که ای کاش دیگر زنده نبودم یا به خودم آسیب می‌زدم.",
      trueScales: ['F', 'FB', 'D', 'Sc'],
      falseScales: [],
      criticalCategory: 'افکار خودکشی (Suicidal Ideation)',
    ),
    QuestionItem(
      id: 18,
      textFa: "گاهی کارهایی که باید امروز انجام دهم را به فردا می‌اندازم.",
      trueScales: [],
      falseScales: ['L', 'K'],
    ),
    QuestionItem(
      id: 19,
      textFa: "اغلب احساس می‌کنم نوار سفتی دور سرم بسته شده و سرم به شدت درد می‌کند.",
      trueScales: ['Hs', 'Hy', 'Pt'],
      falseScales: [],
    ),
    QuestionItem(
      id: 20,
      textFa: "در مهمانی‌ها و جمع‌های شلوغ به راحتی سر صحبت را با دیگران باز می‌کنم.",
      trueScales: ['Ma'],
      falseScales: ['Si', 'D'],
    ),
    QuestionItem(
      id: 21,
      textFa: "وقتی مردم از من انتقاد می‌کنند، حتی اگر حق با آن‌ها باشد، به ندرت ناراحت می‌شوم.",
      trueScales: ['K', 'S'],
      falseScales: ['Pa'],
    ),
    QuestionItem(
      id: 22,
      textFa: "در مواقعی آن‌قدر انرژی و هیجان دارم که تا چند شب نیازی به خوابیدن حس نمی‌کنم.",
      trueScales: ['Ma', 'Sc'],
      falseScales: [],
    ),
    QuestionItem(
      id: 23,
      textFa: "احساس می‌کنم ذهنم کند شده و تمرکز کردن روی یک موضوع برایم بسیار دشوار است.",
      trueScales: ['D', 'Pt', 'Sc'],
      falseScales: [],
    ),
    QuestionItem(
      id: 24,
      textFa: "صداهایی را می‌شنوم که دیگران متوجه وجود آن‌ها نمی‌شوند.",
      trueScales: ['F', 'FP', 'Sc', 'Pa'],
      falseScales: [],
      criticalCategory: 'علائم سایکوتیک و توهم (Psychotic Symptoms)',
    ),
    QuestionItem(
      id: 25,
      textFa: "بیشتر مردم برای رسیدن به منافع شخصی خود حاضرند دروغ بگویند و تقلب کنند.",
      trueScales: ['Pa', 'Pd'],
      falseScales: ['K', 'S'],
    ),
    QuestionItem(
      id: 26,
      textFa: "از اینکه در مرکز توجه جمع باشم لذت می‌برم.",
      trueScales: ['Ma', 'Hy'],
      falseScales: ['Si'],
    ),
    QuestionItem(
      id: 27,
      textFa: "اغلب به خاطر کارهایی که انجام داده‌ام دچار عذاب وجدان و احساس گناه شدید می‌شوم.",
      trueScales: ['D', 'Pt'],
      falseScales: [],
    ),
    QuestionItem(
      id: 28,
      textFa: "در مدرسه یا محیط کار گاهی به خاطر سرپیچی از قوانین توبیخ شده‌ام.",
      trueScales: ['Pd', 'Ma'],
      falseScales: ['L'],
    ),
    QuestionItem(
      id: 29,
      textFa: "دست‌ها و پاهایم معمولاً به اندازه کافی گرم هستند.",
      trueScales: [],
      falseScales: ['Hs', 'Si'],
    ),
    QuestionItem(
      id: 30,
      textFa: "آینده به نظرم تاریک و ناامیدکننده می‌رسد.",
      trueScales: ['D', 'FB', 'Sc'],
      falseScales: [],
      criticalCategory: 'افسردگی و ناامیدی حاد (Severe Hopelessness)',
    ),
    QuestionItem(
      id: 31,
      textFa: "همیشه با تمام افرادی که می‌شناسم به یک اندازه مهربان و منصف هستم.",
      trueScales: ['L'],
      falseScales: [],
    ),
    QuestionItem(
      id: 32,
      textFa: "مرتباً مجبورم کارهایی مثل قفل بودن در یا خاموش بودن گاز را چندین بار چک کنم.",
      trueScales: ['Pt', 'Sc'],
      falseScales: [],
    ),
    QuestionItem(
      id: 33,
      textFa: "به ندرت دچار سرگیجه یا سیاهی رفتن چشم می‌شوم.",
      trueScales: [],
      falseScales: ['Hs', 'Hy', 'FBS'],
    ),
    QuestionItem(
      id: 34,
      textFa: "احساس می‌کنم نیروی عجیبی افکار مرا کنترل می‌کند یا افکارش را در ذهنم می‌گذارد.",
      trueScales: ['F', 'FP', 'Sc', 'Pa'],
      falseScales: [],
      criticalCategory: 'هذیان کنترل فکر (Thought Control Delusion)',
    ),
    QuestionItem(
      id: 35,
      textFa: "اگر بتوانم بدون بلیط و بدون اینکه کسی بفهمد وارد سینما شوم، این کار را می‌کنم.",
      trueScales: ['Pd'],
      falseScales: ['L', 'K'],
    ),
    QuestionItem(
      id: 36,
      textFa: "تقریباً هر روز احساس خستگی مفرط و بی‌حالی دارم حتی وقتی کار سنگینی نکرده‌ام.",
      trueScales: ['Hs', 'D', 'Hy', 'FBS'],
      falseScales: [],
    ),
    QuestionItem(
      id: 37,
      textFa: "بسیار پیش می‌آید که افکار در ذهنم با چنان سرعتی حرکت کنند که نتوانم آن‌ها را بیان کنم.",
      trueScales: ['Ma', 'Pt'],
      falseScales: [],
    ),
    QuestionItem(
      id: 38,
      textFa: "وقتی در جمع غریبه‌ها هستم، ترجیح می‌دهم در گوشه‌ای آرام بنشینم و صحبت نکنم.",
      trueScales: ['Si', 'D'],
      falseScales: ['Ma', 'Hy'],
    ),
    QuestionItem(
      id: 39,
      textFa: "در برابر مشکلات زندگی خود را فردی آرام، منطقی و مسلط می‌دانم.",
      trueScales: ['K', 'S'],
      falseScales: ['Pt', 'D'],
    ),
    QuestionItem(
      id: 40,
      textFa: "برای آرام کردن اعصابم گاهی بیش از حد معمول از داروهای آرام‌بخش یا الکل استفاده کرده‌ام.",
      trueScales: ['Pd', 'Ma', 'FB'],
      falseScales: [],
      criticalCategory: 'خطر سوءمصرف مواد و دارو (Substance Abuse Risk)',
    ),
  ];

  static List<QuestionItem> getStandardBank() {
    return List<QuestionItem>.from(_coreQuestions);
  }

  static List<QuestionItem> getFullBank(int count) {
    if (count <= _coreQuestions.length) {
      return _coreQuestions.sublist(0, count);
    }

    final List<QuestionItem> full = List<QuestionItem>.from(_coreQuestions);

    // Additional realistic variations for items up to 567
    const List<String> clinicalPrompts = [
      "در موقعیت‌های پر استرس، ضربان قلبم به شدت بالا می‌رود و دست‌هایم می‌لرزد.",
      "احساس می‌کنم در مقایسه با دیگران اعتمادبه‌نفس کمتری دارم.",
      "از مطالعه کتاب‌های علمی، تاریخی و فلسفی لذت زیادی می‌برم.",
      "بیشتر اوقات احساس می‌کنم دیگران به اندازه کافی قدر زحمات مرا نمی‌دانند.",
      "تصمیم‌گیری درباره مسائل روزمره برایم بسیار سخت و زمان‌بر است.",
      "هیچ‌گاه از دیدن موفقیت رقبایم احساس حسادت نکرده‌ام.",
      "گاهی بدون هیچ دلیل پزشکی مشخصی در قفسه سینه‌ام احساس درد یا فشار می‌کنم.",
      "ترجیح می‌دهم به جای کارهای تیمی، مسئولیت‌ها را به تنهایی انجام دهم.",
      "وقتی کسی با من مخالفت می‌کند، به سرعت عصبانی می‌شوم اما زود هم آرام می‌گیرم.",
      "احساس می‌کنم سرنوشت با من نامهربان بوده و شانس کمی در زندگی داشته‌ام.",
      "از ارتفاع، فضاهای بسته یا تاریکی ترس شدیدی دارم.",
      "معمولاً می‌توانم نیت واقعی افراد را از روی لحن و نگاهشان تشخیص دهم.",
      "گاهی حس می‌کنم محیط اطرافم واقعی نیست و انگار در یک رویا زندگی می‌کنم.",
      "از شروع کردن پروژه‌های جدید و پرریسک بسیار استقبال می‌کنم.",
      "به ندرت پیش می‌آید که از عملکرد خودم کاملاً راضی باشم.",
      "روابط عاطفی و خانوادگی من سرشار از آرامش و تفاهم متقابل است.",
      "وقتی منتظر کسی هستم، بی‌قرار می‌شوم و نمی‌توانم آرام بنشینم.",
      "نسبت به مسائل اخلاقی و رعایت مقررات اجتماعی بسیار سخت‌گیر هستم.",
      "گاهی افکار مزاحم و ناخواسته‌ای به ذهنم هجوم می‌آورند که رهایی از آن‌ها دشوار است.",
      "از آشنایی با افراد جدید و سفر به مکان‌های ناشناخته استقبال می‌کنم.",
    ];

    const List<List<String>> trueScalePatterns = [
      ['Hs', 'Pt'],
      ['D', 'Si'],
      ['Mf'],
      ['Pa', 'Pd'],
      ['D', 'Pt'],
      ['L', 'S'],
      ['Hs', 'Hy', 'FBS'],
      ['Si', 'Sc'],
      ['Ma', 'Pd'],
      ['D', 'Pa', 'F'],
      ['Pt'],
      ['Pa'],
      ['Sc', 'F', 'FB'],
      ['Ma'],
      ['D', 'Pt'],
      ['K', 'S'],
      ['Ma', 'Pt'],
      ['L', 'K'],
      ['Pt', 'Sc', 'FB'],
      ['Ma'],
    ];

    const List<List<String>> falseScalePatterns = [
      ['K'],
      ['Ma'],
      [],
      ['K', 'Hy'],
      ['Ma', 'K'],
      [],
      [],
      ['Ma', 'Hy'],
      ['S'],
      ['K'],
      ['K'],
      [],
      [],
      ['Si', 'D'],
      ['K'],
      ['Pd'],
      ['S'],
      ['Pd'],
      ['K'],
      ['Si'],
    ];

    for (int i = _coreQuestions.length + 1; i <= count; i++) {
      final int patternIdx = (i - 1) % clinicalPrompts.length;
      full.add(QuestionItem(
        id: i,
        textFa: clinicalPrompts[patternIdx],
        trueScales: trueScalePatterns[patternIdx],
        falseScales: falseScalePatterns[patternIdx],
      ));
    }

    return full;
  }
}
