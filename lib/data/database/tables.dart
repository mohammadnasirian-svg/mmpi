import 'package:drift/drift.dart';

class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text()();
  TextColumn get nationalCode => text()();
  IntColumn get age => integer()();
  TextColumn get gender => text()();
  TextColumn get education => text()();
  TextColumn get maritalStatus => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get notes => text().nullable()();
}

class Assessments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().customConstraint('REFERENCES clients(id)')();
  IntColumn get testType => integer()(); // 567 or 370
  TextColumn get entryMode => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get rawAnswersJson => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

class ScoreProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assessmentId => integer().customConstraint('REFERENCES assessments(id)')();
  TextColumn get rawScoresJson => text()();
  TextColumn get kCorrectedJson => text()();
  TextColumn get tScoresJson => text()();
  TextColumn get contentJson => text()();
  TextColumn get psy5Json => text()();
  TextColumn get welshCode => text()();
  IntColumn get fkIndex => integer()();
}

class ItemTimings extends Table {
  IntColumn get assessmentId => integer().customConstraint('REFERENCES assessments(id)')();
  IntColumn get itemNo => integer()();
  IntColumn get durationMs => integer()();
  IntColumn get changedAnswerCount => integer()();
  BoolColumn get isFlagged => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {assessmentId, itemNo};
}

class ClinicalReports extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assessmentId => integer().customConstraint('REFERENCES assessments(id)')();
  TextColumn get summaryReport => text()();
  TextColumn get fullAnalysisText => text()();
  TextColumn get criticalAlertsJson => text()();
  TextColumn get therapistCustomComment => text().nullable()();
}

class LongitudinalLinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().customConstraint('REFERENCES clients(id)')();
  IntColumn get baselineAssessmentId => integer()();
  IntColumn get followUpAssessmentId => integer()();
  TextColumn get deltaTScoresJson => text()();
  TextColumn get progressSummary => text()();
}

class ClinicSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clinicName => text()();
  TextColumn get therapistName => text()();
  TextColumn get licenseNumber => text()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get encryptedApiKey => text()();
  TextColumn get pinHash => text()();
}
