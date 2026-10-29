import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/question_item.dart';
import '../../domain/models/pearson_scoring_result.dart';
import '../../domain/usecases/pearson_scoring_engine.dart';
import '../../data/services/sample_question_bank.dart';

class SavedAssessmentRecord {
  final String clientName;
  final int age;
  final String gender;
  final DateTime date;
  final int totalQuestions;
  final PearsonScoringResult result;

  const SavedAssessmentRecord({
    required this.clientName,
    required this.age,
    required this.gender,
    required this.date,
    required this.totalQuestions,
    required this.result,
  });
}

class AssessmentState {
  final String clientName;
  final String nationalCode;
  final int clientAge;
  final String gender; // 'male' or 'female'
  final String education;
  final String maritalStatus;
  final int totalQuestions; // 567, 370, or 30
  final int currentIndex;
  final List<String> answers;
  final List<QuestionItem> questionBank;
  final Map<int, int> changeCounts;
  final Map<int, int> itemDurationsMs;
  final DateTime? startTime;
  final DateTime? lastQuestionShownAt;
  final bool isCompleted;
  final PearsonScoringResult? scoringResult;
  final List<SavedAssessmentRecord> history;

  const AssessmentState({
    required this.clientName,
    required this.nationalCode,
    required this.clientAge,
    required this.gender,
    required this.education,
    required this.maritalStatus,
    required this.totalQuestions,
    required this.currentIndex,
    required this.answers,
    required this.questionBank,
    required this.changeCounts,
    required this.itemDurationsMs,
    this.startTime,
    this.lastQuestionShownAt,
    this.isCompleted = false,
    this.scoringResult,
    this.history = const [],
  });

  factory AssessmentState.initial({
    int totalQuestions = 567,
    String gender = 'male',
    String clientName = 'مراجع کلینیک ناهیرا',
    String nationalCode = '',
    int clientAge = 32,
    String education = 'کارشناسی',
    String maritalStatus = 'متأهل',
    List<SavedAssessmentRecord> history = const [],
  }) {
    final bank = MMPIQuestionBank.getFullBank(totalQuestions);
    final now = DateTime.now();
    return AssessmentState(
      clientName: clientName,
      nationalCode: nationalCode,
      clientAge: clientAge,
      gender: gender,
      education: education,
      maritalStatus: maritalStatus,
      totalQuestions: totalQuestions,
      currentIndex: 0,
      answers: List.filled(totalQuestions, 'U'),
      questionBank: bank,
      changeCounts: const {},
      itemDurationsMs: const {},
      startTime: now,
      lastQuestionShownAt: now,
      isCompleted: false,
      history: history,
    );
  }

  AssessmentState copyWith({
    String? clientName,
    String? nationalCode,
    int? clientAge,
    String? gender,
    String? education,
    String? maritalStatus,
    int? totalQuestions,
    int? currentIndex,
    List<String>? answers,
    List<QuestionItem>? questionBank,
    Map<int, int>? changeCounts,
    Map<int, int>? itemDurationsMs,
    DateTime? startTime,
    DateTime? lastQuestionShownAt,
    bool? isCompleted,
    PearsonScoringResult? scoringResult,
    List<SavedAssessmentRecord>? history,
  }) {
    return AssessmentState(
      clientName: clientName ?? this.clientName,
      nationalCode: nationalCode ?? this.nationalCode,
      clientAge: clientAge ?? this.clientAge,
      gender: gender ?? this.gender,
      education: education ?? this.education,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      questionBank: questionBank ?? this.questionBank,
      changeCounts: changeCounts ?? this.changeCounts,
      itemDurationsMs: itemDurationsMs ?? this.itemDurationsMs,
      startTime: startTime ?? this.startTime,
      lastQuestionShownAt: lastQuestionShownAt ?? this.lastQuestionShownAt,
      isCompleted: isCompleted ?? this.isCompleted,
      scoringResult: scoringResult ?? this.scoringResult,
      history: history ?? this.history,
    );
  }

  int get answeredCount => answers.where((a) => a != 'U').length;
  int get trueCount => answers.where((a) => a == 'T').length;
  int get falseCount => answers.where((a) => a == 'F').length;
  int get unansweredCount => answers.where((a) => a == 'U').length;
  double get progress => totalQuestions > 0 ? (currentIndex + 1) / totalQuestions : 0.0;
  QuestionItem get currentQuestion => questionBank[currentIndex];
}

class AssessmentCubit extends Cubit<AssessmentState> {
  AssessmentCubit() : super(AssessmentState.initial());

  void updateClientInfo({
    String? clientName,
    String? nationalCode,
    int? clientAge,
    String? gender,
    String? education,
    String? maritalStatus,
  }) {
    emit(state.copyWith(
      clientName: clientName,
      nationalCode: nationalCode,
      clientAge: clientAge,
      gender: gender,
      education: education,
      maritalStatus: maritalStatus,
    ));
  }

  void setGender(String gender) {
    emit(state.copyWith(gender: gender));
  }

