import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../cubits/customization_cubit.dart';
import '../cubits/assessment_cubit.dart';
import '../../domain/models/pearson_scoring_result.dart';
import '../../core/localization/app_strings.dart';
import '../widgets/three_d_widgets.dart';

class ReportView extends StatefulWidget {
  final bool isEmbedded;

  const ReportView({Key? key, this.isEmbedded = false}) : super(key: key);

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

  static const List<String> _psy5Order = [
    'AGGR',
    'PSYC',
    'DISC',
    'NEGE',
    'INTR',
  ];

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

  String _buildFullTextReport(
    AssessmentState state,
    PearsonScoringResult res,
    AppStrings s,
    bool isEn,
  ) {
    final sb = StringBuffer();
    sb.writeln("==========================================");
    sb.writeln(isEn
        ? "   Nahira MMPI — Clinical Psychometric Report"
        : "   کارنامه جامع بالینی Nahira MMPI");
    sb.writeln("   ${s.creatorsNames}");
    sb.writeln("   https://Nasirian.com");
    sb.writeln("==========================================");
    final nameStr = state.clientName.trim().isEmpty
        ? (isEn ? 'Clinical Examinee' : 'مراجع کلینیک')
        : state.clientName;
    final ageStr = state.clientAge > 0 ? "${state.clientAge}" : "30";
    final genderStr = state.gender == 'male' ? s.maleNorm : s.femaleNorm;
    sb.writeln(isEn
        ? "Patient: $nameStr | Age: $ageStr | Gender: $genderStr"
        : "مراجع: $nameStr | سن: $ageStr | جنسیت: $genderStr");
    sb.writeln(isEn
        ? "Validity: ${res.localizedValidityStatus(true)}"
        : "وضعیت روایی: ${res.localizedValidityStatus(false)}");
    sb.writeln(
        "Two-Point Code: ${res.twoPointCode} | Welsh Code: ${res.welshCode} | F-K: ${res.fMinusKIndex} | Goldberg: ${res.goldbergIndex}");
    sb.writeln("------------------------------------------");
    for (final code in _clinicalOrder) {
      sb.writeln(
          " - ${s.scaleName(code)}: T = ${res.tScores[code] ?? 50} (Raw: ${res.rawScores[code] ?? 0})");
    }
    sb.writeln("------------------------------------------");
    for (final sec in res.clinicalSections) {
      sb.writeln("■ ${sec.localizedTitle(isEn)}");
      sb.writeln(sec.localizedContent(isEn));
      sb.writeln("");
    }
    sb.writeln("Nahira MMPI — https://Nasirian.com");
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomizationCubit, AppCustomizationState>(
      builder: (context, customState) {
        final palette = NahiraPalette.fromPreset(customState.visualPreset);
        final s = customState.strings;
        final isEn = customState.isEn;

        return BlocBuilder<AssessmentCubit, AssessmentState>(
          builder: (context, assessState) {
            if (assessState.scoringResult == null) {
              context.read<AssessmentCubit>().calculateScores();
            }
            final result = assessState.scoringResult;
            if (result == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final content = Column(
              children: [
                // Top 3D Analytics Header & Tab Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Nahira3DCard(
                    depth: 5,
                    borderRadius: 20,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                    topColor: palette.cardTop,
                    bottomColor: palette.cardBottom,
                    bevelColor: palette.cardBevel,
                    glowColor: palette.accentPrimary,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (!widget.isEmbedded) ...[
                                  InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEn
                                          ? "3D Dynamic Clinical Analytics"
                                          : "تحلیل سه‌بعدی و کارنامه بالینی پیرسون",
                                      style: TextStyle(
                                        color: palette.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      assessState.clientName.trim().isEmpty
                                          ? s.appSubtitle
                                          : "${assessState.clientName}  •  ${assessState.gender == 'male' ? s.maleNorm : s.femaleNorm}",
                                      style: TextStyle(
                                        color: palette.textSecondary,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              tooltip: isEn ? "Copy Full Clinical Report" : "کپی متن کامل کارنامه",
                              icon: Icon(Icons.copy_all_rounded, color: palette.goldAccent),
                              onPressed: () {
                                final txt = _buildFullTextReport(assessState, result, s, isEn);
                                Clipboard.setData(ClipboardData(text: txt));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEn
                                          ? "Full clinical report copied to clipboard."
                                          : "متن کامل کارنامه بالینی در حافظه کپی شد.",
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorColor: palette.accentPrimary,
                          labelColor: palette.accentPrimary,
                          unselectedLabelColor: palette.textSecondary,
                          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                          tabs: [
                            Tab(text: isEn ? "3D Profile Charts" : "نمودارهای سه‌بعدی پویا"),
                            Tab(text: isEn ? "Structural & Validity" : "ساختار و شاخص‌های اعتبار"),
                            Tab(text: isEn ? "Clinical Narrative" : "تفسیر جامع بالینی"),
                            Tab(text: isEn ? "Critical Alerts" : "گویه‌های بحرانی"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDynamicChartsTab(result, palette, s, isEn),
                      _buildValidityAndStructureTab(assessState, result, palette, s, isEn),
                      _buildNarrativeTab(result, palette, isEn),
                      _buildCriticalTab(assessState, result, palette, s, isEn),
                    ],
                  ),
                ),
              ],
            );

            if (widget.isEmbedded) {
              return Directionality(
                textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
                child: content,
              );
            }

            return Directionality(
              textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
              child: Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette.bgTop, palette.bgBottom],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(child: content),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDynamicChartsTab(
    PearsonScoringResult result,
    NahiraPalette palette,
    AppStrings s,
    bool isEn,
  ) {
    final List<FlSpot> spots = [];
    for (int i = 0; i < _clinicalOrder.length; i++) {
      final code = _clinicalOrder[i];
      final t = (result.tScores[code] ?? 50).toDouble();
      spots.add(FlSpot(i.toDouble(), t));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // 1. Interactive 3D Clinical Profile Line Chart
        NahiraInteractive3DCard(
          palette: palette,
          glowColor: palette.accentPrimary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn
                              ? "10 Clinical Scales Profile (K-Corrected T-Scores)"
                              : "نیمرخ پویا ۱۰ مقیاس بالینی استاندارد (نمره T با اصلاح K)",
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isEn
                              ? "Touch points on the curve to inspect exact scale metrics • Red line: T=65 clinical cutoff"
                              : "نقاط روی نمودار را لمس کنید • خط قرمز (T=65) مرز معناداری بالینی است",
                          style: TextStyle(color: palette.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: palette.accentPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: palette.accentPrimary.withOpacity(0.5)),
                    ),
                    child: Text(
                      result.twoPointCode,
                      style: TextStyle(
                        color: palette.accentPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 255,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 9,
                    minY: 30,
                    maxY: 120,
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.toInt().clamp(0, _clinicalOrder.length - 1);
                            final code = _clinicalOrder[idx];
                            final raw = result.rawScores[code] ?? 0;
                            final kRaw = result.kCorrectedRaw[code] ?? raw;
                            return LineTooltipItem(
                              "${s.scaleName(code)}\nT = ${spot.y.toInt()}  |  Raw = $raw (K:$kRaw)",
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 15,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.white.withOpacity(0.08),
                        strokeWidth: 1,
                      ),
                    ),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: 65,
                          color: const Color(0xFFF43F5E),
                          strokeWidth: 2,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            style: const TextStyle(
                              color: Color(0xFFFB7185),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            labelResolver: (_) => "T = 65",
                          ),
                        ),
                        HorizontalLine(
                          y: 50,
                          color: Colors.white24,
                          strokeWidth: 1,
                          dashArray: [3, 3],
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
                                  fontWeight: FontWeight.w800,
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
                      border: Border.all(color: Colors.white12),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.25,
                        color: palette.accentPrimary,
                        barWidth: 3.8,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, _, __, ___) {
                            final isHigh = spot.y >= 65;
                            return FlDotCirclePainter(
                              radius: isHigh ? 6.2 : 4.5,
                              color: isHigh ? const Color(0xFFF43F5E) : palette.goldAccent,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              palette.accentPrimary.withOpacity(0.32),
                              palette.accentSecondary.withOpacity(0.03),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
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

        // 2. PSY-5 Personality Psychopathology 3D Bar Chart
        NahiraInteractive3DCard(
          palette: palette,
          glowColor: palette.accentSecondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn
                    ? "PSY-5 Personality Psychopathology Dimensions"
                    : "نیمرخ پنج‌بُعدی آسیب‌شناسی شخصیت (PSY-5)",
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 190,
                child: BarChart(
                  BarChartData(
                    minY: 30,
                    maxY: 110,
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.white.withOpacity(0.08),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 20,
                          getTitlesWidget: (v, _) => Text(
                            "${v.toInt()}",
                            style: TextStyle(color: palette.textSecondary, fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= _psy5Order.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                _psy5Order[idx],
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
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(_psy5Order.length, (i) {
                      final key = _psy5Order[i];
                      final val = (result.psy5TScores[key] ?? 50).toDouble();
                      final isHigh = val >= 65;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: val,
                            width: 24,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            gradient: LinearGradient(
                              colors: isHigh
                                  ? [const Color(0xFFF43F5E), const Color(0xFFBE123C)]
                                  : [palette.accentPrimary, palette.accentSecondary],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Detailed 10 Clinical Scales + 15 Content Scales Breakdown
        Nahira3DCard(
          depth: 6,
          topColor: palette.cardTop,
          bottomColor: palette.cardBottom,
          bevelColor: palette.cardBevel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn
                    ? "Detailed Clinical & Content Scales Breakdown"
                    : "جدول تفصیلی مقیاس‌های بالینی دهگانه و ۱۵ مقیاس محتوایی",
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              ..._clinicalOrder.map((code) {
                final t = result.tScores[code] ?? 50;
                final raw = result.rawScores[code] ?? 0;
                return _scaleProgressRow(
                  label: s.scaleName(code),
                  raw: raw,
                  tScore: t,
                  palette: palette,
                  isEn: isEn,
                );
              }),
              const Divider(color: Colors.white24, height: 26),
              ...result.contentTScores.entries.map((e) {
                return _scaleProgressRow(
                  label: s.scaleName(e.key),
                  raw: result.rawScores[e.key] ?? 0,
                  tScore: e.value,
                  palette: palette,
                  isEn: isEn,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValidityAndStructureTab(
    AssessmentState state,
    PearsonScoringResult result,
    NahiraPalette palette,
    AppStrings s,
    bool isEn,
  ) {
    final statusText = result.localizedValidityStatus(isEn);
    final isWarning = statusText.contains("مخدوش") ||
        statusText.contains("هشدار") ||
        statusText.contains("Questionable") ||
        statusText.contains("Alert");

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // Validity Status Card
        NahiraInteractive3DCard(
          palette: palette,
          glowColor: isWarning ? Colors.amber : const Color(0xFF10B981),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isWarning ? Icons.info_rounded : Icons.verified_rounded,
                    color: isWarning ? Colors.amber : const Color(0xFF10B981),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                result.localizedValidityDesc(isEn),
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 13,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 6 Structural Indices Grid (2x3)
        Row(
          children: [
            Expanded(
              child: _metric3DTile(
                title: isEn ? "Two-Point Code" : "تیپ کدی دو نقطه‌ای",
                value: result.twoPointCode,
                subtitle: isEn ? "Primary Diagnostic Code" : "کد تشخیصی اصلی",
                color: const Color(0xFF0EA5E9),
                palette: palette,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metric3DTile(
                title: isEn ? "Gough Index (F-K)" : "شاخص تمارض گاف (F-K)",
                value: "${result.fMinusKIndex}",
                subtitle: result.fMinusKIndex > 11
                    ? (isEn ? "Over-reporting Alert" : "احتمال بزرگ‌نمایی")
                    : (isEn ? "Within Normal Limits" : "در دامنه طبیعی"),
                color: const Color(0xFFF59E0B),
                palette: palette,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metric3DTile(
                title: isEn ? "Goldberg Index" : "شاخص گلدبرگ",
                value: "${result.goldbergIndex}",
                subtitle: result.goldbergIndex >= 45
                    ? (isEn ? "Psychotic Slope (>45)" : "سازمان سایکوتیک (>45)")
                    : (isEn ? "Neurotic Slope (<45)" : "سازمان نوروتیک (<45)"),
                color: const Color(0xFF8B5CF6),
                palette: palette,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metric3DTile(
                title: isEn ? "Mean Clinical T" : "میانگین ارتفاع بالینی",
                value: "${result.meanClinicalT}",
                subtitle: isEn ? "Overall Distress Level" : "شدت کلی تنش روانی",
                color: const Color(0xFF10B981),
                palette: palette,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metric3DTile(
                title: "VRIN (T-Score)",
                value: "${result.vrinTScore}",
                subtitle: isEn ? "Response Consistency" : "ثبات پاسخ‌دهی",
                color: const Color(0xFF06B6D4),
                palette: palette,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metric3DTile(
                title: "TRIN (T-Score)",
                value: "${result.trinTScore}",
                subtitle: isEn ? "True/False Bias" : "سوگیری موافقت/مخالفت",
                color: const Color(0xFFEC4899),
                palette: palette,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Welsh Code Full String
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
                isEn ? "Complete Welsh Code:" : "کد کامل نیمرخ ولش:",
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
        const SizedBox(height: 14),

        // Validity Scales Table
        Nahira3DCard(
          depth: 6,
          topColor: palette.cardTop,
          bottomColor: palette.cardBottom,
          bevelColor: palette.cardBevel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn ? "Validity Scales Profile" : "جدول شاخص‌های اعتبار پیرسون",
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ...['L', 'F', 'K', 'FB', 'FP', 'FBS', 'S'].map((scale) {
                final t = result.tScores[scale] ?? 50;
                final raw = result.rawScores[scale] ?? 0;
                return _scaleProgressRow(
                  label: s.scaleName(scale),
                  raw: raw,
                  tScore: t,
                  palette: palette,
                  isEn: isEn,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrativeTab(
    PearsonScoringResult result,
    NahiraPalette palette,
    bool isEn,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: result.clinicalSections.length,
      itemBuilder: (context, index) {
        final sec = result.clinicalSections[index];
        Color badgeColor = const Color(0xFF10B981);
        if (sec.severity == 'critical') badgeColor = const Color(0xFFF43F5E);
        if (sec.severity == 'high') badgeColor = Colors.orangeAccent;
        if (sec.severity == 'moderate') badgeColor = Colors.amber;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: NahiraInteractive3DCard(
            palette: palette,
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
                        sec.localizedTitle(isEn),
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  sec.localizedContent(isEn),
                  style: TextStyle(
                    color: palette.textPrimary.withOpacity(0.92),
                    fontSize: 13.5,
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
    AppStrings s,
    bool isEn,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                          ? (isEn
                              ? "No Critical Risk Items Triggered"
                              : "هیچ گویه بحرانی پرخطری فعال نشده است")
                          : (isEn
                              ? "Clinical Alert: ${result.criticalAlerts.length} Critical Items Endorsed"
                              : "هشدار بالینی: ${result.criticalAlerts.length} گویه بحرانی نیازمند بررسی در مصاحبه"),
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
                isEn
                    ? "Critical items represent acute clinical themes (suicidal ideation, severe anxiety, perceptual distortion, or substance risk) requiring direct inquiry during the clinical interview."
                    : "گویه‌های بحرانی نشان‌دهنده موضوعات حاد بالینی (افکار آسیب به خود، بحران هیجانی یا علائم ادراکی) هستند که باید در جلسه مصاحبه مستقیماً بررسی شوند.",
                style: TextStyle(color: palette.textSecondary, fontSize: 12.5, height: 1.55),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${s.questionWord} #${alert.questionId}  •  ${alert.localizedCategory(isEn)}",
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        alert.localizedAnswer(isEn),
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
                    alert.localizedText(isEn),
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 13.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
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
      depth: 5,
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
              fontSize: 21,
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
    required bool isEn,
  }) {
    final bool isElevated = tScore >= 65;
    final Color barColor = tScore >= 75
        ? const Color(0xFFF43F5E)
        : isElevated
            ? Colors.amber
            : palette.accentPrimary;
    final double ratio = ((tScore - 30) / 90.0).clamp(0.05, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12.5,
                    fontWeight: isElevated ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ),
              Text(
                isEn ? "Raw: $raw  •  T = $tScore" : "خام: $raw  •  T = $tScore",
                style: TextStyle(
                  color: barColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
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
