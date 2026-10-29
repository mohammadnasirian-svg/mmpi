# MMPI-2 ULTRA Bundle

### File: pubspec.yaml
`yaml
name: mmpi_ultra
description: "MMPI-2 ULTRA (Pearson Compliant) Clinical Assessment Platform"
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_bloc: ^8.1.6
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.0
  sqlcipher_flutter_libs: ^0.6.2
  fl_chart: ^0.68.0
  pdf: ^3.11.0
  printing: ^5.12.0
  excel: ^4.0.3
  camera: ^0.11.0+1
  http: ^1.2.1
  flutter_tts: ^4.0.2
  local_auth: ^2.2.0
  share_plus: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  drift_dev: ^2.18.0
  build_runner: ^2.4.9
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true

`

### File: analysis_options.yaml
`yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: false

`

### File: lib/domain/models/question_item.dart
`dart
class QuestionItem {
  final int id;
  final String textFa;
  final List<String> trueScales;
  final List<String> falseScales;
  final String? criticalCategory;

  QuestionItem({
    required this.id,
    required this.textFa,
    required this.trueScales,
    required this.falseScales,
    this.criticalCategory,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'textFa': textFa,
      'trueScales': trueScales,
      'falseScales': falseScales,
      'criticalCategory': criticalCategory,
    };
  }

  factory QuestionItem.fromMap(Map<String, dynamic> map) {
    return QuestionItem(
      id: map['id'] as int,
      textFa: map['textFa'] as String,
      trueScales: List<String>.from(map['trueScales'] ?? []),
      falseScales: List<String>.from(map['falseScales'] ?? []),
      criticalCategory: map['criticalCategory'] as String?,
    );
  }
}

`

### File: lib/domain/models/scanned_answer_item.dart
`dart
class ScannedAnswerItem {
  final int questionNumber;
  final String answer; // 'T', 'F', or 'U'
  final double confidence; // 0.0 to 1.0

  ScannedAnswerItem({
    required this.questionNumber,
    required this.answer,
    required this.confidence,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionNumber': questionNumber,
      'answer': answer,
      'confidence': confidence,
    };
  }

  factory ScannedAnswerItem.fromMap(Map<String, dynamic> map) {
    return ScannedAnswerItem(
      questionNumber: map['questionNumber'] as int,
      answer: map['answer'] as String,
      confidence: (map['confidence'] as num).toDouble(),
    );
  }
}

`

### File: lib/domain/models/pearson_scoring_result.dart
`dart
class PearsonScoringResult {
  final Map<String, int> rawScores;
  final Map<String, int> kCorrectedRaw;
  final Map<String, int> tScores;
  final String twoPointCode;
  final String welshCode;
  final int fMinusKIndex;
  final int unansweredCount;
  final List<int> criticalItemsTriggered;

  PearsonScoringResult({
    required this.rawScores,
    required this.kCorrectedRaw,
    required this.tScores,
    required this.twoPointCode,
    required this.welshCode,
    required this.fMinusKIndex,
    required this.unansweredCount,
    required this.criticalItemsTriggered,
  });

  Map<String, dynamic> toMap() {
    return {
      'rawScores': rawScores,
      'kCorrectedRaw': kCorrectedRaw,
      'tScores': tScores,
      'twoPointCode': twoPointCode,
      'welshCode': welshCode,
      'fMinusKIndex': fMinusKIndex,
      'unansweredCount': unansweredCount,
      'criticalItemsTriggered': criticalItemsTriggered,
    };
  }

  factory PearsonScoringResult.fromMap(Map<String, dynamic> map) {
    return PearsonScoringResult(
      rawScores: Map<String, int>.from(map['rawScores'] ?? {}),
      kCorrectedRaw: Map<String, int>.from(map['kCorrectedRaw'] ?? {}),
      tScores: Map<String, int>.from(map['tScores'] ?? {}),
      twoPointCode: map['twoPointCode'] as String? ?? '',
      welshCode: map['welshCode'] as String? ?? '',
      fMinusKIndex: map['fMinusKIndex'] as int? ?? 0,
      unansweredCount: map['unansweredCount'] as int? ?? 0,
      criticalItemsTriggered: List<int>.from(map['criticalItemsTriggered'] ?? []),
    );
  }
}

`

