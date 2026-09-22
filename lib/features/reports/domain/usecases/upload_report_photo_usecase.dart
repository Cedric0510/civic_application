import 'dart:io';

import 'package:civic_app/features/reports/domain/repositories/report_repository.dart';

class UploadReportPhotoUseCase {
  const UploadReportPhotoUseCase(this._repository);

  final ReportRepository _repository;

  Future<String> call(File file) => _repository.uploadPhoto(file);
}
