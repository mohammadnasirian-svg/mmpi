import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'zen_test_view.dart';
import 'rapid_entry_console.dart';
import 'report_view.dart';
import '../cubits/customization_cubit.dart';
import '../cubits/assessment_cubit.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("سیستم جامع ارزیابی بالینی MMPI-2 ULTRA"),
          centerTitle: true,
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Badge
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00695C), Color(0xFF00897B)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(Icons.psychology, size: 54, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      "MMPI-2 Clinical Assessment Platform",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "منطبق بر استانداردهای روان‌سنجی Pearson & Gough",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Mode 1: Zen Client UI
              _buildActionCard(
                context,
                title: "ورود به محیط آزمون مراجع (Zen UI)",
                subtitle: "رابط کاربری آرامش‌بخش، ضدخستگی، دکمه‌های ارگونومیک انگشت شست",
                icon: Icons.spa_outlined,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ZenTestView()),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Mode 2: Rapid Entry Console for Therapist
              _buildActionCard(
                context,
                title: "کنسول ۵ کلیدی ورود سریع (درمانگر)",
                subtitle: "ورود فوق‌سریع پاسخنامه کاغذی، فیدبک صوتی تفکیک‌شده و هپتیک",
                icon: Icons.keyboard_alt_outlined,
                color: Colors.deepPurple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RapidEntryConsole()),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Mode 3: Clinical Reports
              _buildActionCard(
                context,
                title: "مشاهده پروفایل و گزارش روان‌سنجی",
                subtitle: "کدهای ولش و ۲ نقطه‌ای، شاخص F-K، نمرات T اصلاح‌شده و اقلام بحرانی",
                icon: Icons.analytics_outlined,
                color: Colors.indigo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportView()),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Quick Gender Selection for Test
              BlocBuilder<AssessmentCubit, AssessmentState>(
                builder: (context, state) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("جنسیت مراجع (جهت هنجاریابی T):", style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text("آقا"),
                                selected: state.gender == 'male',
                                onSelected: (sel) {
                                  if (sel) context.read<AssessmentCubit>().setGender('male');
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text("خانم"),
                                selected: state.gender == 'female',
                                onSelected: (sel) {
                                  if (sel) context.read<AssessmentCubit>().setGender('female');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