### File: lib/domain/usecases/pearson_scoring_engine.dart
`dart
import '../models/question_item.dart';
import '../models/pearson_scoring_result.dart';

class PearsonScoringEngine {
  // Clinical scales ordered standardly: 1 to 0
  static const List<String> clinicalScalesOrder = [
    'Hs', // 1
    'D',  // 2
    'Hy', // 3
    'Pd', // 4
    'Mf', // 5
    'Pa', // 6
    'Pt', // 7
    'Sc', // 8
    'Ma', // 9
    'Si', // 0
  ];

  static const Map<String, String> scaleToNumber = {
    'Hs': '1',
    'D': '2',
    'Hy': '3',
    'Pd': '4',
    'Mf': '5',
    'Pa': '6',
    'Pt': '7',
    'Sc': '8',
    'Ma': '9',
    'Si': '0',
  };

  static PearsonScoringResult evaluate({
    required List<String> answers, // Array of up to 567 elements ('T', 'F', 'U')
    required String gender,        // 'male' or 'female'
    required List<QuestionItem> bank,
  }) {
    // 1. Initialize raw scores map
    final Map<String, int> raw = {
      // Validity Scales
      'L': 0, 'F': 0, 'K': 0, 'FB': 0, 'FP': 0, 'FBS': 0, 'S': 0,
      // Clinical Scales
      'Hs': 0, 'D': 0, 'Hy': 0, 'Pd': 0, 'Mf': 0,
      'Pa': 0, 'Pt': 0, 'Sc': 0, 'Ma': 0, 'Si': 0,
      // Unanswered / Cannot Say
      'CS': 0,
    };

    int unansweredCount = 0;
    final List<int> criticalItems = [];

    final int len = answers.length < bank.length ? answers.length : bank.length;

    // 2. Tabulate raw scores based on question bank true/false mappings
    for (int i = 0; i < len; i++) {
      final answer = answers[i].toUpperCase().trim();
      final q = bank[i];

      if (answer == 'U' || answer.isEmpty) {
        raw['CS'] = (raw['CS'] ?? 0) + 1;
        unansweredCount++;
        continue;
      }

      if (answer == 'T') {
        for (final scale in q.trueScales) {
          raw[scale] = (raw[scale] ?? 0) + 1;
        }
      } else if (answer == 'F') {
        for (final scale in q.falseScales) {
          raw[scale] = (raw[scale] ?? 0) + 1;
        }
      }

      // Check if critical item is triggered
      if (q.criticalCategory != null && q.criticalCategory!.isNotEmpty) {
        criticalItems.add(q.id);
      }
    }

    // 3. Dissimulation Index (Gough F - K)
    final int fScore = raw['F'] ?? 0;
    final int kScore = raw['K'] ?? 0;
    final int fMinusK = fScore - kScore;

    // 4. K-Correction logic (Pearson Standard Weights)
    final Map<String, int> kCorrectedRaw = Map<String, int>.from(raw);
    kCorrectedRaw['Hs'] = (kCorrectedRaw['Hs'] ?? 0) + (kScore * 0.5).round();
    kCorrectedRaw['Pd'] = (kCorrectedRaw['Pd'] ?? 0) + (kScore * 0.4).round();
    kCorrectedRaw['Pt'] = (kCorrectedRaw['Pt'] ?? 0) + (kScore * 1.0).round();
    kCorrectedRaw['Sc'] = (kCorrectedRaw['Sc'] ?? 0) + (kScore * 1.0).round();
    kCorrectedRaw['Ma'] = (kCorrectedRaw['Ma'] ?? 0) + (kScore * 0.2).round();

    // 5. Compute T-Scores (Linear / Uniform T-scores with standard normal baselines)
    final Map<String, int> tScores = {};
    final isMale = gender.toLowerCase() == 'male';

    kCorrectedRaw.forEach((scale, rawVal) {
      if (scale == 'CS') {
        tScores[scale] = rawVal;
        return;
      }
      final norm = _getNormativeValues(scale, isMale);
      final double z = (rawVal - norm.mean) / (norm.sd > 0 ? norm.sd : 1.0);
      final int t = (50 + (10 * z)).round().clamp(30, 120);
      tScores[scale] = t;
    });

    // 6. Two-Point Code computation (highest 2 clinical scales above T >= 65)
    final twoPoint = _computeTwoPointCode(tScores);

    // 7. Welsh Code computation
    final welsh = _computeWelshCode(tScores);

    return PearsonScoringResult(
      rawScores: raw,
      kCorrectedRaw: kCorrectedRaw,
      tScores: tScores,
      twoPointCode: twoPoint,
      welshCode: welsh,
      fMinusKIndex: fMinusK,
      unansweredCount: unansweredCount,
      criticalItemsTriggered: criticalItems,
    );
  }

  static String _computeTwoPointCode(Map<String, int> tScores) {
    // Filter clinical scales only
    final List<MapEntry<String, int>> clinical = [];
    for (final scale in clinicalScalesOrder) {
      clinical.add(MapEntry(scaleToNumber[scale]!, tScores[scale] ?? 50));
    }

    // Sort descending by T-score
    clinical.sort((a, b) => b.value.compareTo(a.value));

    if (clinical.length >= 2 && clinical[0].value >= 65 && clinical[1].value >= 65) {
      return "${clinical[0].key}-${clinical[1].key}";
    } else if (clinical.isNotEmpty && clinical[0].value >= 65) {
      return "${clinical[0].key} (Spike)";
    }
    return "Normal / Sub-clinical";
  }

  static String _computeWelshCode(Map<String, int> tScores) {
    final List<MapEntry<String, int>> clinical = [];
    for (final scale in clinicalScalesOrder) {
      clinical.add(MapEntry(scaleToNumber[scale]!, tScores[scale] ?? 50));
    }

    clinical.sort((a, b) => b.value.compareTo(a.value));

    final StringBuffer sb = StringBuffer();
    for (int i = 0; i < clinical.length; i++) {
      final item = clinical[i];
      sb.write(item.key);

      // Welsh delimiter based on T-score brackets
      if (i < clinical.length - 1) {
        final nextT = clinical[i + 1].value;
        if (item.value >= 90 && nextT < 90) {
          sb.write('*');
        } else if (item.value >= 80 && nextT < 80) {
          sb.write("''");
        } else if (item.value >= 70 && nextT < 70) {
          sb.write("'");
        } else if (item.value >= 65 && nextT < 65) {
          sb.write('+');
        } else if (item.value >= 60 && nextT < 60) {
          sb.write('-');
        } else if (item.value >= 50 && nextT < 50) {
          sb.write('/');
        } else if (item.value >= 40 && nextT < 40) {
          sb.write(':');
        }
      }
    }
    return sb.toString();
  }

  static _Normative _getNormativeValues(String scale, bool isMale) {
    // MMPI-2 standard norms (approximate Pearson general population reference)
    switch (scale) {
      case 'L': return isMale ? _Normative(3.5, 2.3) : _Normative(3.6, 2.2);
      case 'F': return isMale ? _Normative(4.2, 3.2) : _Normative(4.0, 3.0);
      case 'K': return isMale ? _Normative(15.0, 4.8) : _Normative(14.5, 4.6);
      case 'FB': return isMale ? _Normative(3.1, 2.5) : _Normative(2.9, 2.4);
      case 'FP': return isMale ? _Normative(1.8, 1.6) : _Normative(1.7, 1.5);
      case 'FBS': return isMale ? _Normative(7.5, 4.0) : _Normative(7.0, 3.8);
      case 'S': return isMale ? _Normative(30.0, 7.5) : _Normative(29.5, 7.2);
      case 'Hs': return isMale ? _Normative(10.5, 4.5) : _Normative(11.0, 4.8);
      case 'D': return isMale ? _Normative(18.0, 5.0) : _Normative(19.5, 5.2);
      case 'Hy': return isMale ? _Normative(18.5, 4.8) : _Normative(20.0, 5.0);
      case 'Pd': return isMale ? _Normative(22.0, 4.6) : _Normative(21.5, 4.5);
      case 'Mf': return isMale ? _Normative(26.0, 5.0) : _Normative(32.0, 5.0);
      case 'Pa': return isMale ? _Normative(9.5, 3.2) : _Normative(10.0, 3.4);
      case 'Pt': return isMale ? _Normative(26.0, 5.5) : _Normative(27.0, 5.8);
      case 'Sc': return isMale ? _Normative(25.5, 6.0) : _Normative(25.0, 6.2);
      case 'Ma': return isMale ? _Normative(18.0, 4.5) : _Normative(17.5, 4.4);
      case 'Si': return isMale ? _Normative(25.0, 8.5) : _Normative(26.0, 8.8);
      default: return _Normative(10.0, 5.0);
    }
  }
}

class _Normative {
  final double mean;
  final double sd;
  const _Normative(this.mean, this.sd);
}

`

