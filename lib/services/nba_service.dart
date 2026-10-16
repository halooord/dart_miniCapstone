import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsStory {
  final String title;
  final String summary;
  final String source;
  final DateTime? published;
  final bool isSample;

  const NewsStory({
    required this.title,
    required this.summary,
    required this.source,
    this.published,
    this.isSample = false,
  });

  static const sample = <NewsStory>[
    NewsStory(
      title: 'Practice tip: build consistency through repetition',
      summary:
          'Set a target number of makes at each shooting spot. Write down the result so you can measure improvement.',
      source: 'Court IQ training tip',
      isSample: true,
    ),
    NewsStory(
      title: 'Train your weak hand every session',
      summary:
          'Spend at least five minutes dribbling, passing and finishing with your less comfortable hand.',
      source: 'Court IQ training tip',
      isSample: true,
    ),
    NewsStory(
      title: 'Recovery is part of your game',
      summary:
          'After a hard session, cool down, hydrate and leave room for rest before another high-intensity workout.',
      source: 'Court IQ training tip',
      isSample: true,
    ),
  ];
}

/// Calls a public ESPN NBA news endpoint; no API key is required.
/// This is a third-party endpoint, so the screen handles downtime and errors.
class NbaService {
  final http.Client _client;

  // An injectable HTTP client makes the network layer testable offline.
  NbaService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() => _client.close();

  static final Uri endpoint = Uri.parse(
    'https://site.api.espn.com/apis/site/v2/sports/basketball/nba/news?limit=12',
  );

  Future<List<NewsStory>> fetchStories() async {
    final response = await _client.get(endpoint, headers: {
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception('The news service returned HTTP ${response.statusCode}.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected API response.');
    }
    final articles = decoded['articles'];
    if (articles is! List) {
      throw const FormatException('Missing articles in API response.');
    }
    return articles
        .whereType<Map>()
        .map((raw) {
          final article = Map<String, dynamic>.from(raw);
          final source = article['source'];
          final sourceName =
              source is Map ? (source['name']?.toString() ?? 'ESPN') : 'ESPN';
          final date =
              DateTime.tryParse(article['published']?.toString() ?? '');
          return NewsStory(
            title: (article['headline']?.toString().trim().isNotEmpty ?? false)
                ? article['headline'].toString().trim()
                : 'NBA update',
            summary:
                (article['description']?.toString().trim().isNotEmpty ?? false)
                    ? article['description'].toString().trim()
                    : 'No summary was provided for this headline.',
            source: sourceName,
            published: date,
          );
        })
        .where((story) => story.title.isNotEmpty)
        .toList();
  }
}
