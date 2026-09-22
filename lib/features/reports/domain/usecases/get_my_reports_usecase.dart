import 'package:civic_app/features/reports/domain/entities/report.dart';
import 'package:civic_app/features/reports/domain/repositories/report_repository.dart';

class GetMyReportsUseCase {
  const GetMyReportsUseCase(this._repository);

  final ReportRepository _repository;

  Future<List<Report>> call() => _repository.getMyReports();
}
