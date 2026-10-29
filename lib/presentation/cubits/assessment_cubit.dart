import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/question_item.dart';
import '../../domain/models/pearson_scoring_result.dart';
import '../../domain/usecases/pearson_scoring_engine.dart';
import '../../data/services/sample_question_bank.dart';

class AssessmentState {
  final int totalQuestions;
  final int currentIndex;
  final List<String> answers;
  final List<QuestionItem> questionBank;
  final String gender;
  final Map<int, int> changeCounts;
  final Map<int, int> itemDurationsMs;
  final DateTime? startTime;
  final bool isCompleted;
  final PearsonScoringResult? scoringResult;

  const AssessmentState({
    required this.totalQuestions,
    required this.currentIndex,
    required this.answers,
    required this.questionBank,
    required this.gender,
    required this.changeCounts,
    required this.itemDurationsMs,
    this.startTime,
    this.isCompleted = false,
    this.scoringResult,
  });

  factory AssessmentState.initial({int totalQuestions = 567, String gender = 'male'}) {
    final bank = MMPIQuestionBank.getFullBank(totalQuestions);
    return AssessmentState(
      totalQuestions: totalQuestions,
      currentIndex: 0,
      answers: List.filled(totalQuestions, 'U'),
      questionBank: bank,
      gender: gender,
      changeCounts: {},
      itemDurationsMs: {},
      startTime: DateTime.now(),
      isCompleted: false,
    );
  }

  AssessmentState copyWith({
    int? totalQuestions,
    int? currentIndex,
    List<String> answers,
    List<QuestionItem>? questionBank,
    String? gender,
    Map<int, int>? changeCounts,
    Map<int, int>? itemDurationsMs,
    DateTime? startTime,
    bool? isCompleted,
    PearsonScoringResult? scoringResult,
  }) {
    return AssessmentState(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      questionBank: questionBank ?? this.questionBank,
      gender: gender ?? this.gender,
      changeCounts: changeCounts ?? this.changeCounts,
      itemDurationsMs: itemDurationsMs ?? this.itemDurationsMs,
      startTime: startTime ?? this.startTime,
      isCompleted: isCompleted ?? this.isCompleted,
      scoringResult: scoringResult ?? this.scoringResult,
    );
  }

  int get answeredCount => answers.where((a) => a != 'U').length;
  double get progress => totalQuestions > 0 ? (currentIndex + 1) / totalQuestions : 0.0;
  QuestionItem get currentQuestion => questionBank[currentIndex];
}

class AssessmentCubit extends Cubit<AssessmentState> {
  AssessmentCubit() : super(AssessmentState.initial());

  void setGender(String gender) {
    emit(state.copyWith(gender: gender));
  }

  void answerCurrent(String answer) {
    final idx = state.currentIndex;
    final List<String> updatedAnswers = List.from(state.answers);
    
    final changeCount = (state.changeCounts[idx] ?? 0) + (updatedAnswers[idx] != 'U' ? 1 : 0);
    final updatedChangeCounts = Map<int, int>.from(state.changeCounts);
    updatedChangeCounts[idx] = changeCount;

    updatedAnswers[idx] = answer;

    int nextIdx = state.currentIndex + 1;
    bool completed = false;
    if (nextIdx >= state.totalQuestions) {
      nextIdx = state.totalQuestions - 1;
      completed = true;
    }

    emit(state.copyWith(
      answers: updatedAnswers,
      currentIndex: nextIdx,
      changeCounts: updatedChangeCounts,
      isCompleted: completed,
    ));

    if (completed) {
      calculateScores();
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  void nextQuestion() {
    if (state.currentIndex < state.totalQuestions - 1) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < state.totalQuestions) {
      emit(state.copyWith(currentIndex: index));
    }
  }

  void calculateScores() {
    final result = PearsonScoringEngine.evaluate(
      answers: state.answers,
      gender: state.gender,
      bank: state.questionBank,
    );
    emit(state.copyWith(scoringResult: result, isCompleted: true));
  }

  void resetTest() {
    emit(AssessmentState.initial(totalQuestions: state.totalQuestions, gender: state.gender));
  }
}
