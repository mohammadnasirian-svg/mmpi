class QuestionItem {
  final int id;
  final String textFa;
  final List<String> trueScales;
  final List<String> falseScales;
  final String? criticalCategory;

  const QuestionItem({
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
