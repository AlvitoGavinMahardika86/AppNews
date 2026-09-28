import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static const String baseUrl = 'https://newsapi.org/v2';

  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';

  static const List<String> categories = [
    'general',
    'technology',
    'business',
    'sports',
    'health',
    'science',
    'entertainment',
  ];

  static const String defaultCountry = 'us';

  static const String appName = 'News App';
  static const String appVersion = '1.0.0';
}
