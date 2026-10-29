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
