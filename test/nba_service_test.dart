import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:court_iq/services/nba_service.dart';

void main() {
  test('NBA service decodes headlines from HTTP JSON', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.host, 'site.api.espn.com');
      return http.Response(
          jsonEncode({
            'articles': [
              {
                'headline': 'Basketball practice update',
                'description': 'Practice description',
                'source': {'name': 'Test source'},
                'published': '2026-10-16T00:00:00Z',
              }
            ],
          }),
          200);
    });
    final service = NbaService(client: client);
    final result = await service.fetchStories();
    expect(result, hasLength(1));
    expect(result.first.title, 'Basketball practice update');
    expect(result.first.source, 'Test source');
    expect(result.first.isSample, false);
    service.dispose();
  });

  test('NBA service surfaces HTTP errors', () async {
    final service = NbaService(
        client:
            MockClient((request) async => http.Response('Unavailable', 503)));
    await expectLater(service.fetchStories(), throwsException);
    service.dispose();
  });

  test('NBA service surfaces invalid API structure', () async {
    final service = NbaService(
        client: MockClient(
            (request) async => http.Response('{"articles":{}}', 200)));
    await expectLater(service.fetchStories(), throwsFormatException);
    service.dispose();
  });
}