  void setTestLength(int count) {
    final bank = MMPIQuestionBank.getFullBank(count);
    final now = DateTime.now();
    emit(state.copyWith(
      totalQuestions: count,
      currentIndex: 0,
      answers: List.filled(count, 'U'),
      questionBank: bank,
      changeCounts: const {},
      itemDurationsMs: const {},
      startTime: now,
      lastQuestionShownAt: now,
      isCompleted: false,
    ));
  }

  void answerCurrent(String answer) {
    final idx = state.currentIndex;
    final now = DateTime.now();
    final List<String> updatedAnswers = List.from(state.answers);

    final int prevChanges = state.changeCounts[idx] ?? 0;
    final int newChanges = updatedAnswers[idx] != 'U' && updatedAnswers[idx] != answer
        ? prevChanges + 1
        : prevChanges;
    final updatedChangeCounts = Map<int, int>.from(state.changeCounts);
    updatedChangeCounts[idx] = newChanges;

    final int elapsedMs = state.lastQuestionShownAt != null
        ? now.difference(state.lastQuestionShownAt!).inMilliseconds.clamp(120, 60000)
        : 1200;
    final updatedTimings = Map<int, int>.from(state.itemDurationsMs);
    updatedTimings[idx] = (updatedTimings[idx] ?? 0) + elapsedMs;

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
      itemDurationsMs: updatedTimings,
      lastQuestionShownAt: now,
      isCompleted: completed,
    ));

    if (completed) {
      calculateScores();
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      emit(state.copyWith(
        currentIndex: state.currentIndex - 1,
        lastQuestionShownAt: DateTime.now(),
      ));
    }
  }

  void nextQuestion() {
    if (state.currentIndex < state.totalQuestions - 1) {
      emit(state.copyWith(
        currentIndex: state.currentIndex + 1,
        lastQuestionShownAt: DateTime.now(),
      ));
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < state.totalQuestions) {
      emit(state.copyWith(
        currentIndex: index,
        lastQuestionShownAt: DateTime.now(),
      ));
    }
  }

  void calculateScores() {
    final result = PearsonScoringEngine.evaluate(
      answers: state.answers,
      gender: state.gender,
      bank: state.questionBank,
    );

    final newRecord = SavedAssessmentRecord(
      clientName: state.clientName,
      age: state.clientAge,
      gender: state.gender,
      date: DateTime.now(),
      totalQuestions: state.totalQuestions,
      result: result,
    );

    final updatedHistory = [newRecord, ...state.history];

    emit(state.copyWith(
      scoringResult: result,
      isCompleted: true,
      history: updatedHistory,
    ));
  }

  void loadSimulatedProfile(String preset) {
    final int len = state.totalQuestions;
    final List<String> simAnswers = List.filled(len, 'F');
    final Map<int, int> simTimings = {};

    for (int i = 0; i < len; i++) {
      final q = state.questionBank[i];
      simTimings[i] = 1400 + ((i * 137) % 2800);

      if (preset == 'depression_anxiety') {
        if (q.trueScales.contains('D') || q.trueScales.contains('Pt')) {
          simAnswers[i] = 'T';
        } else if (q.falseScales.contains('D') || q.falseScales.contains('Pt')) {
          simAnswers[i] = 'F';
        } else {
          simAnswers[i] = (i % 4 == 0) ? 'T' : 'F';
        }
      } else if (preset == 'somatization') {
        if (q.trueScales.contains('Hs') || q.trueScales.contains('Hy')) {
          simAnswers[i] = 'T';
        } else if (q.falseScales.contains('Hs') || q.falseScales.contains('Hy')) {
          simAnswers[i] = 'F';
        } else {
          simAnswers[i] = (i % 5 == 0) ? 'T' : 'F';
        }
      } else if (preset == 'paranoid_schizo') {
        if (q.trueScales.contains('Pa') || q.trueScales.contains('Sc') || q.trueScales.contains('F')) {
          simAnswers[i] = 'T';
        } else {
          simAnswers[i] = (i % 3 == 0) ? 'T' : 'F';
        }
      } else {
        // Balanced / Normal profile
        if (q.trueScales.contains('K') || q.trueScales.contains('S')) {
          simAnswers[i] = (i % 2 == 0) ? 'T' : 'F';
        } else if (q.criticalCategory != null) {
          simAnswers[i] = 'F';
        } else {
          simAnswers[i] = (i % 3 == 0) ? 'T' : 'F';
        }
      }
    }

    final result = PearsonScoringEngine.evaluate(
      answers: simAnswers,
      gender: state.gender,
      bank: state.questionBank,
    );

    final newRecord = SavedAssessmentRecord(
      clientName: state.clientName,
      age: state.clientAge,
      gender: state.gender,
      date: DateTime.now(),
      totalQuestions: state.totalQuestions,
      result: result,
    );

    emit(state.copyWith(
      answers: simAnswers,
      itemDurationsMs: simTimings,
      currentIndex: len - 1,
      scoringResult: result,
      isCompleted: true,
      history: [newRecord, ...state.history],
    ));
  }

  void resetTest() {
    emit(AssessmentState.initial(
      totalQuestions: state.totalQuestions,
      gender: state.gender,
      clientName: state.clientName,
      nationalCode: state.nationalCode,
      clientAge: state.clientAge,
      education: state.education,
      maritalStatus: state.maritalStatus,
      history: state.history,
    ));
  }
}
