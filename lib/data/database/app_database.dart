import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Clients,
  Assessments,
  ScoreProfiles,
  ItemTimings,
  ClinicalReports,
  LongitudinalLinks,
  ClinicSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // Basic DAO methods for MMPI Assessment Operations
  Future<int> insertClient(ClientsCompanion client) => into(clients).insert(client);
  Future<List<Client>> getAllClients() => select(clients).get();
  
  Future<int> startAssessment(AssessmentsCompanion assessment) => into(assessments).insert(assessment);
  Future<bool> updateAssessment(Assessment assessment) => update(assessments).replace(assessment);
  
  Future<int> saveScoreProfile(ScoreProfilesCompanion profile) => into(scoreProfiles).insert(profile);
  Future<ScoreProfile?> getScoreProfileForAssessment(int assessmentId) {
    return (select(scoreProfiles)..where((tbl) => tbl.assessmentId.equals(assessmentId))).getSingleOrNull();
  }

  Future<int> saveClinicalReport(ClinicalReportsCompanion report) => into(clinicalReports).insert(report);
  Future<ClinicalReport?> getClinicalReportForAssessment(int assessmentId) {
    return (select(clinicalReports)..where((tbl) => tbl.assessmentId.equals(assessmentId))).getSingleOrNull();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = File('mmpi_ultra_encrypted.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}
