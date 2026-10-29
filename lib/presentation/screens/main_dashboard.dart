import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/customization_cubit.dart';
import '../cubits/assessment_cubit.dart';
import '../widgets/three_d_widgets.dart';
import 'zen_test_view.dart';
import 'rapid_entry_console.dart';
import 'report_view.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, customState) {
        final palette = NahiraPalette.fromPreset(customState.visualPreset);

        return BlocBuilder<AssessmentCubit, AssessmentState>(
          builder: (context, assessState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette.bgTop, palette.bgBottom],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                      children: [
                        // 1. 3D Branded Hero Banner (Nahira MMPI | Dr. Mohammad Nasirian & Dr. Nabi Tahkohan | Nasirian.com)
                        NahiraHeroBanner(
                          onAboutTap: () => _showCreatorsDialog(context, palette),
                        ),
                        const SizedBox(height: 18),

                        // 2. Client Intake & Test Mode 3D Card
                        Nahira3DCard(
                          depth: 7,
                          tiltX: 0.01,
                          topColor: palette.cardTop,
                          bottomColor: palette.cardBottom,
                          bevelColor: palette.cardBevel,
                          glowColor: palette.accentPrimary,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.person_pin_rounded, color: palette.accentPrimary, size: 22),
                                      const SizedBox(width: 8),
                                      Text(
                                        "پرونده مراجع و پیکربندی آزمون",
                                        style: TextStyle(
                                          color: palette.textPrimary,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _showClientEditModal(context, assessState, palette),
                                    icon: Icon(Icons.edit_note_rounded, color: palette.goldAccent, size: 18),
                                    label: Text(
                                      "ویرایش مشخصات",
                                      style: TextStyle(
                                        color: palette.goldAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _infoBadge("نام: ${assessState.clientName}", palette),
                                  _infoBadge("سن: ${assessState.clientAge} سال", palette),
                                  _infoBadge(
                                    "جنسیت: ${assessState.gender == 'male' ? 'مرد (هنجار مردان)' : 'زن (هنجار زنان)'}",
                                    palette,
                                  ),
                                  _infoBadge("تحصیلات: ${assessState.education}", palette),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                "انتخاب قالب آزمون (تعداد سؤالات):",
                                style: TextStyle(color: palette.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _lengthSelectorButton(
                                    context: context,
                                    count: 567,
                                    label: "۵۶۷ سؤال (کامل)",
                                    current: assessState.totalQuestions,
                                    palette: palette,
                                  ),
                                  const SizedBox(width: 8),
                                  _lengthSelectorButton(
                                    context: context,
                                    count: 370,
                                    label: "۳۷۰ سؤال (کوتاه)",
                                    current: assessState.totalQuestions,
                                    palette: palette,
                                  ),
                                  const SizedBox(width: 8),
                                  _lengthSelectorButton(
                                    context: context,
                                    count: 30,
                                    label: "۳۰ سؤال (دمو سریع)",
                                    current: assessState.totalQuestions,
                                    palette: palette,
                                  ),
                                ],
                              ),
                              if (assessState.answeredCount > 0) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "پاسخ‌های ثبت‌شده: ${assessState.answeredCount} از ${assessState.totalQuestions}",
                                      style: TextStyle(
                                        color: palette.accentPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => context.read<AssessmentCubit>().resetTest(),
                                      child: const Text(
                                        "شروع مجدد (صفر کردن)",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 3. Primary 3D Action Buttons
                        Nahira3DButton(
                          label: assessState.answeredCount > 0
                              ? "ادامه آزمون سه بعدی مراجع (سؤال ${assessState.currentIndex + 1})"
                              : "شروع آزمون سه بعدی مراجع (Zen 3D)",
                          sublabel: "محیط تعاملی سه بعدی، خوانش صوتی و دکمه‌های ارگونومیک",
                          icon: Icons.play_circle_fill_rounded,
                          primaryColor: const Color(0xFF0284C7),
                          darkBevelColor: const Color(0xFF075985),
                          height: 74,
                          fontSize: 17,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ZenTestView()),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Nahira3DButton(
                                label: "کنسول ۵ کلیده درمانگر",
                                sublabel: "ثبت فوق سریع پاسخبرگ",
                                icon: Icons.dialpad_rounded,
                                primaryColor: const Color(0xFF0D9488),
                                darkBevelColor: const Color(0xFF115E59),
                                height: 68,
                                fontSize: 14.5,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RapidEntryConsole()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Nahira3DButton(
                                label: "کارنامه و نمودار پیرسون",
                                sublabel: "نیمرخ T، کد ولش و تفسیر",
                                icon: Icons.insights_rounded,
                                primaryColor: const Color(0xFF6366F1),
                                darkBevelColor: const Color(0xFF3730A3),
                                height: 68,
                                fontSize: 14.5,
                                onTap: () {
                                  context.read<AssessmentCubit>().calculateScores();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ReportView()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 4. Instant Clinical Profile Simulator (1-Tap Testing)
                        Nahira3DCard(
                          depth: 6,
                          topColor: palette.cardTop,
                          bottomColor: palette.cardBottom,
                          bevelColor: palette.cardBevel,
                          glowColor: palette.goldAccent,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_graph_rounded, color: palette.goldAccent, size: 22),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "آزمایشگاه شبیه‌ساز فوری نیمرخ بالینی (تست ۱ ثانیه‌ای)",
                                      style: TextStyle(
                                        color: palette.textPrimary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "برای بررسی فوری الگوریتم نمره‌دهی پیرسون و نمودارها، یکی از نیمرخ‌های بالینی استاندارد زیر را بارگذاری کنید:",
                                style: TextStyle(color: palette.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _simButton(
                                    context,
                                    preset: 'depression_anxiety',
                                    label: "نیمرخ ۲-۷ (افسردگی و اضطراب)",
                                    color: const Color(0xFFE11D48),
                                  ),
                                  _simButton(
                                    context,
                                    preset: 'somatization',
                                    label: "نیمرخ ۱-۳ (جسمانی‌سازی / هیستری)",
                                    color: const Color(0xFFD97706),
                                  ),
                                  _simButton(
                                    context,
                                    preset: 'paranoid_schizo',
                                    label: "نیمرخ ۶-۸ (پارانوئید / اسکیزوئید)",
                                    color: const Color(0xFF7C3AED),
                                  ),
                                  _simButton(
                                    context,
                                    preset: 'normal',
                                    label: "نیمرخ بهنجار و متعادل",
                                    color: const Color(0xFF059669),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 5. 3D Visual Theme Switcher Card
                        Nahira3DCard(
                          depth: 5,
                          topColor: palette.cardTop,
                          bottomColor: palette.cardBottom,
                          bevelColor: palette.cardBevel,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "پوسته سه بعدی و تم نوری برنامه:",
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _themePill(context, customState, 'royal_3d', 'رویال سه بعدی'),
                                    const SizedBox(width: 8),
                                    _themePill(context, customState, 'amoled_black', 'مشکی AMOLED'),
                                    const SizedBox(width: 8),
                                    _themePill(context, customState, 'sepia_warm', 'سپیا کاغذی'),
                                    const SizedBox(width: 8),
                                    _themePill(context, customState, 'daylight', 'روشن کلینیکی'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 6. Footer Attribution Card
                        Nahira3DCard(
                          depth: 4,
                          topColor: palette.cardTop,
                          bottomColor: palette.cardBottom,
                          bevelColor: palette.cardBevel,
                          padding: const EdgeInsets.all(14),
                          onTap: () => _showCreatorsDialog(context, palette),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Nahira MMPI — نسخه حرفه‌ای سه بعدی ۲.۰",
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "سازندگان: دکتر محمد نصیریان و دکتر نبی تاه کهن",
                                    style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
                                  ),
                                ],
                              ),
                              Text(
                                "Nasirian.com",
                                style: TextStyle(
                                  color: palette.goldAccent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoBadge(String text, NahiraPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: TextStyle(color: palette.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _lengthSelectorButton({
    required BuildContext context,
    required int count,
    required String label,
    required int current,
    required NahiraPalette palette,
  }) {
    final isSelected = count == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<AssessmentCubit>().setTestLength(count),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [palette.accentPrimary, palette.accentSecondary])
                : null,
            color: isSelected ? null : Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white54 : Colors.white12,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : palette.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _simButton(
    BuildContext context, {
    required String preset,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        context.read<AssessmentCubit>().loadSimulatedProfile(preset);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportView()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themePill(
    BuildContext context,
    AppCustomizationState state,
    String preset,
    String label,
  ) {
    final selected = state.visualPreset == preset;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color(0xFF06B6D4),
      onSelected: (_) => context.read<CustomizationCubit>().updateTheme(preset),
    );
  }

  void _showClientEditModal(
    BuildContext context,
    AssessmentState state,
    NahiraPalette palette,
  ) {
    final nameCtrl = TextEditingController(text: state.clientName);
    final ageCtrl = TextEditingController(text: "${state.clientAge}");
    final eduCtrl = TextEditingController(text: state.education);
    String selectedGender = state.gender;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.bgBottom,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ثبت مشخصات مراجع (هنجاریابی پیرسون)",
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      style: TextStyle(color: palette.textPrimary),
                      decoration: InputDecoration(
                        labelText: "نام و نام خانوادگی مراجع",
                        labelStyle: TextStyle(color: palette.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageCtrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: palette.textPrimary),
                            decoration: InputDecoration(
                              labelText: "سن (سال)",
                              labelStyle: TextStyle(color: palette.textSecondary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: eduCtrl,
                            style: TextStyle(color: palette.textPrimary),
                            decoration: InputDecoration(
                              labelText: "تحصیلات",
                              labelStyle: TextStyle(color: palette.textSecondary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text("جدول هنجار جنسیت:", style: TextStyle(color: palette.textPrimary)),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text("مرد (Male Norms)"),
                          selected: selectedGender == 'male',
                          onSelected: (_) => setModalState(() => selectedGender = 'male'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("زن (Female Norms)"),
                          selected: selectedGender == 'female',
                          onSelected: (_) => setModalState(() => selectedGender = 'female'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Nahira3DButton(
                      label: "ذخیره اطلاعات مراجع",
                      icon: Icons.save_rounded,
                      primaryColor: const Color(0xFF059669),
                      darkBevelColor: const Color(0xFF064E3B),
                      height: 52,
                      fontSize: 15,
                      onTap: () {
                        context.read<AssessmentCubit>().updateClientInfo(
                              clientName: nameCtrl.text.trim().isEmpty
                                  ? 'مراجع کلینیک ناهیرا'
                                  : nameCtrl.text.trim(),
                              clientAge: int.tryParse(ageCtrl.text) ?? 30,
                              education: eduCtrl.text.trim(),
                              gender: selectedGender,
                            );
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreatorsDialog(BuildContext context, NahiraPalette palette) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: palette.cardTop,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Icon(Icons.verified_rounded, color: palette.goldAccent, size: 28),
              const SizedBox(width: 8),
              Text(
                "درباره Nahira MMPI",
                style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "سامانه تخصصی سه بعدی روان‌سنجی و تفسیر بالینی آزمون چندوجهی شخصیت مینه‌سوتا (MMPI-2) بر اساس استاندارد پیرسون.",
                style: TextStyle(color: palette.textSecondary, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 14),
              Text(
                "طراحان و سازندگان:",
                style: TextStyle(color: palette.goldAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                "• دکتر محمد نصیریان\n• دکتر نبی تاه کهن",
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "وب‌سایت رسمی سازنده:",
                style: TextStyle(color: palette.goldAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: "https://Nasirian.com"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("آدرس سایت Nasirian.com کپی شد.")),
                  );
                },
                child: const Text(
                  "https://Nasirian.com",
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("بستن", style: TextStyle(color: palette.goldAccent)),
            ),
          ],
        ),
      ),
    );
  }
}
