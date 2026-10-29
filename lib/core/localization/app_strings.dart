class AppStrings {
  final bool isEn;

  const AppStrings(this.isEn);

  // Navigation Bar
  String get navHome => isEn ? 'Assessment' : 'میز کار آزمون';
  String get navPatients => isEn ? 'Patient Records' : 'پرونده مراجعین';
  String get navAnalytics => isEn ? '3D Analytics' : 'تحلیل سه‌بعدی';
  String get navSettings => isEn ? 'Settings' : 'تنظیمات';

  // Brand & Creators
  String get appTitle => 'Nahira MMPI';
  String get appSubtitle => isEn
      ? 'Pearson Clinical Psychometric & 3D Diagnostic Suite'
      : 'سامانه جامع روان‌سنجی و تشخیص بالینی پیرسون';
  String get creatorsLabel => isEn ? 'Designed & Developed by' : 'طراحان و سازندگان';
  String get creatorsNames => isEn
      ? 'Dr. Mohammad Nasirian  •  Dr. Nabiollah Kohan'
      : 'دکتر محمد نصیریان  •  دکتر نبی اله کهن';
  String get drNasirian => isEn ? 'Dr. Mohammad Nasirian' : 'دکتر محمد نصیریان';
  String get drKohan => isEn ? 'Dr. Nabiollah Kohan' : 'دکتر نبی اله کهن';
  String get creatorRole1 => isEn ? 'Clinical Psychologist & Lead Architect' : 'روانشناس بالینی و طراح ارشد سامانه';
  String get creatorRole2 => isEn ? 'Clinical Specialist & Co-Designer' : 'متخصص بالینی و هم‌بنیان‌گذار علمی';
  String get websiteUrl => 'Nasirian.com';

  // Home / Intake
  String get newPatientRegistration => isEn ? 'New Patient Registration' : 'ثبت مشخصات مراجع جدید';
  String get activePatientFile => isEn ? 'Active Patient Profile' : 'پرونده فعال مراجع';
  String get noActivePatientDesc => isEn
      ? 'Register patient details before starting a new clinical assessment, or select an existing file from Patient Records.'
      : 'پیش از آغاز آزمون، مشخصات مراجع جدید را ثبت کنید یا از بخش «پرونده مراجعین» یک پرونده را انتخاب نمایید.';
  String get registerPatientBtn => isEn ? 'Register New Patient' : 'ثبت مراجع جدید';
  String get changePatientBtn => isEn ? 'Edit / Switch Patient' : 'ویرایش یا تغییر مراجع';
  String get fullNameLabel => isEn ? 'Patient Full Name' : 'نام و نام خانوادگی مراجع';
  String get fullNameHint => isEn ? 'Enter full name...' : 'نام و نام خانوادگی را وارد کنید...';
  String get fileCodeLabel => isEn ? 'File / National ID' : 'شماره پرونده یا کد ملی';
  String get fileCodeHint => isEn ? 'Optional ID...' : 'اختیاری...';
  String get ageLabel => isEn ? 'Age (Years)' : 'سن (سال)';
  String get ageHint => isEn ? 'e.g. 28' : 'مثلاً ۲۸';
  String get educationLabel => isEn ? 'Education Level' : 'سطح تحصیلات';
  String get maritalLabel => isEn ? 'Marital Status' : 'وضعیت تأهل';
  String get genderNormLabel => isEn ? 'Normative Gender Table' : 'جدول هنجاری جنسیت';
  String get maleNorm => isEn ? 'Male' : 'مرد';
  String get femaleNorm => isEn ? 'Female' : 'زن';
  String get singleStatus => isEn ? 'Single' : 'مجرد';
  String get marriedStatus => isEn ? 'Married' : 'متأهل';
  String get eduDiploma => isEn ? 'High School / Diploma' : 'دیپلم';
  String get eduBachelor => isEn ? 'Bachelor’s Degree' : 'کارشناسی';
  String get eduMaster => isEn ? 'Master’s Degree' : 'کارشناسی ارشد';
  String get eduPhd => isEn ? 'Doctorate / PhD' : 'دکتری';
  String get saveAndStartBtn => isEn ? 'Confirm & Save Profile' : 'ثبت پرونده و آماده‌سازی آزمون';

  // Test Modes
  String get testModeSectionTitle => isEn ? 'Assessment Form & Protocol' : 'انتخاب پروتکل و فرم آزمون';
  String get mode567Title => isEn ? '567 Items (Complete)' : 'فرم کامل (۵۶۷ گویه)';
  String get mode567Sub => isEn ? 'Clinical + Content + PSY-5' : 'مقیاس‌های بالینی، محتوایی و شخصیت';
  String get mode370Title => isEn ? '370 Items (Standard)' : 'فرم استاندارد (۳۷۰ گویه)';
  String get mode370Sub => isEn ? 'Core Validity & 10 Clinical Scales' : 'مقیاس‌های اعتبار و ۱۰ مقیاس اصلی';
  String get mode30Title => isEn ? '30 Items (Rapid Screening)' : 'فرم غربالگری سریع (۳۰ گویه)';
  String get mode30Sub => isEn ? 'Fast Clinical Screening' : 'ارزیابی سریع اولیه کلینیکی';

  // Main Launch Actions (Pure Persian when in FA, Pure English when in EN)
  String get startTestBtn => isEn ? 'Start Patient Assessment' : 'شروع آزمون استاندارد مراجع';
  String get continueTestBtn => isEn ? 'Resume Assessment' : 'ادامه آزمون مراجع';
  String get startTestSub => isEn
      ? 'Interactive 3D question cards with response latency tracking'
      : 'نمایش سه‌بعدی تک‌گویه‌ای همراه با ثبت زمان واکنش';
  String get rapidConsoleBtn => isEn ? 'Clinician Key Console' : 'کنسول ثبت سریع درمانگر';
  String get rapidConsoleSub => isEn ? 'High-speed paper sheet entry' : 'ورود سریع از روی پاسخبرگ کاغذی';
  String get viewReportBtn => isEn ? '3D Clinical Report' : 'کارنامه و تحلیل سه‌بعدی';
  String get viewReportSub => isEn ? 'Dynamic charts & Pearson narrative' : 'نمودارهای پویا و تفسیر بالینی پیرسون';
  String get resetTestBtn => isEn ? 'Reset Current Answers' : 'پاک‌سازی پاسخ‌های فعلی';

  // Simulator Lab
  String get simulatorTitle => isEn ? 'Clinical Profile Simulation Lab' : 'آزمایشگاه شبیه‌سازی نیمرخ‌های بالینی';
  String get simulatorDesc => isEn
      ? 'Load a standardized clinical pattern to inspect 3D psychometric charts and interpretations instantly:'
      : 'برای مشاهده فوری نمودارهای سه‌بعدی و نحوه تفسیر بالینی، یکی از الگوهای استاندارد زیر را بارگذاری کنید:';
  String get simDepAnx => isEn ? '2-7 Profile (Depression & Anxiety)' : 'نیمرخ ۲-۷ (افسردگی و اضطراب)';
  String get simSomat => isEn ? '1-3 Profile (Somatization)' : 'نیمرخ ۱-۳ (جسمانی‌سازی و هیستری)';
  String get simParanoid => isEn ? '6-8 Profile (Paranoid-Schizoid)' : 'نیمرخ ۶-۸ (پارانوئید و آشفتگی فکر)';
  String get simNormal => isEn ? 'Balanced / Normative Profile' : 'نیمرخ متعادل و بهنجار';

  // Zen Test View (Pure Persian without English clutter)
  String get questionWord => isEn ? 'Item' : 'گویه';
  String get ofWord => isEn ? 'of' : 'از';
  String get answeredWord => isEn ? 'Answered' : 'پاسخ‌داده‌شده';
  String get trueAnswerBtn => isEn ? 'True' : 'درست';
  String get trueAnswerSub => isEn ? 'Applies to me' : 'در مورد من صدق می‌کند';
  String get falseAnswerBtn => isEn ? 'False' : 'غلط';
  String get falseAnswerSub => isEn ? 'Does not apply to me' : 'در مورد من صدق نمی‌کند';
  String get skipQuestionBtn => isEn ? 'Pass / Unsure' : 'عبور از سؤال';
  String get prevQuestionBtn => isEn ? 'Previous' : 'سؤال قبلی';
  String get finishAndAnalyzeBtn => isEn ? 'Complete & Analyze' : 'پایان و صدور کارنامه';
  String get recordedTrue => isEn ? 'Recorded: True' : 'پاسخ ثبت‌شده: درست';
  String get recordedFalse => isEn ? 'Recorded: False' : 'پاسخ ثبت‌شده: غلط';
  String get answerChangesCount => isEn ? 'Answer Changes' : 'تغییر پاسخ';
  String get itemMapTitle => isEn ? 'Assessment Item Navigator' : 'فهرست و نقشه سؤالات آزمون';

  // Rapid Console
  String get rapidConsoleHeader => isEn ? 'Clinician Rapid Entry Console' : 'کنسول ثبت سریع پاسخبرگ درمانگر';
  String get rapidRowNumber => isEn ? 'Answer Sheet Item Number' : 'شماره ردیف در پاسخبرگ';
  String get rapidBlankBtn => isEn ? 'Blank / Omitted' : 'سفید / بدون پاسخ';
  String get rapidUndoBtn => isEn ? 'Step Back' : 'برگشت به قبلی';
  String get rapidAnalyzeBtn => isEn ? 'Generate Report' : 'صدور کارنامه بالینی';

  // Patient Records Screen
  String get recordsHeader => isEn ? 'Patient Clinical Archives' : 'بایگانی پرونده‌های بالینی مراجعین';
  String get searchPatientsHint => isEn ? 'Search by patient name or ID...' : 'جستجوی نام مراجع یا شماره پرونده...';
  String get emptyRecordsTitle => isEn ? 'No Patient Records Saved Yet' : 'هنوز پرونده‌ای در بایگانی ثبت نشده است';
  String get emptyRecordsSub => isEn
      ? 'Completed assessments and registered patients will automatically appear here with full 3D clinical profiles.'
      : 'پس از ثبت مراجع یا تکمیل هر آزمون، پرونده کامل به همراه نیمرخ سه‌بعدی و تفسیر بالینی در این بخش ذخیره می‌شود.';
  String get loadRecordBtn => isEn ? 'Open 3D Report' : 'مشاهده کارنامه سه‌بعدی';
  String get deleteRecordBtn => isEn ? 'Delete' : 'حذف پرونده';

  // Settings Screen
  String get settingsHeader => isEn ? 'System & Clinical Preferences' : 'تنظیمات سامانه و محیط بالینی';
  String get langSectionTitle => isEn ? 'Application Language' : 'زبان برنامه و گزارش‌های بالینی';
  String get themeSectionTitle => isEn ? 'Visual Environment & 3D Depth' : 'پوسته بصری و عمق سه‌بعدی';
  String get themeRoyal => isEn ? 'Royal Sapphire 3D' : 'کبود سلطنتی سه‌بعدی';
  String get themeAmoled => isEn ? 'Obsidian Dark' : 'مشکی عمیق کلینیکی';
  String get themeSepia => isEn ? 'Warm Paper' : 'کاغذی گرم (مطالعه طولانی)';
  String get themeDaylight => isEn ? 'Clinical Daylight' : 'روشن استاندارد کلینیکی';
  String get soundSectionTitle => isEn ? 'Audio Chimes & Tactile Haptics' : 'افکت‌های صوتی و بازخورد لمسی';
  String get soundToggleTitle => isEn ? 'Enable Acoustic Key Chimes' : 'فعال‌سازی صدای دکمه‌ها هنگام پاسخ‌گویی';
  String get soundToggleSub => isEn
      ? 'Synthesizes distinct harmonic tones for True, False, and Skip actions'
      : 'پخش طنین صوتی مجزا برای گزینه‌های درست، غلط و عبور از سؤال';
  String get testSoundBtn => isEn ? 'Test Audio Effect' : 'تست صدای دکمه‌ها';
  String get ergonomicsTitle => isEn ? 'Ergonomics & Typography' : 'ارگونومی و اندازه نوشته‌ها';
  String get leftHandedTitle => isEn ? 'Left-Handed Button Layout' : 'چیدمان دکمه‌ها ویژه افراد چپ‌دست';
  String get fontSizeTitle => isEn ? 'Question Text Size' : 'اندازه متن سؤالات آزمون';

  // Scale Names
  String scaleName(String code) {
    if (isEn) {
      const mapEn = {
        'L': 'Lie / Uncommon Virtues (L)',
        'F': 'Infrequency (F)',
        'K': 'Defensiveness / Correction (K)',
        'FB': 'Back Infrequency (FB)',
        'FP': 'Infrequency-Psychopathology (FP)',
        'FBS': 'Symptom Validity (FBS)',
        'S': 'Superlative Self-Presentation (S)',
        'Hs': '1 - Hypochondriasis (Hs)',
        'D': '2 - Depression (D)',
        'Hy': '3 - Hysteria (Hy)',
        'Pd': '4 - Psychopathic Deviate (Pd)',
        'Mf': '5 - Masculinity-Femininity (Mf)',
        'Pa': '6 - Paranoia (Pa)',
        'Pt': '7 - Psychasthenia / Anxiety (Pt)',
        'Sc': '8 - Schizophrenia (Sc)',
        'Ma': '9 - Hypomania (Ma)',
        'Si': '0 - Social Introversion (Si)',
        'ANX': 'Anxiety (ANX)',
        'FRS': 'Fears (FRS)',
        'OBS': 'Obsessiveness (OBS)',
        'DEP': 'Depression Content (DEP)',
        'HEA': 'Health Concerns (HEA)',
        'BIZ': 'Bizarre Mentation (BIZ)',
        'ANG': 'Anger (ANG)',
        'CYN': 'Cynicism (CYN)',
        'ASP': 'Antisocial Practices (ASP)',
        'TPA': 'Type A Behavior (TPA)',
        'LSE': 'Low Self-Esteem (LSE)',
        'SOD': 'Social Discomfort (SOD)',
        'FAM': 'Family Problems (FAM)',
        'WRK': 'Work Interference (WRK)',
        'TRT': 'Negative Treatment Indicators (TRT)',
        'AGGR': 'Aggressiveness (AGGR)',
        'PSYC': 'Psychoticism (PSYC)',
        'DISC': 'Disconstraint (DISC)',
        'NEGE': 'Negative Emotionality (NEGE)',
        'INTR': 'Introversion / Low Positive Emotion (INTR)',
      };
      return mapEn[code] ?? code;
    } else {
      const mapFa = {
        'L': 'دروغ‌سنج و مطلوب‌نمایی (L)',
        'F': 'پاسخ‌های نامتعارف و نادر (F)',
        'K': 'تدافع و اصلاح بالینی (K)',
        'FB': 'نامتعارف نیمه دوم آزمون (FB)',
        'FP': 'روان‌پریشی نامتعارف (FP)',
        'FBS': 'اعتبار علائم جسمانی-شناختی (FBS)',
        'S': 'خودبرترنمایی مفرط (S)',
        'Hs': '۱ - خودبیمارانگاری (Hs)',
        'D': '۲ - افسردگی (D)',
        'Hy': '۳ - هیستری تبدیلی (Hy)',
        'Pd': '۴ - انحراف روانی-اجتماعی (Pd)',
        'Mf': '۵ - علایق جنسیتی (Mf)',
        'Pa': '۶ - پارانویا و بدگمانی (Pa)',
        'Pt': '۷ - ضعف روانی و اضطراب (Pt)',
        'Sc': '۸ - اسکیزوفرنی و آشفتگی فکر (Sc)',
        'Ma': '۹ - شیدایی خفیف (Ma)',
        'Si': '۰ - درون‌گرایی اجتماعی (Si)',
        'ANX': 'اضطراب فراگیر (ANX)',
        'FRS': 'ترس‌ها و فوبیا (FRS)',
        'OBS': 'وسواس فکری (OBS)',
        'DEP': 'محتوای افسردگی (DEP)',
        'HEA': 'نگرانی‌های سلامتی (HEA)',
        'BIZ': 'افکار عجیب و غریب (BIZ)',
        'ANG': 'خشم و تکانشگری (ANG)',
        'CYN': 'بدبینی به دیگران (CYN)',
        'ASP': 'رفتارهای ضداجتماعی (ASP)',
        'TPA': 'الگوی رفتاری تیپ الف (TPA)',
        'LSE': 'عزت‌نفس پایین (LSE)',
        'SOD': 'ناآرامی اجتماعی (SOD)',
        'FAM': 'تعارضات خانوادگی (FAM)',
        'WRK': 'اختلال در عملکرد شغلی (WRK)',
        'TRT': 'مقاومت در برابر درمان (TRT)',
        'AGGR': 'پرخاشگری ابزاری (AGGR)',
        'PSYC': 'روان‌پریشی‌گرایی (PSYC)',
        'DISC': 'بی‌مهاری و تکانشگری (DISC)',
        'NEGE': 'هیجان‌پذیری منفی و رنجوری (NEGE)',
        'INTR': 'درون‌گرایی و فقدان لذت (INTR)',
      };
      return mapFa[code] ?? code;
    }
  }
}
