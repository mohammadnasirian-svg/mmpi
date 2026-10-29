import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/assessment_cubit.dart';
import '../../domain/models/pearson_scoring_result.dart';

class ReportView extends StatelessWidget {
  const ReportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("گزارش تحلیلی MMPI-2 (استاندارد Pearson)"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "آزمون جدید",
            onPressed: () {
              context.read<AssessmentCubit>().resetTest();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<AssessmentCubit, AssessmentState>(
        builder: (context, state) {
          final result = state.scoringResult;
          if (result == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("هیچ نتیجه‌ای هنوز ثبت نشده است."),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AssessmentCubit>().calculateScores(),
                    child: const Text("محاسبه نمرات آزمون"),
                  ),
                ],
              ),
            );
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Card
                  _buildSummaryCard(result, state),
                  const SizedBox(height: 20),

                  // Validity Scales Section
                  const Text("مقیاس‌های اعتبارسنجی (Validity Scales)",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildValidityGrid(result),
                  const SizedBox(height: 24),

                  // Clinical Scales Section
                  const Text("مقیاس‌های بالینی (Clinical Scales - T-Scores)",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildClinicalScoresList(result),
                  const SizedBox(height: 24),

                  // Critical Items Alert
                  if (result.criticalItemsTriggered.isNotEmpty) ...[
                    const Text("گزاره‌های بحرانی فعال‌شده (Critical Items)",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 12),
                    _buildCriticalItemsCard(result),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(PearsonScoringResult res, AssessmentState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("کد ۲ نقطه‌ای (Two-Point Code): ${res.twoPointCode}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
              Chip(
                label: Text("شاخص F - K: ${res.fMinusKIndex}"),
                backgroundColor: res.fMinusKIndex.abs() > 11 ? Colors.red.shade100 : Colors.teal.shade100,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("کد ولش (Welsh Code): ${res.welshCode}",
              style: const TextStyle(fontSize: 15, fontFamily: 'monospace')),
          const SizedBox(height: 8),
          Text("تعداد پاسخ‌های مبهم/بدون پاسخ (Cannot Say): ${res.unansweredCount}"),
        ],
      ),
    );
  }

  Widget _buildValidityGrid(PearsonScoringResult res) {
    final validityKeys = ['L', 'F', 'K', 'FB', 'FP', 'FBS', 'S'];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: validityKeys.map((k) {
        final raw = res.rawScores[k] ?? 0;
        final t = res.tScores[k] ?? 50;
        final isHigh = t >= 65;

        return Container(
          width: 95,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isHigh ? Colors.amber.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isHigh ? Colors.amber : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Text(k, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text("خام: $raw", style: const TextStyle(fontSize: 12, color: Colors.black54)),
              Text("T: $t", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isHigh ? Colors.red.shade700 : Colors.black87)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClinicalScoresList(PearsonScoringResult res) {
    final clinicalScales = [
      {'key': 'Hs', 'name': '۱. هیپوکندریا (خودبیمارانگاری)'},
      {'key': 'D', 'name': '۲. افسردگی'},
      {'key': 'Hy', 'name': '۳. هیستری'},
      {'key': 'Pd', 'name': '۴. انحراف روانی-اجتماعی'},
      {'key': 'Mf', 'name': '۵. زنانگی - مردانگی'},
      {'key': 'Pa', 'name': '۶. پارانویا'},
      {'key': 'Pt', 'name': '۷. ضعف روانی (اضطراب)'},
      {'key': 'Sc', 'name': '۸. اسکیزوفرنی'},
      {'key': 'Ma', 'name': '۹. هیپومانیا'},
      {'key': 'Si', 'name': '۰. درون‌گرایی اجتماعی'},
    ];

    return Column(
      children: clinicalScales.map((s) {
        final key = s['key']!;
        final name = s['name']!;
        final raw = res.rawScores[key] ?? 0;
        final kCorr = res.kCorrectedRaw[key] ?? raw;
        final t = res.tScores[key] ?? 50;
        final isElevated = t >= 65;

        return Card(
          elevation: isElevated ? 2 : 0,
          color: isElevated ? Colors.red.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isElevated ? Colors.red.shade300 : Colors.grey.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(name, style: TextStyle(fontWeight: isElevated ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text("نمره خام: $raw | پس از اصلاح K: $kCorr"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isElevated ? Colors.red : Colors.teal.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("T = $t", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCriticalItemsCard(PearsonScoringResult res) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "تعداد ${res.criticalItemsTriggered.length} گویه بحرانی علامت‌گذاری شده است: "
            "${res.criticalItemsTriggered.join(', ')}",
            style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            "توجه بالینی: گزاره‌های نشان‌دهنده افکار خودکشی، بحران عاطفی شدید یا باورهای گزند و آسیب نیاز به مصاحبه ساختاریافته فوری دارند.",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
