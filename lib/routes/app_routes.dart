part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const MAIN = _Paths.MAIN;
  static const HOME = _Paths.HOME;
  static const SEARCH = _Paths.SEARCH;
  static const SAVED = _Paths.SAVED;
  static const NEWS_DETAIL = _Paths.NEWS_DETAIL;
}

abstract class _Paths {
  _Paths._();

  static const SPLASH = '/splash';
  static const MAIN = '/main';
  static const HOME = '/home';
  static const SEARCH = '/search';
  static const SAVED = '/saved';
  static const NEWS_DETAIL = '/news-detail';
}
