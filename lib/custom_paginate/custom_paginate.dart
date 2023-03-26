import 'package:custom_paginate/custom_paginate/custom_paginate_error.dart';
import 'package:custom_paginate/custom_paginate/custom_paginate_load_more_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'custom_paginate_controller.dart';
import 'custom_paginate_no_item.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);

class CustomPaginate<K, T> extends ConsumerStatefulWidget {
  final ItemBuilder<T> builder;
  final Widget loadMoreWidget;
  final Widget loadWidget;
  final Widget Function(VoidCallback refresh)? pageErrorWidget;
  final Widget? errorWidget;
  final Widget? noItemWidget;
  final EdgeInsets? padding;
  final IndexedWidgetBuilder? separatorBuilder;
  final CustomPaginateController<K, T> controller;
  final ScrollController? scrollController;

  const CustomPaginate({
    super.key,
    required this.builder,
    this.loadMoreWidget = const CustomPaginateLoadMoreIndicator(),
    this.loadWidget = const Center(
      child: CircularProgressIndicator(),
    ),
    this.pageErrorWidget,
    this.errorWidget,
    this.noItemWidget,
    this.padding,
    this.separatorBuilder,
    required this.controller,
    this.scrollController,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomPaginateState<K, T>();
}

class _CustomPaginateState<K, T> extends ConsumerState<CustomPaginate<K, T>> {
  late final provider = createCustomPaginateProvider<K, T>(
    widget.controller,
  );

  late final scrollController = widget.scrollController ?? ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(provider).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentState = ref.watch(provider).state;
    if (ref.read(provider).items.isEmpty) {
      if (currentState == PageState.loading) {
        return widget.loadMoreWidget;
      }
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: _buildContentFromState(),
          )
        ],
      );
    }
    return Column(
      children: [
        Flexible(
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (t) {
              final scrollEnded = t.metrics.pixels > 0 && t.metrics.atEdge ||
                  t.metrics.maxScrollExtent == 0;
              final fetchNext = scrollEnded &&
                  (![PageState.ended, PageState.loading, PageState.error]
                      .contains(currentState));
              if (!fetchNext) return false;
              ref.read(provider).callNextPage();
              return false;
            },
            child: widget.separatorBuilder != null
                ? ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    padding: widget.padding,
                    itemCount: ref.watch(provider).items.length,
                    itemBuilder: (context, index) => widget.builder(
                      context,
                      ref.watch(provider).items[index],
                    ),
                    separatorBuilder: widget.separatorBuilder!,
                  )
                : ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    padding: widget.padding,
                    itemCount: ref.watch(provider).items.length,
                    itemBuilder: (context, index) => widget.builder(
                      context,
                      ref.watch(provider).items[index],
                    ),
                  ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: _buildContentFromState(),
        ),
      ],
    );
  }

  Widget? _buildContentFromState() {
    switch (ref.watch(provider).state) {
      case PageState.loading:
        return widget.loadMoreWidget;
      case PageState.error:
        return widget.pageErrorWidget?.call(ref.read(provider).callNextPage) ??
            CustomPaginateError(
              error: ref.read(provider).error,
              refresh: ref.read(provider).callNextPage,
            );
      case PageState.ended:
        return const Center(
          child: CustomPaginateNoItem(),
        );
      default:
        return null;
    }
  }
}