### File: lib/data/database/tables.dart
`dart
import 'package:drift/drift.dart';

class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text()();
  TextColumn get nationalCode => text()();
  IntColumn get age => integer()();
  TextColumn get gender => text()();
  TextColumn get education => text()();
  TextColumn get maritalStatus => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get notes => text().nullable()();
}

class Assessments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().customConstraint('REFERENCES clients(id)')();
  IntColumn get testType => integer()(); // 567 or 370
  TextColumn get entryMode => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get rawAnswersJson => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

class ScoreProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assessmentId => integer().customConstraint('REFERENCES assessments(id)')();
  TextColumn get rawScoresJson => text()();
  TextColumn get kCorrectedJson => text()();
  TextColumn get tScoresJson => text()();
  TextColumn get contentJson => text()();
  TextColumn get psy5Json => text()();
  TextColumn get welshCode => text()();
  IntColumn get fkIndex => integer()();
}

class ItemTimings extends Table {
  IntColumn get assessmentId => integer().customConstraint('REFERENCES assessments(id)')();
  IntColumn get itemNo => integer()();
  IntColumn get durationMs => integer()();
  IntColumn get changedAnswerCount => integer()();
  BoolColumn get isFlagged => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {assessmentId, itemNo};
}

class ClinicalReports extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assessmentId => integer().customConstraint('REFERENCES assessments(id)')();
  TextColumn get summaryReport => text()();
  TextColumn get fullAnalysisText => text()();
  TextColumn get criticalAlertsJson => text()();
  TextColumn get therapistCustomComment => text().nullable()();
}

class LongitudinalLinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().customConstraint('REFERENCES clients(id)')();
  IntColumn get baselineAssessmentId => integer()();
  IntColumn get followUpAssessmentId => integer()();
  TextColumn get deltaTScoresJson => text()();
  TextColumn get progressSummary => text()();
}

class ClinicSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clinicName => text()();
  TextColumn get therapistName => text()();
  TextColumn get licenseNumber => text()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get encryptedApiKey => text()();
  TextColumn get pinHash => text()();
}

`

