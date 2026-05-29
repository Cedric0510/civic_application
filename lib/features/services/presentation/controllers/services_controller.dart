import 'package:civic_app/features/services/domain/entities/service.dart';
import 'package:civic_app/features/services/presentation/controllers/services_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServicesController extends AutoDisposeAsyncNotifier<List<Service>> {
  @override
  Future<List<Service>> build() async {
    return ref.read(getServicesUseCaseProvider)();
  }
}

final servicesControllerProvider =
    AsyncNotifierProvider.autoDispose<ServicesController, List<Service>>(
      ServicesController.new,
    );
