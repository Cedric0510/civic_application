import 'package:civic_app/features/reports/domain/entities/report.dart';
import 'package:civic_app/features/reports/domain/repositories/report_repository.dart';

class CreateReportUseCase {
  const CreateReportUseCase(this._repository);

  final ReportRepository _repository;

  Future<void> call(Report report) => _repository.createReport(report);
}
