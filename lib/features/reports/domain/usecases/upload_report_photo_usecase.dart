import 'package:cross_file/cross_file.dart';

import 'package:civic_app/features/reports/domain/repositories/report_repository.dart';

class UploadReportPhotoUseCase {
  const UploadReportPhotoUseCase(this._repository);

  final ReportRepository _repository;

  Future<String> call(XFile file) => _repository.uploadPhoto(file);
}
