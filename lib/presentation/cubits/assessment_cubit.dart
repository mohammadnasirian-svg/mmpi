import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/question_item.dart';
import '../../domain/models/pearson_scoring_result.dart';
import '../../domain/usecases/pearson_scoring_engine.dart';
import '../../data/services/sample_question_bank.dart';

class SavedAssessmentRecord {
  final String id;
  final String clientName;
  final String nationalCode;
  final int age;
  final String gender;
  final String education;
  final String maritalStatus;
  final DateTime date;
  final int totalQuestions;
  final List<String> answers;
  final PearsonScoringResult result;

  const SavedAssessmentRecord({
    required this.id,
    required this.clientName,
    this.nationalCode = '',
    required this.age,
    required this.gender,
    this.education = '',
    this.maritalStatus = '',
    required this.date,
    required this.totalQuestions,
    required this.answers,
    required this.result,
  });
}

class AssessmentState {
  final bool hasActivePatient;
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
    required this.hasActivePatient,
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
    bool hasActivePatient = false,
    String clientName = '',
    String nationalCode = '',
    int clientAge = 0,
    String education = '',
    String maritalStatus = '',
    List<SavedAssessmentRecord> history = const [],
  }) {
    final bank = MMPIQuestionBank.getFullBank(totalQuestions);
    final now = DateTime.now();
    return AssessmentState(
      hasActivePatient: hasActivePatient,
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
    bool? hasActivePatient,
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
      hasActivePatient: hasActivePatient ?? this.hasActivePatient,
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

  void registerClientInfo({
    required String clientName,
    String nationalCode = '',
    required int clientAge,
    required String gender,
    String education = '',
    String maritalStatus = '',
  }) {
    emit(state.copyWith(
      hasActivePatient: true,
      clientName: clientName.trim(),
      nationalCode: nationalCode.trim(),
      clientAge: clientAge,
      gender: gender,
      education: education.trim(),
      maritalStatus: maritalStatus.trim(),
    ));
  }

  void clearActivePatient() {
    emit(AssessmentState.initial(
      totalQuestions: state.totalQuestions,
      history: state.history,
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

    final String displayName = state.clientName.trim().isEmpty
        ? 'پرونده شماره ${state.history.length + 1}'
        : state.clientName.trim();
    final int displayAge = state.clientAge > 0 ? state.clientAge : 30;

    final newRecord = SavedAssessmentRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: displayName,
      nationalCode: state.nationalCode,
      age: displayAge,
      gender: state.gender,
      education: state.education,
      maritalStatus: state.maritalStatus,
      date: DateTime.now(),
      totalQuestions: state.totalQuestions,
      answers: List<String>.from(state.answers),
      result: result,
    );

    final updatedHistory = [
      newRecord,
      ...state.history.where((r) =>
          !(r.clientName == displayName &&
              DateTime.now().difference(r.date).inSeconds < 15)),
    ];

    emit(state.copyWith(
      scoringResult: result,
      isCompleted: true,
      history: updatedHistory,
    ));
  }

  void loadSavedRecord(SavedAssessmentRecord record) {
    final bank = MMPIQuestionBank.getFullBank(record.totalQuestions);
    emit(state.copyWith(
      hasActivePatient: true,
      clientName: record.clientName,
      nationalCode: record.nationalCode,
      clientAge: record.age,
      gender: record.gender,
      education: record.education,
      maritalStatus: record.maritalStatus,
      totalQuestions: record.totalQuestions,
      answers: List<String>.from(record.answers),
      questionBank: bank,
      currentIndex: record.totalQuestions - 1,
      scoringResult: record.result,
      isCompleted: true,
    ));
  }

  void deleteSavedRecord(String id) {
    emit(state.copyWith(
      history: state.history.where((r) => r.id != id).toList(),
    ));
  }

  void loadSimulatedProfile(String preset, {bool isEn = false}) {
    final int len = state.totalQuestions;
    final List<String> simAnswers = List.filled(len, 'F');
    final Map<int, int> simTimings = {};

    String simName = state.clientName.trim();
    if (simName.isEmpty) {
      if (preset == 'depression_anxiety') {
        simName = isEn ? 'Sample Case: 2-7 Profile' : 'پرونده نمونه (نیمرخ ۲-۷)';
      } else if (preset == 'somatization') {
        simName = isEn ? 'Sample Case: 1-3 Profile' : 'پرونده نمونه (نیمرخ ۱-۳)';
      } else if (preset == 'paranoid_schizo') {
        simName = isEn ? 'Sample Case: 6-8 Profile' : 'پرونده نمونه (نیمرخ ۶-۸)';
      } else {
        simName = isEn ? 'Sample Case: Normative' : 'پرونده نمونه (بهنجار)';
      }
    }

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

    final int simAge = state.clientAge > 0 ? state.clientAge : 34;

    final newRecord = SavedAssessmentRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: simName,
      nationalCode: state.nationalCode,
      age: simAge,
      gender: state.gender,
      education: state.education,
      maritalStatus: state.maritalStatus,
      date: DateTime.now(),
      totalQuestions: state.totalQuestions,
      answers: simAnswers,
      result: result,
    );

    emit(state.copyWith(
      hasActivePatient: true,
      clientName: simName,
      clientAge: simAge,
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
      hasActivePatient: state.hasActivePatient,
      clientName: state.clientName,
      nationalCode: state.nationalCode,
      clientAge: state.clientAge,
      education: state.education,
      maritalStatus: state.maritalStatus,
      history: state.history,
    ));
  }
}