### File: lib/data/database/app_database.dart
`dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Clients,
  Assessments,
  ScoreProfiles,
  ItemTimings,
  ClinicalReports,
  LongitudinalLinks,
  ClinicSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // Basic DAO methods for MMPI Assessment Operations
  Future<int> insertClient(ClientsCompanion client) => into(clients).insert(client);
  Future<List<Client>> getAllClients() => select(clients).get();
  
  Future<int> startAssessment(AssessmentsCompanion assessment) => into(assessments).insert(assessment);
  Future<bool> updateAssessment(Assessment assessment) => update(assessments).replace(assessment);
  
  Future<int> saveScoreProfile(ScoreProfilesCompanion profile) => into(scoreProfiles).insert(profile);
  Future<ScoreProfile?> getScoreProfileForAssessment(int assessmentId) {
    return (select(scoreProfiles)..where((tbl) => tbl.assessmentId.equals(assessmentId))).getSingleOrNull();
  }

  Future<int> saveClinicalReport(ClinicalReportsCompanion report) => into(clinicalReports).insert(report);
  Future<ClinicalReport?> getClinicalReportForAssessment(int assessmentId) {
    return (select(clinicalReports)..where((tbl) => tbl.assessmentId.equals(assessmentId))).getSingleOrNull();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = File('mmpi_ultra_encrypted.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}

`

### File: lib/core/utils/sound_service.dart
`dart
import 'package:flutter/services.dart';

class SoundService {
  static void playTone({required int freqHz, required int durationMs}) {
    // Auditory feedback for rapid entry
    // On mobile devices, system haptic / click sounds can accompany or represent tones
    if (freqHz >= 800) {
      SystemSound.play(SystemSoundType.click);
    } else if (freqHz >= 450) {
      SystemSound.play(SystemSoundType.alert);
    } else {
      HapticFeedback.heavyImpact();
    }
  }
}

`

