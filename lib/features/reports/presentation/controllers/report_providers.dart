import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/features/reports/data/datasources/report_api_datasource.dart';
import 'package:civic_app/features/reports/data/repositories/report_repository_impl.dart';
import 'package:civic_app/features/reports/domain/repositories/report_repository.dart';
import 'package:civic_app/features/reports/domain/usecases/create_report_usecase.dart';
import 'package:civic_app/features/reports/domain/usecases/get_my_reports_usecase.dart';
import 'package:civic_app/features/reports/domain/usecases/upload_report_photo_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportDatasourceProvider = Provider<ReportApiDatasource>((ref) {
  return ReportApiDatasource(ref.watch(apiClientProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ref.watch(reportDatasourceProvider));
});

final createReportUseCaseProvider = Provider<CreateReportUseCase>((ref) {
  return CreateReportUseCase(ref.watch(reportRepositoryProvider));
});

final getMyReportsUseCaseProvider = Provider<GetMyReportsUseCase>((ref) {
  return GetMyReportsUseCase(ref.watch(reportRepositoryProvider));
});

final uploadReportPhotoUseCaseProvider = Provider<UploadReportPhotoUseCase>((
  ref,
) {
  return UploadReportPhotoUseCase(ref.watch(reportRepositoryProvider));
});
