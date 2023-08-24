import 'package:custom_paginate/custom_paginate/custom_paginate_error.dart';
import 'package:custom_paginate/custom_paginate/custom_paginate_load_more_indicator.dart';
import 'package:flutter/gestures.dart';
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
  final Widget Function(VoidCallback refresh)? noItemWidget;
  final EdgeInsets? padding;
  final IndexedWidgetBuilder? separatorBuilder;
  final CustomPaginateController<K, T> controller;
  final ScrollController? scrollController;
  final bool reverse;
  final bool shrinkWrap;

  final Axis scrollDirection;
  final bool? primary;
  final ScrollPhysics? physics;
  final double? itemExtent;
  final Widget? prototypeItem;
  final ChildIndexGetter? findChildIndexCallback;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

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
    this.reverse = false,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.primary,
    this.physics,
    this.itemExtent,
    this.prototypeItem,
    this.findChildIndexCallback,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
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
            child: _buildLoadState(),
          )
        ],
      );
    }
    return Column(
      children: [
        if (widget.reverse) ...[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: _buildLoadState(),
          ),
        ],
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
                    reverse: widget.reverse,
                    shrinkWrap: widget.shrinkWrap,
                    physics: widget.physics,
                    controller: scrollController,
                    padding: widget.padding,
                    itemCount: ref.watch(provider).items.length,
                    itemBuilder: (context, index) => widget.builder(
                      context,
                      ref.watch(provider).items[index],
                    ),
                    separatorBuilder: widget.separatorBuilder!,
                    scrollDirection: widget.scrollDirection,
                    primary: widget.primary,
                    findChildIndexCallback: widget.findChildIndexCallback,
                    addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
                    addRepaintBoundaries: widget.addRepaintBoundaries,
                    addSemanticIndexes: widget.addSemanticIndexes,
                    cacheExtent: widget.cacheExtent,
                    dragStartBehavior: widget.dragStartBehavior,
                    keyboardDismissBehavior: widget.keyboardDismissBehavior,
                    restorationId: widget.restorationId,
                    clipBehavior: widget.clipBehavior,
                  )
                : ListView.builder(
                    reverse: widget.reverse,
                    shrinkWrap: widget.shrinkWrap,
                    physics: widget.physics,
                    controller: scrollController,
                    padding: widget.padding,
                    itemCount: ref.watch(provider).items.length,
                    itemBuilder: (context, index) => widget.builder(
                      context,
                      ref.read(provider).items[index],
                    ),
                    scrollDirection: widget.scrollDirection,
                    primary: widget.primary,
                    findChildIndexCallback: widget.findChildIndexCallback,
                    addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
                    addRepaintBoundaries: widget.addRepaintBoundaries,
                    addSemanticIndexes: widget.addSemanticIndexes,
                    cacheExtent: widget.cacheExtent,
                    dragStartBehavior: widget.dragStartBehavior,
                    keyboardDismissBehavior: widget.keyboardDismissBehavior,
                    restorationId: widget.restorationId,
                    clipBehavior: widget.clipBehavior,
                    prototypeItem: widget.prototypeItem,
                    itemExtent: widget.itemExtent,
                    semanticChildCount: widget.semanticChildCount,
                  ),
          ),
        ),
        if (!widget.reverse) ...[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: _buildLoadState(),
          ),
        ],
      ],
    );
  }

  Widget? _buildLoadState() {
    switch (ref.watch(provider).state) {
      case PageState.loading:
        return widget.loadMoreWidget;
      case PageState.error:
        return ref.read(provider).items.isNotEmpty
            ? widget.pageErrorWidget?.call(ref.read(provider).refresh) ??
                CustomPaginateError(
                  error: ref.read(provider).error,
                  refresh: ref.read(provider).callNextPage,
                )
            : widget.errorWidget;
      case PageState.ended:
        if (ref.watch(provider).items.isEmpty) {
          return widget.noItemWidget?.call(ref.read(provider).refresh) ??
              const Center(
                child: CustomPaginateNoItem(),
              );
        }
        return null;
      default:
        return null;
    }
  }
}
