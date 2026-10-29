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
