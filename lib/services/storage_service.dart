import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:news_app/models/news_article.dart';

class StorageService {
  static const String _savedArticlesKey = 'saved_articles';
  static const String _recentSearchesKey = 'recent_searches';
  static const String _profileNameKey = 'profile_name';
  static const String _profilePhoneKey = 'profile_phone';
  static const String _profileBioKey = 'profile_bio';

  final GetStorage _box = GetStorage();

  // ── Saved Articles ──

  List<NewsArticle> getSavedArticles() {
    final jsonString = _box.read<String>(_savedArticlesKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map(
            (item) =>
                NewsArticle.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveArticle(NewsArticle article) async {
    final articles = getSavedArticles();
    // Avoid duplicates by checking URL
    if (!articles.any((a) => a.url == article.url)) {
      articles.insert(0, article);
      await _box.write(
        _savedArticlesKey,
        json.encode(articles.map((a) => a.toJson()).toList()),
      );
    }
  }

  Future<void> removeArticle(NewsArticle article) async {
    final articles = getSavedArticles();
    articles.removeWhere((a) => a.url == article.url);
    await _box.write(
      _savedArticlesKey,
      json.encode(articles.map((a) => a.toJson()).toList()),
    );
  }

  bool isArticleSaved(NewsArticle article) {
    final articles = getSavedArticles();
    return articles.any((a) => a.url == article.url);
  }

  Future<void> toggleArticle(NewsArticle article) async {
    if (isArticleSaved(article)) {
      await removeArticle(article);
    } else {
      await saveArticle(article);
    }
  }

  // ── Recent Searches ──

  List<String> getRecentSearches() {
    final data = _box.read<List<dynamic>>(_recentSearchesKey);
    if (data == null) return [];
    return data.cast<String>();
  }

  Future<void> addRecentSearch(String query) async {
    final searches = getRecentSearches();
    searches.remove(query); // Remove if already exists
    searches.insert(0, query);
    // Keep max 10
    if (searches.length > 10) {
      searches.removeRange(10, searches.length);
    }
    await _box.write(_recentSearchesKey, searches);
  }

  Future<void> removeRecentSearch(String query) async {
    final searches = getRecentSearches();
    searches.remove(query);
    await _box.write(_recentSearchesKey, searches);
  }

  Future<void> clearRecentSearches() async {
    await _box.remove(_recentSearchesKey);
  }

  String getProfileName() =>
      _box.read<String>(_profileNameKey) ?? 'News Reader';

  String getProfilePhone() => _box.read<String>(_profilePhoneKey) ?? '';

  String getProfileBio() =>
      _box.read<String>(_profileBioKey) ??
      'Curious about what is happening next.';

  Future<void> saveProfile({
    required String name,
    required String phone,
    required String bio,
  }) async {
    await _box.write(
      _profileNameKey,
      name.trim().isEmpty ? 'News Reader' : name.trim(),
    );
    await _box.write(_profilePhoneKey, phone.trim());
    await _box.write(_profileBioKey, bio.trim());
  }
}
