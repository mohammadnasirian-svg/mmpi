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
