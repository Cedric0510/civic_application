import 'dart:io';

import 'package:civic_app/features/reports/domain/entities/report.dart';

abstract class ReportRepository {
  Future<void> createReport(Report report);
  Future<List<Report>> getMyReports();
  Future<String> uploadPhoto(File file);
}
