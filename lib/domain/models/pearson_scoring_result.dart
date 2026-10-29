class CriticalAlertItem {
  final int questionId;
  final String questionText;
  final String category;
  final String givenAnswer;

  const CriticalAlertItem({
    required this.questionId,
    required this.questionText,
    required this.category,
    required this.givenAnswer,
  });
}

class ClinicalSection {
  final String title;
  final String content;
  final String severity; // 'normal', 'moderate', 'high', 'critical'

  const ClinicalSection({
    required this.title,
    required this.content,
    this.severity = 'normal',
  });
}

class PearsonScoringResult {
  final Map<String, int> rawScores;
  final Map<String, int> kCorrectedRaw;
  final Map<String, int> tScores;
  final Map<String, int> contentTScores;
  final Map<String, int> psy5TScores;
  final String twoPointCode;
  final String welshCode;
  final int fMinusKIndex;
  final int vrinTScore;
  final int trinTScore;
  final int unansweredCount;
  final String validityStatus;
  final String validityDescription;
  final List<ClinicalSection> clinicalSections;
  final List<CriticalAlertItem> criticalAlerts;
  final List<int> criticalItemsTriggered;

  const PearsonScoringResult({
    required this.rawScores,
    required this.kCorrectedRaw,
    required this.tScores,
    this.contentTScores = const {},
    this.psy5TScores = const {},
    required this.twoPointCode,
    required this.welshCode,
    required this.fMinusKIndex,
    this.vrinTScore = 50,
    this.trinTScore = 50,
    required this.unansweredCount,
    this.validityStatus = 'معتبر و قابل تفسیر',
    this.validityDescription = '',
    this.clinicalSections = const [],
    this.criticalAlerts = const [],
    required this.criticalItemsTriggered,
  });
}
