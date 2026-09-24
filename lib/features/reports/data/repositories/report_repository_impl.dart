import 'package:cross_file/cross_file.dart';

import 'package:civic_app/features/reports/data/datasources/report_api_datasource.dart';
import 'package:civic_app/features/reports/data/models/report_model.dart';
import 'package:civic_app/features/reports/domain/entities/report.dart';
import 'package:civic_app/features/reports/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this._datasource);

  final ReportApiDatasource _datasource;

  @override
  Future<void> createReport(Report report) {
    return _datasource.createReport(
      ReportModel(
        address: report.address,
        category: report.category,
        description: report.description,
        imageUrl: report.imageUrl,
      ),
    );
  }

  @override
  Future<List<Report>> getMyReports() => _datasource.getMyReports();

  @override
  Future<String> uploadPhoto(XFile file) => _datasource.uploadPhoto(file);
}
