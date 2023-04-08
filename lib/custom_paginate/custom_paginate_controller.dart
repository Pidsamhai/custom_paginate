// ignore_for_file: must_call_super

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

ProviderBase<CustomPaginateController<K, T>> createCustomPaginateProvider<K, T>(
    CustomPaginateController<K, T> controller) {
  final provider = ChangeNotifierProvider.family<CustomPaginateController<K, T>,
          PageData<K, T>>(((ref, arg) => controller.._ref = ref),
      name: "CustomPaginate<$K, $T>");
  // ignore: no_leading_underscores_for_local_identifiers
  final _provider = provider(PageData<K, T>(nextPage: controller.initialPage));
  controller._provider = _provider;
  return _provider;
}

class CustomPaginateController<K, T> extends ChangeNotifier {
  CustomPaginateController({required this.initialPage});
  ProviderBase<CustomPaginateController<K, T>>? _provider;
  final K initialPage;
  Ref? _ref;
  late K? _nextPage = initialPage;
  K? get nextPage => _nextPage;
  final List<T> items = [];

  dynamic _error;
  dynamic get error => _error;
  set error(dynamic e) {
    _error = e;
    _state = PageState.error;
    notifyListeners();
  }

  CustomPageRequestListener<K>? _pageRequestListener;

  PageState _state = PageState.init;
  PageState get state => _state;

  appendPage(List<T> data, K? nextPage) {
    items.addAll(data);
    _nextPage = nextPage;
    _state = PageState.loaded;
    notifyListeners();
  }

  appendLastPage(List<T> data) {
    items.addAll(data);
    _nextPage = null;
    _state = PageState.ended;
    notifyListeners();
  }

  void setPageRequestListener(CustomPageRequestListener<K> listner,
      [bool loadInitial = true]) {
    _pageRequestListener = listner;
    if (!loadInitial) return;
    refresh();
  }

  void removePageRequestListener(CustomPageRequestListener<K> listner) {
    _pageRequestListener = null;
  }

  void callNextPage() {
    if (nextPage == null ||
        state == PageState.loading ||
        _pageRequestListener == null) return;
    _state = PageState.loading;
    _error = null;
    notifyListeners();
    _pageRequestListener?.call(nextPage as K);
  }

  void refresh() {
    if (state == PageState.loading) return;
    items.clear();
    _nextPage = initialPage;
    callNextPage();
  }

  @override
  void dispose() {
    if (_provider != null && _ref != null) {
      _ref!.invalidate(_provider!);
    }
  }
}

class PageData<K, T> {
  final K nextPage;
  final dynamic error;

  const PageData({
    required this.nextPage,
    this.error,
  });
}

enum PageState {
  init,
  loading,
  loaded,
  error,
  ended,
}

typedef CustomPageRequestListener<K> = Function(K nextPage);
