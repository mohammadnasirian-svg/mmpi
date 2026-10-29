class QuestionItem {
  final int id;
  final String textFa;
  final String textEn;
  final List<String> trueScales;
  final List<String> falseScales;
  final String? criticalCategory;
  final String? criticalCategoryEn;

  String get text => textFa;

  String localizedText(bool isEn) => isEn ? textEn : textFa;
  String? localizedCriticalCategory(bool isEn) => isEn ? (criticalCategoryEn ?? criticalCategory) : criticalCategory;

  const QuestionItem({
    required this.id,
    required this.textFa,
    this.textEn = '',
    required this.trueScales,
    required this.falseScales,
    this.criticalCategory,
    this.criticalCategoryEn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'textFa': textFa,
      'textEn': textEn,
      'trueScales': trueScales,
      'falseScales': falseScales,
      'criticalCategory': criticalCategory,
      'criticalCategoryEn': criticalCategoryEn,
    };
  }

  factory QuestionItem.fromMap(Map<String, dynamic> map) {
    return QuestionItem(
      id: map['id'] as int,
      textFa: map['textFa'] as String,
      textEn: (map['textEn'] as String?) ?? '',
      trueScales: List<String>.from(map['trueScales'] ?? []),
      falseScales: List<String>.from(map['falseScales'] ?? []),
      criticalCategory: map['criticalCategory'] as String?,
      criticalCategoryEn: map['criticalCategoryEn'] as String?,
    );
  }
}
