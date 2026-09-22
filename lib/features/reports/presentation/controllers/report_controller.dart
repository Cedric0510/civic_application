import 'dart:io';

import 'package:civic_app/features/reports/domain/entities/report.dart';
import 'package:civic_app/features/reports/domain/usecases/create_report_usecase.dart';
import 'package:civic_app/features/reports/domain/usecases/upload_report_photo_usecase.dart';
import 'package:civic_app/features/reports/presentation/controllers/report_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportController extends StateNotifier<AsyncValue<void>> {
  ReportController(this._createUseCase, this._uploadUseCase)
    : super(const AsyncData(null));

  final CreateReportUseCase _createUseCase;
  final UploadReportPhotoUseCase _uploadUseCase;

  Future<void> submit(Report report, {File? photo}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final imageUrl = photo != null ? await _uploadUseCase(photo) : null;
      await _createUseCase(
        Report(
          address: report.address,
          category: report.category,
          description: report.description,
          imageUrl: imageUrl,
        ),
      );
    });
  }

  void reset() => state = const AsyncData(null);
}

final reportControllerProvider =
    StateNotifierProvider.autoDispose<ReportController, AsyncValue<void>>(
      (ref) => ReportController(
        ref.read(createReportUseCaseProvider),
        ref.read(uploadReportPhotoUseCaseProvider),
      ),
    );