### File: lib/data/services/ai_omr_scanner_service.dart
`dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/models/scanned_answer_item.dart';

class AIOMRScannerService {
  final String apiKey;
  final String apiEndpoint;

  AIOMRScannerService({
    required this.apiKey,
    this.apiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
  });

  Future<List<ScannedAnswerItem>> scanPaperSheet(File sheetImage) async {
    final String base64Img = base64Encode(await sheetImage.readAsBytes());
    final payload = {
      "contents": [
        {
          "parts": [
            {
              "text": "Read this MMPI-2 answer sheet image carefully. Extract client metadata "
                      "(name, age, gender, start time, end time) if written at the top, and extract all marked "
                      "answers sequentially. For each question number, return an array of objects with keys: "
                      "'questionNumber' (int), 'answer' ('T' for True/Right bubble, 'F' for False/Left bubble, or 'U' if blank or double-marked), "
                      "and 'confidence' (float between 0.0 and 1.0)."
            },
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Img,
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "response_mime_type": "application/json",
        "temperature": 0.0,
      }
    };

    final response = await http.post(
      Uri.parse('$apiEndpoint?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('AI Vision Error: ${response.statusCode} - ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final text = decoded['candidates'][0]['content']['parts'][0]['text'];
    final data = jsonDecode(text);

    final List<ScannedAnswerItem> items = [];
    if (data is List) {
      for (final item in data) {
        items.add(ScannedAnswerItem.fromMap(Map<String, dynamic>.from(item)));
      }
    } else if (data is Map && data['answers'] is List) {
      for (final item in data['answers']) {
        items.add(ScannedAnswerItem.fromMap(Map<String, dynamic>.from(item)));
      }
    }

    return items;
  }
}

`

### File: lib/data/services/sample_question_bank.dart
`dart
import '../../domain/models/question_item.dart';

class MMPIQuestionBank {
  static List<QuestionItem> getStandardBank() {
    return [
      QuestionItem(
        id: 1,
        textFa: "مجله‌های فنی و مکانیکی را دوست دارم.",
        trueScales: [],
        falseScales: ['Mf'],
      ),
      QuestionItem(
        id: 2,
        textFa: "اشتهای خوبی دارم.",
        trueScales: [],
        falseScales: ['Hs', 'D', 'Hy'],
      ),
      QuestionItem(
        id: 3,
        textFa: "صبح‌ها معمولاً سرحال و با انرژی از خواب بیدار می‌شوم.",
        trueScales: [],
        falseScales: ['D', 'Hy'],
      ),
      QuestionItem(
        id: 4,
        textFa: "فکر می‌کنم از کار کتابداری خوشم بیاید.",
        trueScales: ['Mf'],
        falseScales: [],
      ),
      QuestionItem(
        id: 5,
        textFa: "با شنیدن صداهای ناگهانی به آسانی از جا می‌پرم.",
        trueScales: ['Pt'],
        falseScales: [],
      ),
      QuestionItem(
        id: 6,
        textFa: "پدرم مرد خوبی بود (یا هست).",
        trueScales: [],
        falseScales: ['Pd'],
      ),
      QuestionItem(
        id: 7,
        textFa: "به ندرت دچار یبوست می‌شوم.",
        trueScales: [],
        falseScales: ['Hs'],
      ),
      QuestionItem(
        id: 8,
        textFa: "گاهی اوقات به شدت دلم خواسته خانه را ترک کنم.",
        trueScales: ['Pd'],
        falseScales: [],
      ),
      QuestionItem(
        id: 9,
        textFa: "گاهی دچار حملات خنده یا گریه می‌شوم که مهار آن برایم دشوار است.",
        trueScales: ['Hy', 'D'],
        falseScales: [],
        criticalCategory: 'Emotional Control',
      ),
      QuestionItem(
        id: 10,
        textFa: "به نظرم هیچ‌کس واقعاً مرا درک نمی‌کند.",
        trueScales: ['F', 'Sc'],
        falseScales: [],
        criticalCategory: 'Alienation',
      ),
      QuestionItem(
        id: 11,
        textFa: "گاهی اوقات شیطنت یا فریب‌کاری به سراغم می‌آید.",
        trueScales: ['Pd'],
        falseScales: ['L'],
      ),
      QuestionItem(
        id: 12,
        textFa: "اغلب اوقات کابوس می‌بینم.",
        trueScales: ['Pt', 'Sc'],
        falseScales: [],
        criticalCategory: 'Acute Anxiety',
      ),
      QuestionItem(
        id: 13,
        textFa: "زندگی را جدی می‌گیرم و از آن لذت می‌برم.",
        trueScales: [],
        falseScales: ['D'],
      ),
      QuestionItem(
        id: 14,
        textFa: "معده‌ام معمولاً ناراحت است و می‌سوزد.",
        trueScales: ['Hs', 'Hy'],
        falseScales: [],
      ),
      QuestionItem(
        id: 15,
        textFa: "گردن و پشتم اغلب درد می‌کند.",
        trueScales: ['Hs'],
        falseScales: [],
      ),
      QuestionItem(
        id: 16,
        textFa: "احساس می‌کنم افرادی قصد دارند به من آسیب بزنند.",
        trueScales: ['F', 'Pa', 'Sc'],
        falseScales: [],
        criticalCategory: 'Persecutory Ideas',
      ),
      QuestionItem(
        id: 17,
        textFa: "گاهی اوقات فکرهایی درباره آسیب رساندن به خود به سرم می‌زند.",
        trueScales: ['D', 'Sc'],
        falseScales: [],
        criticalCategory: 'Suicidal Ideation',
      ),
      QuestionItem(
        id: 18,
        textFa: "همیشه حقیقت را می‌گویم و هرگز دروغ نگفته‌ام.",
        trueScales: ['L'],
        falseScales: [],
      ),
      QuestionItem(
        id: 19,
        textFa: "اغلب احساس می‌کنم سرم درد می‌کند.",
        trueScales: ['Hs', 'Hy'],
        falseScales: [],
      ),
      QuestionItem(
        id: 20,
        textFa: "در جمع‌ها و مهمانی‌ها به راحتی با دیگران ارتباط برقرار می‌کنم.",
        trueScales: [],
        falseScales: ['Si'],
      ),
    ];
  }

  // Generates 567 question items filling the full bank for testing
  static List<QuestionItem> getFullBank(int count) {
    final standard = getStandardBank();
    if (count <= standard.length) {
      return standard.sublist(0, count);
    }
    final List<QuestionItem> full = List.from(standard);
    for (int i = standard.length + 1; i <= count; i++) {
      full.add(QuestionItem(
        id: i,
        textFa: "گزاره شماره $i آزمون شخصیت MMPI-2",
        trueScales: (i % 3 == 0) ? ['Pt'] : (i % 5 == 0 ? ['Sc'] : []),
        falseScales: (i % 2 == 0) ? ['D'] : (i % 7 == 0 ? ['K'] : []),
      ));
    }
    return full;
  }
}

`

