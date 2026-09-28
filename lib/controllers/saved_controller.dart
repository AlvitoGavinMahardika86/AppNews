import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/storage_service.dart';

class SavedController extends GetxController {
  final StorageService _storageService = StorageService();

  final _savedArticles = <NewsArticle>[].obs;

  List<NewsArticle> get savedArticles => _savedArticles;

  @override
  void onInit() {
    super.onInit();
    loadSavedArticles();
  }

  void loadSavedArticles() {
    _savedArticles.value = _storageService.getSavedArticles();
    update();
  }

  bool isArticleSaved(NewsArticle article) {
    return _savedArticles.any((a) => a.url == article.url);
  }

  Future<void> toggleArticle(NewsArticle article) async {
    await _storageService.toggleArticle(article);
    loadSavedArticles();
  }

  Future<void> removeArticle(NewsArticle article) async {
    await _storageService.removeArticle(article);
    loadSavedArticles();
  }
}
