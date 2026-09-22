import 'package:civic_app/features/commerces/domain/entities/commerce.dart';
import 'package:civic_app/features/commerces/presentation/controllers/commerces_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommercesController extends AutoDisposeAsyncNotifier<List<Commerce>> {
  @override
  Future<List<Commerce>> build() async {
    return ref.read(getCommercesUseCaseProvider)();
  }
}

final commercesControllerProvider =
    AsyncNotifierProvider.autoDispose<CommercesController, List<Commerce>>(
      CommercesController.new,
    );
