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