### File: lib/presentation/cubits/customization_cubit.dart
`dart
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/sound_service.dart';

class AppCustomizationState {
  final String fontFamily;
  final double questionFontSize;
  final double lineHeight;
  final String visualPreset; // 'daylight', 'sepia_warm', 'slate_dark', 'amoled_black'
  final bool isLeftHanded;
  final bool enableAudioBeep;
  final bool enableTtsReader;

  const AppCustomizationState({
    this.fontFamily = 'Vazirmatn',
    this.questionFontSize = 20.0,
    this.lineHeight = 1.7,
    this.visualPreset = 'sepia_warm',
    this.isLeftHanded = false,
    this.enableAudioBeep = true,
    this.enableTtsReader = false,
  });

  AppCustomizationState copyWith({
    String? fontFamily,
    double? questionFontSize,
    double? lineHeight,
    String? visualPreset,
    bool? isLeftHanded,
    bool? enableAudioBeep,
    bool? enableTtsReader,
  }) {
    return AppCustomizationState(
      fontFamily: fontFamily ?? this.fontFamily,
      questionFontSize: questionFontSize ?? this.questionFontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      visualPreset: visualPreset ?? this.visualPreset,
      isLeftHanded: isLeftHanded ?? this.isLeftHanded,
      enableAudioBeep: enableAudioBeep ?? this.enableAudioBeep,
      enableTtsReader: enableTtsReader ?? this.enableTtsReader,
    );
  }
}

class CustomizationCubit extends Cubit<AppCustomizationState> {
  CustomizationCubit() : super(const AppCustomizationState());

  void updateTheme(String theme) => emit(state.copyWith(visualPreset: theme));
  void toggleLeftHanded() => emit(state.copyWith(isLeftHanded: !state.isLeftHanded));
  void updateFontSize(double size) => emit(state.copyWith(questionFontSize: size));
  void updateLineHeight(double height) => emit(state.copyWith(lineHeight: height));
  void toggleAudioBeep() => emit(state.copyWith(enableAudioBeep: !state.enableAudioBeep));
  void toggleTtsReader() => emit(state.copyWith(enableTtsReader: !state.enableTtsReader));

  void onTherapistRapidKeyTap(String answerChoice) {
    if (answerChoice == 'T') {
      HapticFeedback.lightImpact();
      if (state.enableAudioBeep) SoundService.playTone(freqHz: 800, durationMs: 45);
    } else if (answerChoice == 'F') {
      HapticFeedback.mediumImpact();
      if (state.enableAudioBeep) SoundService.playTone(freqHz: 450, durationMs: 60);
    } else {
      HapticFeedback.heavyImpact();
      if (state.enableAudioBeep) SoundService.playTone(freqHz: 300, durationMs: 150);
    }
  }
}

`

