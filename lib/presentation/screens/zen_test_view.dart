import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/customization_cubit.dart';
import '../cubits/assessment_cubit.dart';
import '../widgets/three_d_widgets.dart';
import 'report_view.dart';

class ZenTestView extends StatefulWidget {
  const ZenTestView({Key? key}) : super(key: key);

  @override
  State<ZenTestView> createState() => _ZenTestViewState();
}

class _ZenTestViewState extends State<ZenTestView> {
  Future<void> _speakText(String text) async {
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, customState) {
        final palette = NahiraPalette.fromPreset(customState.visualPreset);

        return BlocConsumer<AssessmentCubit, AssessmentState>(
          listener: (context, assessState) {
            if (customState.enableTtsReader) {
              _speakText(assessState.currentQuestion.text);
            }
          },
          builder: (context, assessState) {
            final currentQ = assessState.currentQuestion;
            final currentAns = assessState.answers[assessState.currentIndex];
            final changeCount = assessState.changeCounts[assessState.currentIndex] ?? 0;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette.bgTop, palette.bgBottom],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Top 3D Control Bar
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                          child: Nahira3DCard(
                            depth: 5,
                            borderRadius: 18,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            topColor: palette.cardTop,
                            bottomColor: palette.cardBottom,
                            bevelColor: palette.cardBevel,
                            glowColor: palette.accentPrimary,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => Navigator.pop(context),
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: palette.accentPrimary.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.arrow_back_rounded,
                                              color: palette.textPrimary,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "سؤال ${assessState.currentIndex + 1} از ${assessState.totalQuestions}",
                                              style: TextStyle(
                                                color: palette.textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Text(
                                              "پاسخ‌داده‌شده: ${assessState.answeredCount} | بلی: ${assessState.trueCount} | خیر: ${assessState.falseCount}",
                                              style: TextStyle(
                                                color: palette.textSecondary,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: "خوانش صوتی سؤال",
                                          icon: Icon(
                                            customState.enableTtsReader
                                                ? Icons.record_voice_over_rounded
                                                : Icons.voice_over_off_rounded,
                                            color: customState.enableTtsReader
                                                ? palette.goldAccent
                                                : palette.textSecondary,
                                            size: 22,
                                          ),
                                          onPressed: () {
                                            context.read<CustomizationCubit>().toggleTtsReader();
                                            if (!customState.enableTtsReader) {
                                              _speakText(currentQ.text);
                                            }
                                          },
                                        ),
                                        IconButton(
                                          tooltip: "نقشه سؤالات",
                                          icon: Icon(
                                            Icons.grid_view_rounded,
                                            color: palette.accentPrimary,
                                            size: 22,
                                          ),
                                          onPressed: () => _showQuestionGridModal(context, assessState, palette),
                                        ),
                                        IconButton(
                                          tooltip: "تنظیمات نمایش سه بعدی",
                                          icon: Icon(
                                            Icons.tune_rounded,
                                            color: palette.textPrimary,
                                            size: 22,
                                          ),
                                          onPressed: () => _showSettingsSheet(context, palette),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: assessState.progress,
                                    minHeight: 8,
                                    backgroundColor: Colors.black26,
                                    valueColor: AlwaysStoppedAnimation<Color>(palette.accentPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Center 3D Question Stage
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 260),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: Tween<double>(begin: 0.94, end: 1.0).animate(
                                      CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                                    ),
                                    child: FadeTransition(opacity: animation, child: child),
                                  );
                                },
                                child: Nahira3DCard(
                                  key: ValueKey<int>(assessState.currentIndex),
                                  depth: 10,
                                  tiltX: 0.015,
                                  borderRadius: 28,
                                  topColor: palette.cardTop,
                                  bottomColor: palette.cardBottom,
                                  bevelColor: palette.cardBevel,
                                  glowColor: currentAns == 'T'
                                      ? const Color(0xFF10B981)
                                      : currentAns == 'F'
                                          ? const Color(0xFFF43F5E)
                                          : palette.accentPrimary,
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Question Number & Scale Badge Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [palette.accentPrimary, palette.accentSecondary],
                                              ),
                                              borderRadius: BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: palette.accentPrimary.withOpacity(0.35),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              "گویه شماره ${currentQ.id}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          if (currentAns != 'U')
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: (currentAns == 'T'
                                                        ? const Color(0xFF10B981)
                                                        : const Color(0xFFF43F5E))
                                                    .withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: currentAns == 'T'
                                                      ? const Color(0xFF10B981)
                                                      : const Color(0xFFF43F5E),
                                                ),
                                              ),
                                              child: Text(
                                                currentAns == 'T' ? "ثبت‌شده: بلی (درست)" : "ثبت‌شده: خیر (غلط)",
                                                style: TextStyle(
                                                  color: currentAns == 'T'
                                                      ? const Color(0xFF34D399)
                                                      : const Color(0xFFFB7185),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 28),

                                      // Main Question Text
                                      Text(
                                        currentQ.text,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: palette.textPrimary,
                                          fontSize: customState.questionFontSize,
                                          height: customState.lineHeight,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 26),

                                      // Metadata Footer inside 3D Card
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        alignment: WrapAlignment.center,
                                        children: [
                                          ...currentQ.trueScales.take(4).map(
                                                (s) => Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: palette.accentPrimary.withOpacity(0.12),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    "مقیاس $s",
                                                    style: TextStyle(
                                                      color: palette.textSecondary,
                                                      fontSize: 10.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          if (changeCount > 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.withOpacity(0.18),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "تغییر پاسخ: $changeCount مرتبه",
                                                style: const TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 10.5,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bottom 3D Tactile Thumb-Zone Controls
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                          child: Column(
                            children: [
                              // True / False 3D Push Buttons
                              Row(
                                textDirection:
                                    customState.isLeftHanded ? TextDirection.ltr : TextDirection.rtl,
                                children: [
                                  Expanded(
                                    child: Nahira3DButton(
                                      label: "بلی / درست",
                                      sublabel: "موافقم (True)",
                                      icon: Icons.check_circle_rounded,
                                      primaryColor: const Color(0xFF059669),
                                      darkBevelColor: const Color(0xFF064E3B),
                                      height: 68,
                                      fontSize: 19,
                                      onTap: () {
                                        context.read<CustomizationCubit>().onTherapistRapidKeyTap('T');
                                        context.read<AssessmentCubit>().answerCurrent('T');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Nahira3DButton(
                                      label: "خیر / غلط",
                                      sublabel: "مخالفم (False)",
                                      icon: Icons.cancel_rounded,
                                      primaryColor: const Color(0xFFE11D48),
                                      darkBevelColor: const Color(0xFF881337),
                                      height: 68,
                                      fontSize: 19,
                                      onTap: () {
                                        context.read<CustomizationCubit>().onTherapistRapidKeyTap('F');
                                        context.read<AssessmentCubit>().answerCurrent('F');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Navigation & Finish Row
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Nahira3DButton(
                                      label: "قبلی",
                                      icon: Icons.navigate_before_rounded,
                                      primaryColor: const Color(0xFF334155),
                                      darkBevelColor: const Color(0xFF0F172A),
                                      height: 48,
                                      fontSize: 14,
                                      onTap: () => context.read<AssessmentCubit>().previousQuestion(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 3,
                                    child: Nahira3DButton(
                                      label: "رد کردن (؟)",
                                      primaryColor: const Color(0xFF475569),
                                      darkBevelColor: const Color(0xFF1E293B),
                                      height: 48,
                                      fontSize: 13.5,
                                      onTap: () {
                                        context.read<CustomizationCubit>().onTherapistRapidKeyTap('U');
                                        context.read<AssessmentCubit>().answerCurrent('U');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 4,
                                    child: Nahira3DButton(
                                      label: "پایان و کارنامه",
                                      icon: Icons.analytics_rounded,
                                      primaryColor: const Color(0xFFD97706),
                                      darkBevelColor: const Color(0xFF78350F),
                                      height: 48,
                                      fontSize: 14,
                                      onTap: () {
                                        context.read<AssessmentCubit>().calculateScores();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const ReportView()),
                                        );
                                      },
                                    ),
                                  ),
                                ],
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

  void _showQuestionGridModal(
    BuildContext context,
    AssessmentState assessState,
    NahiraPalette palette,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.bgBottom,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "نقشه سه بعدی سؤالات (${assessState.totalQuestions} گویه)",
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: palette.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: assessState.totalQuestions,
                    itemBuilder: (_, index) {
                      final ans = assessState.answers[index];
                      final isCurrent = index == assessState.currentIndex;
                      Color bg = Colors.white10;
                      if (ans == 'T') bg = const Color(0xFF059669);
                      if (ans == 'F') bg = const Color(0xFFE11D48);

                      return InkWell(
                        onTap: () {
                          context.read<AssessmentCubit>().jumpToQuestion(index);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(10),
                            border: isCurrent
                                ? Border.all(color: Colors.amberAccent, width: 2.5)
                                : Border.all(color: Colors.white24),
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: palette.isDark || ans != 'U' ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsSheet(BuildContext context, NahiraPalette palette) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.bgBottom,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocBuilder<CustomizationCubit, AppCustomizationState>(
          builder: (context, state) {
            final cubit = context.read<CustomizationCubit>();
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "تنظیمات محیط سه بعدی Nahira MMPI",
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "تم نوری و عمق سه بعدی:",
                      style: TextStyle(color: palette.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _presetChip(cubit, state, 'royal_3d', 'رویال سه بعدی (پیش‌فرض)'),
                        _presetChip(cubit, state, 'amoled_black', 'مشکی AMOLED'),
                        _presetChip(cubit, state, 'sepia_warm', 'کاغذی گرم (سپیا)'),
                        _presetChip(cubit, state, 'daylight', 'روشن کلینیکی'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text("اندازه فونت سؤالات:", style: TextStyle(color: palette.textPrimary)),
                        Expanded(
                          child: Slider(
                            value: state.questionFontSize,
                            min: 16.0,
                            max: 30.0,
                            divisions: 7,
                            label: "${state.questionFontSize.round()}",
                            onChanged: (val) => cubit.updateFontSize(val),
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: Text(
                        "چیدمان ارگونومیک چپ‌دست‌ها",
                        style: TextStyle(color: palette.textPrimary, fontSize: 14),
                      ),
                      value: state.isLeftHanded,
                      onChanged: (_) => cubit.toggleLeftHanded(),
                    ),
                    SwitchListTile(
                      title: Text(
                        "افکت صوتی دکمه‌های سه بعدی",
                        style: TextStyle(color: palette.textPrimary, fontSize: 14),
                      ),
                      value: state.enableAudioBeep,
                      onChanged: (_) => cubit.toggleAudioBeep(),
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

  Widget _presetChip(
    CustomizationCubit cubit,
    AppCustomizationState state,
    String key,
    String label,
  ) {
    final selected = state.visualPreset == key;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color(0xFF06B6D4),
      onSelected: (_) => cubit.updateTheme(key),
    );
  }
}
