class CriticalAlertItem {
  final int questionId;
  final String questionText;
  final String questionTextEn;
  final String category;
  final String categoryEn;
  final String givenAnswer;
  final String givenAnswerEn;

  const CriticalAlertItem({
    required this.questionId,
    required this.questionText,
    this.questionTextEn = '',
    required this.category,
    this.categoryEn = '',
    required this.givenAnswer,
    this.givenAnswerEn = 'True',
  });

  String localizedText(bool isEn) => isEn && questionTextEn.isNotEmpty ? questionTextEn : questionText;
  String localizedCategory(bool isEn) => isEn && categoryEn.isNotEmpty ? categoryEn : category;
  String localizedAnswer(bool isEn) => isEn ? givenAnswerEn : givenAnswer;
}

class ClinicalSection {
  final String title;
  final String titleEn;
  final String content;
  final String contentEn;
  final String severity; // 'normal', 'moderate', 'high', 'critical'

  const ClinicalSection({
    required this.title,
    this.titleEn = '',
    required this.content,
    this.contentEn = '',
    this.severity = 'normal',
  });

  String localizedTitle(bool isEn) => isEn && titleEn.isNotEmpty ? titleEn : title;
  String localizedContent(bool isEn) => isEn && contentEn.isNotEmpty ? contentEn : content;
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
  final int goldbergIndex;
  final double meanClinicalT;
  final int vrinTScore;
  final int trinTScore;
  final int unansweredCount;
  final String validityStatus;
  final String validityStatusEn;
  final String validityDescription;
  final String validityDescriptionEn;
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
    this.goldbergIndex = 45,
    this.meanClinicalT = 50.0,
    this.vrinTScore = 50,
    this.trinTScore = 50,
    required this.unansweredCount,
    this.validityStatus = 'معتبر و قابل تفسیر',
    this.validityStatusEn = 'Valid & Interpretable Profile',
    this.validityDescription = '',
    this.validityDescriptionEn = '',
    this.clinicalSections = const [],
    this.criticalAlerts = const [],
    required this.criticalItemsTriggered,
  });

  String localizedValidityStatus(bool isEn) => isEn ? validityStatusEn : validityStatus;
  String localizedValidityDesc(bool isEn) => isEn ? validityDescriptionEn : validityDescription;
}
