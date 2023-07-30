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
  final List<T> _items = [];
  List<T> get items => List.unmodifiable(_items);

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

  void appendPage(List<T> data, K? nextPage) {
    _items.addAll(data);
    _nextPage = nextPage;
    _state = PageState.loaded;
    notifyListeners();
  }

  void addAll(List<T> data) {
    _items.addAll(data);
    notifyListeners();
  }

  void add(T data) {
    _items.add(data);
    notifyListeners();
  }

  void remove(T data) {
    _items.remove(data);
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void removeWhere(bool Function(T data) condition) {
    _items.removeWhere(condition);
    notifyListeners();
  }

  void insertLast(T data) {
    _items.add(data);
    notifyListeners();
  }

  void insertFirst(T data) {
    _items.insert(0, data);
    notifyListeners();
  }

  void insertAt(T data, int index) {
    _items.insert(index, data);
    notifyListeners();
  }

  void replaceWhere(T n, bool Function(T data) condition) {
    _items[_items.indexWhere(condition)] = n;
    notifyListeners();
  }

  void replace(T old, T n) {
    _items[_items.indexOf(old)] = n;
    notifyListeners();
  }

  void replaceAt(T n, int index) {
    _items[index] = n;
    notifyListeners();
  }

  void insertFirstOrReplace(T old, T n) {
    if (_items.contains(old)) {
      _items[_items.indexOf(old)] = n;
    } else {
      insertFirst(n);
    }
    notifyListeners();
  }

  void insertFirstOrReplaceWhere(T n, bool Function(T data) condition) {
    final index = _items.indexWhere(condition);
    if (index != -1) {
      _items[index] = n;
    } else {
      insertFirst(n);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void appendLastPage(List<T> data) {
    _items.addAll(data);
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
    _items.clear();
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
