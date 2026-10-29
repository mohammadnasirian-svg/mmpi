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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, customState) {
        final palette = NahiraPalette.fromPreset(customState.visualPreset);
        final s = customState.strings;
        final isEn = customState.isEn;

        return BlocBuilder<AssessmentCubit, AssessmentState>(
          builder: (context, assessState) {
            final currentQ = assessState.currentQuestion;
            final currentAns = assessState.answers[assessState.currentIndex];
            final changeCount = assessState.changeCounts[assessState.currentIndex] ?? 0;

            return Directionality(
              textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
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
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                            padding: const EdgeInsets.all(7),
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
                                              "${s.questionWord} ${assessState.currentIndex + 1} ${s.ofWord} ${assessState.totalQuestions}",
                                              style: TextStyle(
                                                color: palette.textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${s.answeredWord}: ${assessState.answeredCount}  •  ${s.trueAnswerBtn}: ${assessState.trueCount}  •  ${s.falseAnswerBtn}: ${assessState.falseCount}",
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
                                          tooltip: s.itemMapTitle,
                                          icon: Icon(
                                            Icons.grid_view_rounded,
                                            color: palette.accentPrimary,
                                            size: 22,
                                          ),
                                          onPressed: () => _showQuestionGridModal(context, assessState, palette, s, isEn),
                                        ),
                                        IconButton(
                                          tooltip: s.settingsHeader,
                                          icon: Icon(
                                            Icons.tune_rounded,
                                            color: palette.textPrimary,
                                            size: 22,
                                          ),
                                          onPressed: () => _showQuickDisplaySheet(context, palette, s, isEn),
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
                                    minHeight: 7,
                                    backgroundColor: Colors.black26,
                                    valueColor: AlwaysStoppedAnimation<Color>(palette.accentPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Center Interactive 3D Question Stage
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 240),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                      CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                                    ),
                                    child: FadeTransition(opacity: animation, child: child),
                                  );
                                },
                                child: NahiraInteractive3DCard(
                                  key: ValueKey<int>(assessState.currentIndex),
                                  palette: palette,
                                  padding: const EdgeInsets.all(24),
                                  glowColor: currentAns == 'T'
                                      ? const Color(0xFF10B981)
                                      : currentAns == 'F'
                                          ? const Color(0xFFF43F5E)
                                          : palette.accentPrimary,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Question Number & Status Badge Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [palette.accentPrimary, palette.accentSecondary],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "${s.questionWord} ${currentQ.id}",
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
                                                    .withOpacity(0.16),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: currentAns == 'T'
                                                      ? const Color(0xFF10B981)
                                                      : const Color(0xFFF43F5E),
                                                ),
                                              ),
                                              child: Text(
                                                currentAns == 'T' ? s.recordedTrue : s.recordedFalse,
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

                                      // Main Question Text (Localized FA or EN)
                                      Text(
                                        currentQ.localizedText(isEn),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: palette.textPrimary,
                                          fontSize: customState.questionFontSize,
                                          height: customState.lineHeight,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      if (changeCount > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.16),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "${s.answerChangesCount}: $changeCount",
                                            style: const TextStyle(
                                              color: Colors.amber,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bottom Ergonomic 3D Controls
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                          child: Column(
                            children: [
                              Row(
                                textDirection:
                                    customState.isLeftHanded ? TextDirection.ltr : TextDirection.rtl,
                                children: [
                                  Expanded(
                                    child: Nahira3DButton(
                                      label: s.trueAnswerBtn,
                                      sublabel: s.trueAnswerSub,
                                      icon: Icons.check_circle_rounded,
                                      primaryColor: const Color(0xFF059669),
                                      darkBevelColor: const Color(0xFF064E3B),
                                      height: 66,
                                      fontSize: 18,
                                      onTap: () {
                                        context.read<CustomizationCubit>().onTherapistRapidKeyTap('T');
                                        context.read<AssessmentCubit>().answerCurrent('T');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Nahira3DButton(
                                      label: s.falseAnswerBtn,
                                      sublabel: s.falseAnswerSub,
                                      icon: Icons.cancel_rounded,
                                      primaryColor: const Color(0xFFE11D48),
                                      darkBevelColor: const Color(0xFF881337),
                                      height: 66,
                                      fontSize: 18,
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
                                      label: s.prevQuestionBtn,
                                      icon: Icons.navigate_before_rounded,
                                      primaryColor: const Color(0xFF334155),
                                      darkBevelColor: const Color(0xFF0F172A),
                                      height: 48,
                                      fontSize: 13.5,
                                      onTap: () => context.read<AssessmentCubit>().previousQuestion(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 3,
                                    child: Nahira3DButton(
                                      label: s.skipQuestionBtn,
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
                                      label: s.finishAndAnalyzeBtn,
                                      icon: Icons.analytics_rounded,
                                      primaryColor: const Color(0xFFD97706),
                                      darkBevelColor: const Color(0xFF78350F),
                                      height: 48,
                                      fontSize: 13.5,
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
    dynamic s,
    bool isEn,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.bgBottom,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${s.itemMapTitle} (${assessState.totalQuestions})",
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 16,
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

  void _showQuickDisplaySheet(
    BuildContext context,
    NahiraPalette palette,
    dynamic s,
    bool isEn,
  ) {
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
              textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.ergonomicsTitle,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(s.fontSizeTitle, style: TextStyle(color: palette.textPrimary)),
                        Expanded(
                          child: Slider(
                            value: state.questionFontSize,
                            min: 16.0,
                            max: 28.0,
                            divisions: 6,
                            label: "${state.questionFontSize.round()}",
                            onChanged: (val) => cubit.updateFontSize(val),
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: Text(
                        s.leftHandedTitle,
                        style: TextStyle(color: palette.textPrimary, fontSize: 14),
                      ),
                      value: state.isLeftHanded,
                      onChanged: (_) => cubit.toggleLeftHanded(),
                    ),
                    SwitchListTile(
                      title: Text(
                        s.soundToggleTitle,
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
}
