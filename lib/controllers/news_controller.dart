import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/models/news_response.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/services/storage_service.dart';
import 'package:news_app/utils/constants.dart';

class NewsController extends GetxController {
  final NewsService _newsService = NewsService();
  final StorageService _storageService = StorageService();

  // Observable variables
  final _isLoading = false.obs;
  final _articles = <NewsArticle>[].obs;
  final _selectedCategory = 'general'.obs;
  final _error = ''.obs;
  final _isLoadingMore = false.obs;
  final _currentPage = 1.obs;
  final _hasMore = true.obs;
  final _totalResults = 0.obs;

  static const int _pageSize = 20;
  static const int _freePlanLimit = 100;

  // Search state
  final _isSearching = false.obs;
  final _searchQuery = ''.obs;
  final _searchResults = <NewsArticle>[].obs;
  final _recentSearches = <String>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<NewsArticle> get articles => _articles;
  String get selectedCategory => _selectedCategory.value;
  String get error => _error.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMore => _hasMore.value;
  List<String> get categories => Constants.categories;

  // Search getters
  bool get isSearching => _isSearching.value;
  String get searchQuery => _searchQuery.value;
  List<NewsArticle> get searchResults => _searchResults;
  List<String> get recentSearches => _recentSearches;

  Worker? _debounceWorker;

  @override
  void onInit() {
    super.onInit();
    fetchTopHeadlines();
    _loadRecentSearches();

    // Debounce search: auto-search after 500ms of no typing
    _debounceWorker = debounce(_searchQuery, (String query) {
      if (query.isNotEmpty) {
        _performSearch(query);
      }
    }, time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    _debounceWorker?.dispose();
    super.onClose();
  }

  void _loadRecentSearches() {
    _recentSearches.value = _storageService.getRecentSearches();
  }

  Future<void> fetchTopHeadlines({String? category}) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _newsService.getTopHeadlines(
        category: category ?? _selectedCategory.value,
        page: 1,
        pageSize: _pageSize,
      );

      _articles.value = response.articles;
      _currentPage.value = 1;
      _totalResults.value = response.totalResults;
      _hasMore.value = _canLoadMore;
    } catch (e) {
      _error.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to load news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshNews() async {
    await fetchTopHeadlines();
  }

  Future<void> loadMoreNews() async {
    if (_isLoading.value || _isLoadingMore.value || !_hasMore.value) return;

    final nextPage = _currentPage.value + 1;
    if (nextPage * _pageSize > _freePlanLimit) {
      _hasMore.value = false;
      return;
    }
    try {
      _isLoadingMore.value = true;
      final response = await _getNextPageWithRetry(nextPage);

      final existingUrls = _articles
          .map((article) => article.url)
          .whereType<String>()
          .toSet();
      final newArticles = response.articles
          .where(
            (article) =>
                article.url == null || !existingUrls.contains(article.url),
          )
          .toList();

      _articles.addAll(newArticles);
      _currentPage.value = nextPage;
      _hasMore.value = _canLoadMore;

      if (newArticles.isEmpty) {
        Get.snackbar(
          'No new stories yet',
          'Try loading again in a moment.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      final message = e.toString();
      if (message.contains('maximumResultsReached')) {
        _hasMore.value = false;
        return;
      }
      Get.snackbar(
        'Could not load more',
        message.replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingMore.value = false;
    }
  }

  bool get _canLoadMore {
    final availableResults = _totalResults.value > 0
        ? _totalResults.value.clamp(0, _freePlanLimit)
        : _freePlanLimit;
    return _articles.length < availableResults &&
        (_currentPage.value * _pageSize) < _freePlanLimit;
  }

  Future<NewsResponse> _getNextPageWithRetry(int page) async {
    try {
      return await _newsService.getTopHeadlines(
        category: _selectedCategory.value,
        page: page,
        pageSize: _pageSize,
      );
    } catch (firstError) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      try {
        return await _newsService.getTopHeadlines(
          category: _selectedCategory.value,
          page: page,
          pageSize: _pageSize,
        );
      } catch (_) {
        throw firstError;
      }
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      fetchTopHeadlines(category: category);
    }
  }

  // ── Search ──

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
    if (query.isEmpty) {
      _searchResults.clear();
      _isSearching.value = false;
    }
  }

  Future<void> searchNews(String query) async {
    if (query.trim().isEmpty) return;
    _searchQuery.value = query;
    await _storageService.addRecentSearch(query);
    _loadRecentSearches();
    await _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    try {
      _isSearching.value = true;
      _error.value = '';

      final response = await _newsService.searchNews(query: query);
      _searchResults.value = response.articles;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isSearching.value = false;
    }
  }

  void clearSearch() {
    _searchQuery.value = '';
    _searchResults.clear();
    _isSearching.value = false;
  }

  Future<void> removeRecentSearch(String query) async {
    await _storageService.removeRecentSearch(query);
    _loadRecentSearches();
  }

  Future<void> clearRecentSearches() async {
    await _storageService.clearRecentSearches();
    _loadRecentSearches();
  }
}
