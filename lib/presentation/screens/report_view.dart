import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../cubits/customization_cubit.dart';
import '../cubits/assessment_cubit.dart';
import '../../domain/models/pearson_scoring_result.dart';
import '../widgets/three_d_widgets.dart';

class ReportView extends StatefulWidget {
  const ReportView({Key? key}) : super(key: key);

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _clinicalOrder = [
    'Hs',
    'D',
    'Hy',
    'Pd',
    'Mf',
    'Pa',
    'Pt',
    'Sc',
    'Ma',
    'Si',
  ];

  static const Map<String, String> _scaleNamesFa = {
    'L': 'دروغ‌سنج (L)',
    'F': 'نامتعارف بودن (F)',
    'K': 'اصلاح دفاعی (K)',
    'FB': 'نامتعارف پایانی (FB)',
    'FP': 'روان‌پریشی نامتعارف (FP)',
    'FBS': 'بزرگ‌نمایی علائم (FBS)',
    'S': 'خودبرترنمایی (S)',
    'Hs': '1- خودبیمارانگاری (Hs)',
    'D': '2- افسردگی (D)',
    'Hy': '3- هیستری (Hy)',
    'Pd': '4- انحراف روانی-اجتماعی (Pd)',
    'Mf': '5- مردانگی/زنانگی (Mf)',
    'Pa': '6- پارانویا (Pa)',
    'Pt': '7- ضعف روانی / اضطراب (Pt)',
    'Sc': '8- اسکیزوفرنی (Sc)',
    'Ma': '9- شیدایی خفیف (Ma)',
    'Si': '0- درون‌گرایی اجتماعی (Si)',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _buildFullTextReport(AssessmentState state, PearsonScoringResult res) {
    final sb = StringBuffer();
    sb.writeln("==========================================");
    sb.writeln("   کارنامه جامع روانشناختی Nahira MMPI");
    sb.writeln("   طراحان: دکتر محمد نصیریان و دکتر نبی تاه کهن");
    sb.writeln("   وب‌سایت رسمی: https://Nasirian.com");
    sb.writeln("==========================================");
    sb.writeln("نام مراجع: ${state.clientName} | سن: ${state.clientAge} | جنسیت: ${state.gender == 'male' ? 'مرد' : 'زن'}");
    sb.writeln("وضعیت اعتبار: ${res.validityStatus}");
    sb.writeln("کد دو نقطه‌ای: ${res.twoPointCode} | کد ولش: ${res.welshCode}");
    sb.writeln("شاخص گاف (F-K): ${res.fMinusKIndex} | VRIN: ${res.vrinTScore} | TRIN: ${res.trinTScore}");
    sb.writeln("------------------------------------------");
    sb.writeln("مقیاس‌های بالینی (T-Score با اصلاح K):");
    for (final s in _clinicalOrder) {
      sb.writeln(" - ${_scaleNamesFa[s] ?? s}: T = ${res.tScores[s] ?? 50} (خام: ${res.rawScores[s] ?? 0})");
    }
    sb.writeln("------------------------------------------");
    for (final sec in res.clinicalSections) {
      sb.writeln("■ ${sec.title}:");
      sb.writeln(sec.content);
      sb.writeln("");
    }
    sb.writeln("ساخته‌شده با سامانه سه بعدی Nahira MMPI - Nasirian.com");
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, customState) {
        final palette = NahiraPalette.fromPreset(customState.visualPreset);

        return BlocBuilder<AssessmentCubit, AssessmentState>(
          builder: (context, assessState) {
            if (assessState.scoringResult == null) {
              context.read<AssessmentCubit>().calculateScores();
            }
            final result = assessState.scoringResult;
            if (result == null) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette.bgTop, palette.bgBottom],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Branded 3D Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Nahira3DCard(
                            depth: 6,
                            borderRadius: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            topColor: palette.cardTop,
                            bottomColor: palette.cardBottom,
                            bevelColor: palette.cardBevel,
                            glowColor: palette.goldAccent,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => Navigator.pop(context),
                                          child: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "کارنامه بالینی Nahira MMPI",
                                              style: TextStyle(
                                                color: palette.textPrimary,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const Text(
                                              "دکتر محمد نصیریان • دکتر نبی تاه کهن | Nasirian.com",
                                              style: TextStyle(
                                                color: Color(0xFFFBBF24),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: "اشتراک‌گذاری و ارسال گزارش",
                                          icon: Icon(Icons.share_rounded, color: palette.accentPrimary),
                                          onPressed: () {
                                            final txt = _buildFullTextReport(assessState, result);
                                            Share.share(txt, subject: "گزارش بالینی Nahira MMPI");
                                          },
                                        ),
                                        IconButton(
                                          tooltip: "کپی متن کامل گزارش",
                                          icon: Icon(Icons.copy_all_rounded, color: palette.goldAccent),
                                          onPressed: () {
                                            final txt = _buildFullTextReport(assessState, result);
                                            Clipboard.setData(ClipboardData(text: txt));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("متن کامل کارنامه بالینی در حافظه کپی شد."),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TabBar(
                                  controller: _tabController,
                                  isScrollable: true,
                                  indicatorColor: palette.goldAccent,
                                  labelColor: palette.goldAccent,
                                  unselectedLabelColor: palette.textSecondary,
                                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  tabs: const [
                                    Tab(text: "اعتبار و کدها"),
                                    Tab(text: "نمودارهای سه بعدی"),
                                    Tab(text: "تفسیر بالینی پیرسون"),
                                    Tab(text: "گویه‌های بحرانی"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tab Views
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildValidityTab(assessState, result, palette),
                              _buildChartsTab(result, palette),
                              _buildNarrativeTab(result, palette),
                              _buildCriticalTab(assessState, result, palette),
                            ],
                          ),
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

  Widget _buildValidityTab(
    AssessmentState state,
    PearsonScoringResult result,
    NahiraPalette palette,
  ) {
    final isInvalid = result.validityStatus.contains("نامعتبر");
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Client & Validity Banner
        Nahira3DCard(
          depth: 7,
          tiltX: 0.01,
          topColor: palette.cardTop,
          bottomColor: palette.cardBottom,
          bevelColor: palette.cardBevel,
          glowColor: isInvalid ? Colors.redAccent : const Color(0xFF10B981),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "مراجع: ${state.clientName} (${state.clientAge} ساله)",
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isInvalid ? Colors.red : Colors.green).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isInvalid ? Colors.redAccent : Colors.greenAccent),
                    ),
                    child: Text(
                      result.validityStatus,
                      style: TextStyle(
                        color: isInvalid ? Colors.redAccent : Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                result.validityDescription,
                style: TextStyle(color: palette.textSecondary, fontSize: 13, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3D Key Diagnostic Codes Row
        Row(
          children: [
            Expanded(
              child: _metric3DTile(
                title: "کد دو نقطه‌ای",
                value: result.twoPointCode,
                subtitle: "Two-Point Code",
                color: const Color(0xFF06B6D4),
                palette: palette,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metric3DTile(
                title: "شاخص گاف (F-K)",
                value: "${result.fMinusKIndex}",
                subtitle: result.fMinusKIndex > 11 ? "احتمال تمارض" : "طبیعی",
                color: const Color(0xFFF59E0B),
                palette: palette,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metric3DTile(
                title: "ثبات پاسخ (VRIN)",
                value: "T=${result.vrinTScore}",
                subtitle: result.vrinTScore >= 80 ? "پاسخ تصادفی" : "منسجم",
                color: const Color(0xFF8B5CF6),
                palette: palette,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metric3DTile(
                title: "سوگیری بلی/خیر (TRIN)",
                value: "T=${result.trinTScore}",
                subtitle: "همخوانی درونی",
                color: const Color(0xFF10B981),
                palette: palette,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Welsh Code 3D Card
        Nahira3DCard(
          depth: 5,
          topColor: palette.cardTop,
          bottomColor: palette.cardBottom,
          bevelColor: palette.cardBevel,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "کد کامل ولش (Welsh Code):",
                style: TextStyle(color: palette.textSecondary, fontWeight: FontWeight.bold),
              ),
              Text(
                result.welshCode,
                style: TextStyle(
                  color: palette.goldAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Validity Scales Table Card
        Nahira3DCard(
          depth: 6,
          topColor: palette.cardTop,
          bottomColor: palette.cardBottom,
          bevelColor: palette.cardBevel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "جدول مقیاس‌های اعتبار (Validity Scales)",
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ...['L', 'F', 'K', 'FB', 'FP', 'FBS', 'S'].map((scale) {
                final t = result.tScores[scale] ?? 50;
                final raw = result.rawScores[scale] ?? 0;
                return _scaleProgressRow(
                  label: _scaleNamesFa[scale] ?? scale,
                  raw: raw,
                  tScore: t,
                  palette: palette,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartsTab(PearsonScoringResult result, NahiraPalette palette) {
    final List<FlSpot> spots = [];
    for (int i = 0; i < _clinicalOrder.length; i++) {
      final s = _clinicalOrder[i];
      final t = (result.tScores[s] ?? 50).toDouble();
      spots.add(FlSpot(i.toDouble(), t));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 3D LineChart of 10 Clinical Scales
        Nahira3DCard(
          depth: 8,
          tiltX: 0.01,
          topColor: palette.cardTop,
          bottomColor: palette.cardBottom,
          bevelColor: palette.cardBevel,
          glowColor: palette.accentPrimary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "نیمرخ ۱۰ مقیاس بالینی استاندارد (T-Scores با اصلاح K)",
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "خط قرمز افقی (T = 65) مرز معناداری بالینی پیرسون است",
                style: TextStyle(color: palette.textSecondary, fontSize: 11.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 9,
                    minY: 30,
                    maxY: 120,
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 15,
                      getDrawingHorizontalLine: (val) => FlLine(
                        color: Colors.white12,
                        strokeWidth: 1,
                      ),
                    ),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: 65,
                          color: Colors.redAccent,
                          strokeWidth: 2,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            labelResolver: (_) => "مرز بالینی T=65",
                          ),
                        ),
                      ],
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 34,
                          interval: 20,
                          getTitlesWidget: (val, _) => Text(
                            "${val.toInt()}",
                            style: TextStyle(color: palette.textSecondary, fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (val, _) {
                            final idx = val.toInt();
                            if (idx < 0 || idx >= _clinicalOrder.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                _clinicalOrder[idx],
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.white24),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: palette.accentPrimary,
                        barWidth: 4,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, _, __, ___) {
                            final isHigh = spot.y >= 65;
                            return FlDotCirclePainter(
                              radius: isHigh ? 6 : 4.5,
                              color: isHigh ? Colors.redAccent : palette.goldAccent,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: palette.accentPrimary.withOpacity(0.18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Detailed Clinical Scale Bars
        Nahira3DCard(
          depth: 6,
          topColor: palette.cardTop,
          bottomColor: palette.cardBottom,
          bevelColor: palette.cardBevel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "جزئیات ۱۰ مقیاس بالینی (خام، اصلاح K و نمره T)",
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ..._clinicalOrder.map((s) {
                final t = result.tScores[s] ?? 50;
                final raw = result.rawScores[s] ?? 0;
                return _scaleProgressRow(
                  label: _scaleNamesFa[s] ?? s,
                  raw: raw,
                  tScore: t,
                  palette: palette,
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // PSY-5 & Content Scales Card
        Nahira3DCard(
          depth: 6,
          topColor: palette.cardTop,
          bottomColor: palette.cardBottom,
          bevelColor: palette.cardBevel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "مقیاس‌های پنج‌گانه آسیب‌شناسی شخصیت (PSY-5) و محتوایی",
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ...result.psy5TScores.entries.map((e) {
                return _scaleProgressRow(
                  label: "PSY-5: ${e.key}",
                  raw: result.rawScores[e.key] ?? 0,
                  tScore: e.value,
                  palette: palette,
                );
              }),
              const Divider(color: Colors.white24, height: 24),
              ...result.contentTScores.entries.map((e) {
                return _scaleProgressRow(
                  label: "محتوایی: ${e.key}",
                  raw: result.rawScores[e.key] ?? 0,
                  tScore: e.value,
                  palette: palette,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrativeTab(PearsonScoringResult result, NahiraPalette palette) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: result.clinicalSections.length,
      itemBuilder: (context, index) {
        final sec = result.clinicalSections[index];
        Color badgeColor = const Color(0xFF10B981);
        if (sec.severity == 'critical') badgeColor = Colors.redAccent;
        if (sec.severity == 'high') badgeColor = Colors.orangeAccent;
        if (sec.severity == 'moderate') badgeColor = Colors.amber;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Nahira3DCard(
            depth: 6,
            topColor: palette.cardTop,
            bottomColor: palette.cardBottom,
            bevelColor: palette.cardBevel,
            glowColor: badgeColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology_rounded, color: badgeColor, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sec.title,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  sec.content,
                  style: TextStyle(
                    color: palette.textPrimary.withOpacity(0.92),
                    fontSize: 13.8,
                    height: 1.75,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCriticalTab(
    AssessmentState state,
    PearsonScoringResult result,
    NahiraPalette palette,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Nahira3DCard(
          depth: 6,
          topColor: palette.cardTop,
          bottomColor: palette.cardBottom,
          bevelColor: palette.cardBevel,
          glowColor: result.criticalAlerts.isEmpty ? Colors.green : Colors.redAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    result.criticalAlerts.isEmpty
                        ? Icons.verified_user_rounded
                        : Icons.warning_amber_rounded,
                    color: result.criticalAlerts.isEmpty ? Colors.greenAccent : Colors.redAccent,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      result.criticalAlerts.isEmpty
                          ? "هیچ گویه بحرانی خطرناکی (Koss-Butcher) فعال نشده است"
                          : "هشدار بالینی: ${result.criticalAlerts.length} گویه بحرانی نیازمند بررسی فوری!",
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "گویه‌های بحرانی نشان‌دهنده موضوعات حاد (افکار آسیب به خود، بحران روانی، پرخاشگری یا سوءمصرف) هستند که باید در جلسه مصاحبه بالینی مستقیماً بررسی شوند.",
                style: TextStyle(color: palette.textSecondary, fontSize: 12.5, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...result.criticalAlerts.map((alert) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Nahira3DCard(
              depth: 5,
              topColor: palette.cardTop,
              bottomColor: palette.cardBottom,
              bevelColor: palette.cardBevel,
              glowColor: Colors.redAccent,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "سؤال #${alert.questionId} • ${alert.category}",
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        "پاسخ مراجع: ${alert.givenAnswer}",
                        style: TextStyle(
                          color: palette.goldAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert.questionText,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Nahira3DButton(
          label: "اشتراک‌گذاری و ارسال کارنامه کامل",
          sublabel: "ارسال به تلگرام، واتساپ یا ذخیره فایل متنی",
          icon: Icons.share_rounded,
          primaryColor: const Color(0xFF0284C7),
          darkBevelColor: const Color(0xFF075985),
          onTap: () {
            final txt = _buildFullTextReport(state, result);
            Share.share(txt, subject: "کارنامه بالینی Nahira MMPI");
          },
        ),
      ],
    );
  }

  Widget _metric3DTile({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required NahiraPalette palette,
  }) {
    return Nahira3DCard(
      depth: 6,
      topColor: palette.cardTop,
      bottomColor: palette.cardBottom,
      bevelColor: palette.cardBevel,
      glowColor: color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: palette.textSecondary, fontSize: 11.5)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: palette.textSecondary, fontSize: 10.5)),
        ],
      ),
    );
  }

  Widget _scaleProgressRow({
    required String label,
    required int raw,
    required int tScore,
    required NahiraPalette palette,
  }) {
    final bool isElevated = tScore >= 65;
    final Color barColor = tScore >= 75
        ? Colors.redAccent
        : isElevated
            ? Colors.amber
            : palette.accentPrimary;
    final double ratio = ((tScore - 30) / 90.0).clamp(0.05, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 12.5,
                  fontWeight: isElevated ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
              Text(
                "خام: $raw  |  T = $tScore",
                style: TextStyle(
                  color: barColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: Colors.black26,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
