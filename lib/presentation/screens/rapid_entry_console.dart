import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/customization_cubit.dart';
import '../cubits/assessment_cubit.dart';
import '../widgets/three_d_widgets.dart';
import 'report_view.dart';

class RapidEntryConsole extends StatefulWidget {
  const RapidEntryConsole({Key? key}) : super(key: key);

  @override
  State<RapidEntryConsole> createState() => _RapidEntryConsoleState();
}

class _RapidEntryConsoleState extends State<RapidEntryConsole> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _recordAnswer(BuildContext context, String ans) {
    context.read<CustomizationCubit>().onTherapistRapidKeyTap(ans);
    context.read<AssessmentCubit>().answerCurrent(ans);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, customState) {
        final palette = NahiraPalette.fromPreset(customState.visualPreset);
        final s = customState.strings;
        final isEn = customState.isEn;

        return BlocBuilder<AssessmentCubit, AssessmentState>(
          builder: (context, assessState) {
            final currentIdx = assessState.currentIndex;
            final currentQ = assessState.currentQuestion;

            return Directionality(
              textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
              child: KeyboardListener(
                focusNode: _focusNode,
                autofocus: true,
                onKeyEvent: (KeyEvent event) {
                  if (event is KeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.digit1 ||
                        event.logicalKey == LogicalKeyboardKey.numpad1 ||
                        event.logicalKey == LogicalKeyboardKey.keyT) {
                      _recordAnswer(context, 'T');
                    } else if (event.logicalKey == LogicalKeyboardKey.digit2 ||
                        event.logicalKey == LogicalKeyboardKey.numpad2 ||
                        event.logicalKey == LogicalKeyboardKey.keyF) {
                      _recordAnswer(context, 'F');
                    } else if (event.logicalKey == LogicalKeyboardKey.digit0 ||
                        event.logicalKey == LogicalKeyboardKey.space) {
                      _recordAnswer(context, 'U');
                    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
                      context.read<AssessmentCubit>().previousQuestion();
                    }
                  }
                },
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Top Header 3D Card
                            Nahira3DCard(
                              depth: 5,
                              borderRadius: 18,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              topColor: palette.cardTop,
                              bottomColor: palette.cardBottom,
                              bevelColor: palette.cardBevel,
                              glowColor: const Color(0xFFF59E0B),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () => Navigator.pop(context),
                                        child: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        s.rapidConsoleHeader,
                                        style: TextStyle(
                                          color: palette.textPrimary,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.amber),
                                    ),
                                    child: Text(
                                      "${assessState.answeredCount} / ${assessState.totalQuestions}",
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Sliding Ribbon of Answers
                            SizedBox(
                              height: 54,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: assessState.totalQuestions,
                                itemBuilder: (context, idx) {
                                  final ans = assessState.answers[idx];
                                  final isCurrent = idx == currentIdx;
                                  Color badgeColor = Colors.white10;
                                  if (ans == 'T') badgeColor = const Color(0xFF059669);
                                  if (ans == 'F') badgeColor = const Color(0xFFE11D48);

                                  return GestureDetector(
                                    onTap: () => context.read<AssessmentCubit>().jumpToQuestion(idx),
                                    child: Container(
                                      width: 52,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: badgeColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: isCurrent
                                            ? Border.all(color: Colors.amberAccent, width: 2.2)
                                            : Border.all(color: Colors.white12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "#${idx + 1}",
                                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                                          ),
                                          Text(
                                            ans == 'T'
                                                ? s.trueAnswerBtn
                                                : ans == 'F'
                                                    ? s.falseAnswerBtn
                                                    : '-',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Central 3D Digital Counter & Question Preview
                            Expanded(
                              flex: 4,
                              child: NahiraInteractive3DCard(
                                palette: palette,
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      s.rapidRowNumber,
                                      style: TextStyle(color: palette.textSecondary, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${currentIdx + 1}",
                                      style: const TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF38BDF8),
                                        height: 1.05,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      currentQ.localizedText(isEn),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: palette.textPrimary,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 3D Mechanical Tactile Keypad
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Nahira3DButton(
                                            label: s.trueAnswerBtn,
                                            sublabel: s.trueAnswerSub,
                                            icon: Icons.check_circle_rounded,
                                            primaryColor: const Color(0xFF059669),
                                            darkBevelColor: const Color(0xFF064E3B),
                                            height: 106,
                                            fontSize: 21,
                                            onTap: () => _recordAnswer(context, 'T'),
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
                                            height: 106,
                                            fontSize: 21,
                                            onTap: () => _recordAnswer(context, 'F'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Nahira3DButton(
                                          label: s.rapidBlankBtn,
                                          primaryColor: const Color(0xFF475569),
                                          darkBevelColor: const Color(0xFF1E293B),
                                          height: 54,
                                          fontSize: 13.5,
                                          onTap: () => _recordAnswer(context, 'U'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Nahira3DButton(
                                          label: s.rapidUndoBtn,
                                          icon: Icons.undo_rounded,
                                          primaryColor: const Color(0xFFD97706),
                                          darkBevelColor: const Color(0xFF78350F),
                                          height: 54,
                                          fontSize: 13.5,
                                          onTap: () => context.read<AssessmentCubit>().previousQuestion(),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Nahira3DButton(
                                          label: s.rapidAnalyzeBtn,
                                          icon: Icons.assessment_rounded,
                                          primaryColor: const Color(0xFF4F46E5),
                                          darkBevelColor: const Color(0xFF312E81),
                                          height: 54,
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
                ),
              ),
            );
          },
        );
      },
    );
  }
}
