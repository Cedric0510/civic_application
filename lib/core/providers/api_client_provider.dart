import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/core/providers/http_client_provider.dart';
import 'package:civic_app/core/providers/token_storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    ref.watch(httpClientProvider),
    ref.watch(tokenStorageProvider),
  );
});
