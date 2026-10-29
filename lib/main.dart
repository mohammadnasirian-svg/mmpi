import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;

// ==========================================
// 1. DATABASE (Drift SQLite)
// ==========================================
class Assessments extends drift.Table {
  drift.IntColumn get id => integer().autoIncrement()();
  drift.IntColumn get testType => integer()();
  drift.DateTimeColumn get startTime => dateTime()();
  drift.TextColumn get rawAnswersJson => text()();
}

// ==========================================
// 2. PSYCHOMETRIC ENGINE
// ==========================================
class PearsonScoringEngine {
  static Map<String, int> evaluate(List<String> answers) {
    Map<String, int> raw = {'L': 0, 'F': 0, 'K': 0, 'Hs': 0, 'D': 0};
    // منطق کلیدزنی (ساده شده برای بیلد یکپارچه)
    return raw;
  }
}

// ==========================================
// 3. STATE MANAGEMENT (Cubit)
// ==========================================
class AppState {
  final bool isLeftHanded;
  final String theme;
  AppState({this.isLeftHanded = false, this.theme = 'sepia'});
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState());
  void toggleHand() => emit(AppState(isLeftHanded: !state.isLeftHanded, theme: state.theme));
  
  void onRapidKeyTap(String key) {
    if (key == 'T') HapticFeedback.lightImpact();
    else if (key == 'F') HapticFeedback.mediumImpact();
  }
}

// ==========================================
// 4. UI SCREENS
// ==========================================
class ZenTestView extends StatelessWidget {
  const ZenTestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F1),
      appBar: AppBar(title: const Text('آزمون مراجع - MMPI-2'), backgroundColor: Colors.teal),
      body: SafeArea(
        child: Column(
          children: [
            const LinearProgressIndicator(value: 0.2),
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'اغلب احساس می‌کنم سرم درد می‌کند.',
                    style: TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                        onPressed: () => HapticFeedback.selectionClick(),
                        child: const Text('خیر / غلط', style: TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700),
                        onPressed: () => HapticFeedback.selectionClick(),
                        child: const Text('بلی / درست', style: TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RapidEntryConsole extends StatelessWidget {
  const RapidEntryConsole({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(title: const Text('کنسول ورود سریع درمانگر'), backgroundColor: Colors.black),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade900,
            child: const Center(child: Text('سوال ۲۴۵', style: TextStyle(color: Colors.white, fontSize: 24))),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => context.read<AppCubit>().onRapidKeyTap('F'),
                    child: Container(
                      color: Colors.red.shade800,
                      child: const Center(child: Text('غلط (F)', style: TextStyle(fontSize: 32, color: Colors.white))),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => context.read<AppCubit>().onRapidKeyTap('T'),
                    child: Container(
                      color: Colors.green.shade800,
                      child: const Center(child: Text('درست (T)', style: TextStyle(fontSize: 32, color: Colors.white))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پنل مدیریت MMPI-2')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZenTestView())),
              child: const Padding(padding: EdgeInsets.all(12.0), child: Text('ورود به محیط مراجع', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RapidEntryConsole())),
              child: const Padding(padding: EdgeInsets.all(12.0), child: Text('کنسول ۵ کلیدی درمانگر', style: TextStyle(fontSize: 18, color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. APP ENTRY POINT
// ==========================================
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BlocProvider(
      create: (context) => AppCubit(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MMPI-2 Ultra',
        home: DashboardScreen(),
      ),
    ),
  );
}
