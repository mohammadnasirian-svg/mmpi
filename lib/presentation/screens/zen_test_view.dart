import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/customization_cubit.dart';
import '../cubits/assessment_cubit.dart';
import 'report_view.dart';

class ZenTestView extends StatelessWidget {
  const ZenTestView({Key? key}) : super(key: key);

  Color _getBackgroundColor(String preset) {
    switch (preset) {
      case 'sepia_warm': return const Color(0xFFF4ECD8);
      case 'slate_dark': return const Color(0xFF1E293B);
      case 'amoled_black': return Colors.black;
      case 'daylight':
      default: return const Color(0xFFF8FAFC);
    }
  }

  Color _getCardColor(String preset) {
    switch (preset) {
      case 'sepia_warm': return const Color(0xFFFCF8EF);
      case 'slate_dark': return const Color(0xFF334155);
      case 'amoled_black': return const Color(0xFF121212);
      case 'daylight':
      default: return Colors.white;
    }
  }

  Color _getTextColor(String preset) {
    switch (preset) {
      case 'slate_dark':
      case 'amoled_black':
        return const Color(0xFFF1F5F9);
      case 'sepia_warm':
        return const Color(0xFF2C2416);
      case 'daylight':
      default:
        return const Color(0xFF0F172A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, customState) {
        final bgColor = _getBackgroundColor(customState.visualPreset);
        final cardColor = _getCardColor(customState.visualPreset);
        final textColor = _getTextColor(customState.visualPreset);

        return BlocConsumer<AssessmentCubit, AssessmentState>(
          listener: (context, assessState) {
            if (assessState.isCompleted && assessState.scoringResult != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ReportView()),
              );
            }
          },
          builder: (context, assessState) {
            final q = assessState.currentQuestion;
            final currentNum = assessState.currentIndex + 1;
            final total = assessState.totalQuestions;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                backgroundColor: bgColor,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: textColor),
                  centerTitle: true,
                  title: Text(
                    "گزاره $currentNum از $total",
                    style: TextStyle(
                      fontFamily: customState.fontFamily,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.palette_outlined),
                      tooltip: "تغییر تم رنگی",
                      onPressed: () => _showThemeDialog(context),
                    ),
                    IconButton(
                      icon: Icon(customState.isLeftHanded ? Icons.handyman : Icons.pan_tool_outlined),
                      tooltip: "حالت دست چپ/راست",
                      onPressed: () => context.read<CustomizationCubit>().toggleLeftHanded(),
                    ),
                  ],
                ),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      children: [
                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: assessState.progress,
                            minHeight: 8,
                            backgroundColor: textColor.withOpacity(0.1),
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Question Card
                        Expanded(
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Container(
                                key: ValueKey(q.id),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      q.textFa,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: customState.fontFamily,
                                        fontSize: customState.questionFontSize,
                                        height: customState.lineHeight,
                                        color: textColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Ergonomic Thumb-Zone Buttons
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Row(
                            textDirection: customState.isLeftHanded ? TextDirection.ltr : TextDirection.rtl,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // False Button
                              _buildAnswerButton(
                                label: "خیر / نادرست",
                                color: const Color(0xFFE53935),
                                icon: Icons.close_rounded,
                                onTap: () {
                                  context.read<CustomizationCubit>().onTherapistRapidKeyTap('F');
                                  context.read<AssessmentCubit>().answerCurrent('F');
                                },
                              ),
                              // True Button
                              _buildAnswerButton(
                                label: "بله / درست",
                                color: const Color(0xFF00897B),
                                icon: Icons.check_rounded,
                                onTap: () {
                                  context.read<CustomizationCubit>().onTherapistRapidKeyTap('T');
                                  context.read<AssessmentCubit>().answerCurrent('T');
                                },
                              ),
                            ],
                          ),
                        ),

                        // Navigation arrows and Uncertain option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: assessState.currentIndex > 0
                                  ? () => context.read<AssessmentCubit>().previousQuestion()
                                  : null,
                              icon: const Icon(Icons.arrow_forward_ios, size: 16),
                              label: const Text("گزاره قبلی"),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<CustomizationCubit>().onTherapistRapidKeyTap('U');
                                context.read<AssessmentCubit>().answerCurrent('U');
                              },
                              child: const Text("نمی‌دانم / مبهم (?)", style: TextStyle(color: Colors.amber)),
                            ),
                            TextButton.icon(
                              onPressed: assessState.currentIndex < assessState.totalQuestions - 1
                                  ? () => context.read<AssessmentCubit>().nextQuestion()
                                  : null,
                              icon: const Icon(Icons.arrow_back_ios, size: 16),
                              label: const Text("گزاره بعدی"),
                            ),
                          ],
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

  Widget _buildAnswerButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 155,
        height: 64,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("انتخاب تم نمایشی", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFF5F7FA)),
                title: const Text("روشن استاندارد (Daylight)"),
                onTap: () {
                  context.read<CustomizationCubit>().updateTheme('daylight');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFF4ECD8)),
                title: const Text("سپیا آرامش‌بخش (Sepia Warm)"),
                onTap: () {
                  context.read<CustomizationCubit>().updateTheme('sepia_warm');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFF2C3E50)),
                title: const Text("تاریک خاکستری (Slate Dark)"),
                onTap: () {
                  context.read<CustomizationCubit>().updateTheme('slate_dark');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.black),
                title: const Text("مشکی مطلق (AMOLED Black)"),
                onTap: () {
                  context.read<CustomizationCubit>().updateTheme('amoled_black');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
