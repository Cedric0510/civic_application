import 'package:civic_app/features/reports/domain/entities/report.dart';
import 'package:civic_app/features/reports/presentation/controllers/report_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyReportsController extends AutoDisposeAsyncNotifier<List<Report>> {
  @override
  Future<List<Report>> build() async {
    return ref.read(getMyReportsUseCaseProvider)();
  }
}

final myReportsControllerProvider =
    AsyncNotifierProvider.autoDispose<MyReportsController, List<Report>>(
      MyReportsController.new,
    );