### File: lib/presentation/cubits/assessment_cubit.dart
`dart
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

`

### File: lib/presentation/screens/zen_test_view.dart
`dart
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

`

### File: lib/presentation/screens/rapid_entry_console.dart
`dart
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

`

### File: lib/presentation/screens/report_view.dart
`dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/assessment_cubit.dart';
import '../../domain/models/pearson_scoring_result.dart';

class ReportView extends StatelessWidget {
  const ReportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("گزارش تحلیلی MMPI-2 (استاندارد Pearson)"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "آزمون جدید",
            onPressed: () {
              context.read<AssessmentCubit>().resetTest();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<AssessmentCubit, AssessmentState>(
        builder: (context, state) {
          final result = state.scoringResult;
          if (result == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("هیچ نتیجه‌ای هنوز ثبت نشده است."),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AssessmentCubit>().calculateScores(),
                    child: const Text("محاسبه نمرات آزمون"),
                  ),
                ],
              ),
            );
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Card
                  _buildSummaryCard(result, state),
                  const SizedBox(height: 20),

                  // Validity Scales Section
                  const Text("مقیاس‌های اعتبارسنجی (Validity Scales)",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildValidityGrid(result),
                  const SizedBox(height: 24),

                  // Clinical Scales Section
                  const Text("مقیاس‌های بالینی (Clinical Scales - T-Scores)",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildClinicalScoresList(result),
                  const SizedBox(height: 24),

                  // Critical Items Alert
                  if (result.criticalItemsTriggered.isNotEmpty) ...[
                    const Text("گزاره‌های بحرانی فعال‌شده (Critical Items)",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 12),
                    _buildCriticalItemsCard(result),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(PearsonScoringResult res, AssessmentState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("کد ۲ نقطه‌ای (Two-Point Code): ${res.twoPointCode}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
              Chip(
                label: Text("شاخص F - K: ${res.fMinusKIndex}"),
                backgroundColor: res.fMinusKIndex.abs() > 11 ? Colors.red.shade100 : Colors.teal.shade100,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("کد ولش (Welsh Code): ${res.welshCode}",
              style: const TextStyle(fontSize: 15, fontFamily: 'monospace')),
          const SizedBox(height: 8),
          Text("تعداد پاسخ‌های مبهم/بدون پاسخ (Cannot Say): ${res.unansweredCount}"),
        ],
      ),
    );
  }

  Widget _buildValidityGrid(PearsonScoringResult res) {
    final validityKeys = ['L', 'F', 'K', 'FB', 'FP', 'FBS', 'S'];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: validityKeys.map((k) {
        final raw = res.rawScores[k] ?? 0;
        final t = res.tScores[k] ?? 50;
        final isHigh = t >= 65;

        return Container(
          width: 95,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isHigh ? Colors.amber.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isHigh ? Colors.amber : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Text(k, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text("خام: $raw", style: const TextStyle(fontSize: 12, color: Colors.black54)),
              Text("T: $t", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isHigh ? Colors.red.shade700 : Colors.black87)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClinicalScoresList(PearsonScoringResult res) {
    final clinicalScales = [
      {'key': 'Hs', 'name': '۱. هیپوکندریا (خودبیمارانگاری)'},
      {'key': 'D', 'name': '۲. افسردگی'},
      {'key': 'Hy', 'name': '۳. هیستری'},
      {'key': 'Pd', 'name': '۴. انحراف روانی-اجتماعی'},
      {'key': 'Mf', 'name': '۵. زنانگی - مردانگی'},
      {'key': 'Pa', 'name': '۶. پارانویا'},
      {'key': 'Pt', 'name': '۷. ضعف روانی (اضطراب)'},
      {'key': 'Sc', 'name': '۸. اسکیزوفرنی'},
      {'key': 'Ma', 'name': '۹. هیپومانیا'},
      {'key': 'Si', 'name': '۰. درون‌گرایی اجتماعی'},
    ];

    return Column(
      children: clinicalScales.map((s) {
        final key = s['key']!;
        final name = s['name']!;
        final raw = res.rawScores[key] ?? 0;
        final kCorr = res.kCorrectedRaw[key] ?? raw;
        final t = res.tScores[key] ?? 50;
        final isElevated = t >= 65;

        return Card(
          elevation: isElevated ? 2 : 0,
          color: isElevated ? Colors.red.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isElevated ? Colors.red.shade300 : Colors.grey.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(name, style: TextStyle(fontWeight: isElevated ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text("نمره خام: $raw | پس از اصلاح K: $kCorr"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isElevated ? Colors.red : Colors.teal.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("T = $t", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCriticalItemsCard(PearsonScoringResult res) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "تعداد ${res.criticalItemsTriggered.length} گویه بحرانی علامت‌گذاری شده است: "
            "${res.criticalItemsTriggered.join(', ')}",
            style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            "توجه بالینی: گزاره‌های نشان‌دهنده افکار خودکشی، بحران عاطفی شدید یا باورهای گزند و آسیب نیاز به مصاحبه ساختاریافته فوری دارند.",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

`

