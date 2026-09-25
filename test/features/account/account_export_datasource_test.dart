import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/account/data/datasources/account_api_datasource.dart';
import '../../support/no_token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://test.local');
  });

  test('asks the server to e-mail the data, with no body', () async {
    late http.Request seen;
    final datasource = AccountApiDatasource(
      ApiClient(
        MockClient((request) async {
          seen = request;
          return http.Response('', 204);
        }),
        NoTokenStorage(),
      ),
    );

    await datasource.requestDataExport();

    expect(seen.method, 'POST');
    expect(seen.url.path, '/citizens/me/export/email');
  });
}
