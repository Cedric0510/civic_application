import 'dart:convert';
import 'dart:typed_data';

import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _Storage extends TokenStorage {
  @override
  Future<String?> read() async => 'tok';
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://test.local');
  });

  Future<(http.Request, String, String)> upload(XFile file) async {
    late http.Request sent;
    final client = ApiClient(
      MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({'url': 'http://test.local/uploads/a.png'}),
          201,
        );
      }),
      _Storage(),
    );
    final url = await client.uploadImage(file);
    return (sent, url, latin1.decode(sent.bodyBytes));
  }

  test(
    'sends the picked bytes as a multipart file with its image type, without touching the disk',
    () async {
      final (request, url, body) = await upload(
        XFile.fromData(
          Uint8List.fromList([137, 80, 78, 71]),
          path: 'photo.png',
          mimeType: 'image/png',
        ),
      );

      expect(url, 'http://test.local/uploads/a.png');
      expect(request.method, 'POST');
      expect(request.url.path, '/uploads');
      expect(request.headers['Authorization'], 'Bearer tok');
      expect(
        request.headers['content-type'],
        startsWith('multipart/form-data'),
      );
      expect(body, contains('name="file"'));
      expect(body, contains('filename="photo.png"'));
      expect(body, contains('content-type: image/png'));
    },
  );

  test(
    'falls back to the file extension when the picker gives no type',
    () async {
      final (_, _, body) = await upload(
        XFile.fromData(Uint8List(1), path: 'photo.webp'),
      );

      expect(body, contains('content-type: image/webp'));
    },
  );

  test('defaults to jpeg, what the camera produces', () async {
    final (_, _, body) = await upload(
      XFile.fromData(Uint8List(1), path: 'image_picker_123'),
    );

    expect(body, contains('content-type: image/jpeg'));
  });

  test(
    'gives the part a file name even when the picker gives none, or the server would ignore it',
    () async {
      final (_, _, body) = await upload(XFile.fromData(Uint8List(1)));

      expect(body, contains('filename="photo"'));
    },
  );
}