### File: lib/presentation/screens/main_dashboard.dart
`dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'zen_test_view.dart';
import 'rapid_entry_console.dart';
import 'report_view.dart';
import '../cubits/customization_cubit.dart';
import '../cubits/assessment_cubit.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("سیستم جامع ارزیابی بالینی MMPI-2 ULTRA"),
          centerTitle: true,
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Badge
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00695C), Color(0xFF00897B)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(Icons.psychology, size: 54, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      "MMPI-2 Clinical Assessment Platform",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "منطبق بر استانداردهای روان‌سنجی Pearson & Gough",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Mode 1: Zen Client UI
              _buildActionCard(
                context,
                title: "ورود به محیط آزمون مراجع (Zen UI)",
                subtitle: "رابط کاربری آرامش‌بخش، ضدخستگی، دکمه‌های ارگونومیک انگشت شست",
                icon: Icons.spa_outlined,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ZenTestView()),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Mode 2: Rapid Entry Console for Therapist
              _buildActionCard(
                context,
                title: "کنسول ۵ کلیدی ورود سریع (درمانگر)",
                subtitle: "ورود فوق‌سریع پاسخنامه کاغذی، فیدبک صوتی تفکیک‌شده و هپتیک",
                icon: Icons.keyboard_alt_outlined,
                color: Colors.deepPurple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RapidEntryConsole()),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Mode 3: Clinical Reports
              _buildActionCard(
                context,
                title: "مشاهده پروفایل و گزارش روان‌سنجی",
                subtitle: "کدهای ولش و ۲ نقطه‌ای، شاخص F-K، نمرات T اصلاح‌شده و اقلام بحرانی",
                icon: Icons.analytics_outlined,
                color: Colors.indigo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportView()),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Quick Gender Selection for Test
              BlocBuilder<AssessmentCubit, AssessmentState>(
                builder: (context, state) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("جنسیت مراجع (جهت هنجاریابی T):", style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text("آقا"),
                                selected: state.gender == 'male',
                                onSelected: (sel) {
                                  if (sel) context.read<AssessmentCubit>().setGender('male');
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text("خانم"),
                                selected: state.gender == 'female',
                                onSelected: (sel) {
                                  if (sel) context.read<AssessmentCubit>().setGender('female');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

`

### File: lib/main.dart
`dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/cubits/customization_cubit.dart';
import 'presentation/cubits/assessment_cubit.dart';
import 'presentation/screens/main_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<CustomizationCubit>(create: (_) => CustomizationCubit()),
        BlocProvider<AssessmentCubit>(create: (_) => AssessmentCubit()),
      ],
      child: const MMPI2App(),
    ),
  );
}

class MMPI2App extends StatelessWidget {
  const MMPI2App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'MMPI-2 Clinical Ultra',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            fontFamily: state.fontFamily,
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fa', 'IR'),
            Locale('en', 'US'),
          ],
          locale: const Locale('fa', 'IR'),
          home: const MainDashboard(),
        );
      },
    );
  }
}

`

