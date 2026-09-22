import 'dart:io';

import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/reports/data/models/report_model.dart';

class ReportApiDatasource {
  const ReportApiDatasource(this._api);

  final ApiClient _api;

  Future<void> createReport(ReportModel model) async {
    await _api.post('/reports', model.toJson());
  }

  Future<List<ReportModel>> getMyReports() async {
    final json = await _api.get('/reports/mine') as List<dynamic>;
    final reports = json
        .map((item) => ReportModel.fromJson(item as Map<String, dynamic>))
        .toList();
    reports.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return reports;
  }

  Future<String> uploadPhoto(File file) => _api.uploadImage(file);
}
