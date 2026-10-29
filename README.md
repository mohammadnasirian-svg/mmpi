# MMPI-2 ULTRA (Pearson Compliant)

سامانه جامع ارزیابی بالینی و روان‌سنجی آزمون پرسشنامه شخصیتی چندوجهی مینه‌سوتا (MMPI-2) منطبق بر استانداردهای پیرسون (Pearson) و شاخص‌های شاخص گاف (Gough).

---

## 🏗 ساختار معماری (Clean Architecture + BLoC)

پروژه به صورت لایه‌بندی‌شده و ماژولار طراحی شده است:

```
d:/mmpi/
├── pubspec.yaml                          # مشخصات پکیج‌ها و وابستگی‌های مورد نیاز
├── analysis_options.yaml                 # قوانین استاتیک آنالیز کدهای دارت
├── bundle.md                             # فایل تجمیعی قابل اکسترکت خودکار
└── lib/
    ├── main.dart                         # نقطه ورود اپلیکیشن با پشتیبانی RTL
    ├── core/
    │   └── utils/
    │       └── sound_service.dart        # بازخورد صوتی و فرکانس‌های شنیداری
    ├── domain/
    │   ├── models/
    │   │   ├── question_item.dart        # مدل داده گزاره‌های آزمون
    │   │   ├── scanned_answer_item.dart  # مدل خروجی اسکنر بینایی هوش مصنوعی
    │   │   └── pearson_scoring_result.dart # مدل خروجی نمرات خام، T، کدهای ولش و ۲-نقطه‌ای
    │   └── usecases/
    │       └── pearson_scoring_engine.dart # موتور محاسبات دقیق روان‌سنجی پیرسون
    ├── data/
    │   ├── database/
    │   │   ├── tables.dart               # جداول دیتابیس Drift (SQLite + SQLCipher)
    │   │   └── app_database.dart         # کلاس پایگاه‌داده Drift و متدهای DAO
    │   └── services/
    │       ├── ai_omr_scanner_service.dart # اسکنر هوشمند پاسخنامه کاغذی با Gemini Vision
    │       └── sample_question_bank.dart   # بانک استاندارد گزاره‌های MMPI-2 به زبان فارسی
    └── presentation/
        ├── cubits/
        │   ├── customization_cubit.dart  # مدیریت حالات رابط کاربری (تم، فونت، راست‌دست/چپ‌دست)
        │   └── assessment_cubit.dart     # مدیریت چرخه حیات آزمون و پاسخ‌دهی
        └── screens/
            ├── main_dashboard.dart       # داشبورد مدیریت کلینیک
            ├── zen_test_view.dart        # محیط آزمون مراجع (Zen UI ضدخستگی)
            ├── rapid_entry_console.dart  # کنسول ۵ کلیدی ورود سریع درمانگر
            └── report_view.dart          # کارنامه بالینی، نمودارهای نمرات T و هشدارهای بحرانی
```

---

## 🚀 راه‌اندازی و اجرا

### ۱. اکسترکت مجدد در صورت نیاز:
```bash
python3 -c "import os, re; content = open('bundle.md', 'r', encoding='utf-8').read(); matches = re.finditer(r'### File: (.*?)\n```(?:yaml|dart)\n(.*?)\n```', content, re.DOTALL); [(os.makedirs(os.path.dirname(m.group(1)), exist_ok=True) if os.path.dirname(m.group(1)) else None, open(m.group(1), 'w', encoding='utf-8').write(m.group(2))) for m in matches]"
```

### ۲. دریافت پکیج‌ها (پس از نصب فلاتر):
```bash
flutter pub get
```

### ۳. تولید کدهای دیتابیس Drift:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### ۴. اجرای اپلیکیشن:
```bash
flutter run
```

---

## 🔑 قابلیت‌های برجسته

1. **موتور روان‌سنجی پیرسون (Pearson Scoring Engine)**:
   - اعمال دقیق ضرایب اصلاح K برای مقیاس‌های بالینی (Hs + 0.5K, Pd + 0.4K, Pt + 1.0K, Sc + 1.0K, Ma + 0.2K).
   - محاسبه شاخص عدم انطباق گاف (F - K Index).
   - استخراج خودکار کد دو نقطه‌ای (Two-Point Code) و کد ولش (Welsh Code).
   - تشخیص و هشدار گویه‌های بحرانی (Critical Items) با اولویت افکار خودکشی و بحران عاطفی.

2. **محیط آزمون مراجع (Zen Mode)**:
   - طراحی متناسب با ناحیه شست دست (Thumb-Zone) جهت کاهش خطای حرکتی.
   - پشتیبانی از تم‌های Daylight، Sepia Warm، Slate Dark و AMOLED Black.
   - قابلیت تعویض آنی حالت چپ‌دست / راست‌دست.

3. **کنسول ورود سریع درمانگر (Rapid Entry Console)**:
   - ثبت ۵۶۷ پاسخ در کمتر از ۳ دقیقه با کلیدهای میانبر فیزیکی (`1` برای درست، `2` برای غلط، `0` برای مبهم).
   - فیدبک‌های صوتی با فرکانس مجزا (800Hz برای T و 450Hz برای F) همراه با لرزش هپتیک.

4. **پایگاه داده امن Drift + SQLCipher**:
   - رمزنگاری اطلاعات حساس مراجعین و پروفایل‌های نمرات در سطح دیسک.
