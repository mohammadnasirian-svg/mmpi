import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/customization_cubit.dart';
import '../cubits/assessment_cubit.dart';
import 'report_view.dart';

class RapidEntryConsole extends StatefulWidget {
  const RapidEntryConsole({Key? key}) : super(key: key);

  @override
  State<RapidEntryConsole> createState() => _RapidEntryConsoleState();
}

class _RapidEntryConsoleState extends State<RapidEntryConsole> {
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final cubit = context.read<AssessmentCubit>();
    final sound = context.read<CustomizationCubit>();

    if (key == LogicalKeyboardKey.keyT || key == LogicalKeyboardKey.numpad1 || key == LogicalKeyboardKey.digit1) {
      sound.onTherapistRapidKeyTap('T');
      cubit.answerCurrent('T');
    } else if (key == LogicalKeyboardKey.keyF || key == LogicalKeyboardKey.numpad2 || key == LogicalKeyboardKey.digit2) {
      sound.onTherapistRapidKeyTap('F');
      cubit.answerCurrent('F');
    } else if (key == LogicalKeyboardKey.keyU || key == LogicalKeyboardKey.numpad0 || key == LogicalKeyboardKey.digit0 || key == LogicalKeyboardKey.space) {
      sound.onTherapistRapidKeyTap('U');
      cubit.answerCurrent('U');
    } else if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.backspace) {
      cubit.previousQuestion();
    } else if (key == LogicalKeyboardKey.arrowRight) {
      cubit.nextQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: BlocBuilder<CustomizationCubit, AppCustomizationState>(
        builder: (context, customState) {
          return BlocConsumer<AssessmentCubit, AssessmentState>(
            listener: (context, assessState) {
              if (assessState.isCompleted && assessState.scoringResult != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportView()),
                );
              }
            },
            builder: (context, state) {
              final currentNo = state.currentIndex + 1;
              final prevNo = state.currentIndex > 0 ? state.currentIndex : null;
              final prevAnswer = prevNo != null ? state.answers[prevNo - 1] : '-';
              final nextNo = state.currentIndex < state.totalQuestions - 1 ? state.currentIndex + 2 : null;
              final nextAnswer = nextNo != null ? state.answers[nextNo - 1] : '-';

              return Scaffold(
                backgroundColor: const Color(0xFF141414),
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  title: const Text("کنسول ورود سریع درمانگر (Rapid Entry)"),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.calculate_outlined),
                      tooltip: "محاسبه نتایج",
                      onPressed: () {
                        context.read<AssessmentCubit>().calculateScores();
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Top Telemetry Display
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      color: Colors.black,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniIndicator(
                            label: prevNo != null ? "[$prevNo: $prevAnswer]" : "[--]",
                            color: Colors.grey,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade900,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "◀ سوال $currentNo از ${state.totalQuestions} ▶",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          _buildMiniIndicator(
                            label: nextNo != null ? "[$nextNo: $nextAnswer]" : "[--]",
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),

                    // Active question summary preview
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFF222222),
                      child: Text(
                        state.currentQuestion.textFa,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Main Split Touch Zones (F / T)
                    Expanded(
                      child: Row(
                        children: [
                          // False Zone (Red)
                          Expanded(
                            child: GestureDetector(
                              onTapDown: (_) {
                                context.read<CustomizationCubit>().onTherapistRapidKeyTap('F');
                                context.read<AssessmentCubit>().answerCurrent('F');
                              },
                              child: Container(
                                color: const Color(0xFFB71C1C),
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.close, color: Colors.white, size: 72),
                                      SizedBox(height: 12),
                                      Text(
                                        "غلط (F)\n[کلید 2]",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // True Zone (Green)
                          Expanded(
                            child: GestureDetector(
                              onTapDown: (_) {
                                context.read<CustomizationCubit>().onTherapistRapidKeyTap('T');
                                context.read<AssessmentCubit>().answerCurrent('T');
                              },
                              child: Container(
                                color: const Color(0xFF1B5E20),
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check, color: Colors.white, size: 72),
                                      SizedBox(height: 12),
                                      Text(
                                        "درست (T)\n[کلید 1]",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Toolbar (Correction, Uncertain, Jump)
                    Container(
                      height: 84,
                      color: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade800),
                            onPressed: () => context.read<AssessmentCubit>().previousQuestion(),
                            icon: const Icon(Icons.undo),
                            label: const Text("قبلی (اصلاح)"),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<CustomizationCubit>().onTherapistRapidKeyTap('U');
                              context.read<AssessmentCubit>().answerCurrent('U');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade800,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "مبهم / خالی (?)\n[کلید 0 یا Space]",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade800),
                            onPressed: () => context.read<AssessmentCubit>().nextQuestion(),
                            icon: const Icon(Icons.redo),
                            label: const Text("رد کردن"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMiniIndicator({required String label, required Color color}) {
    return Text(
      label,
      style: TextStyle(color: color, fontSize: 16, fontFamily: 'monospace'),
    );
  }
}
