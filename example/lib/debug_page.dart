import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:custom_paginate/custom_paginate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PostState {
  initial,
  loading,
  loaded,
  error,
  none,
}

class Post {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
  PostState state = PostState.none;
  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });
}

class DebugPage extends ConsumerStatefulWidget {
  const DebugPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DebugPageState();
}

class _DebugPageState extends ConsumerState<DebugPage> {
  late final controller = CustomPaginateController<int, Post>(initialPage: 1);

  Future<void> fetchPage(int page) async {
    await Future.delayed(const Duration(seconds: 2));
    controller.appendPage(
        List.generate(20, (index) {
          return index + (page * 100);
        })
            .map((e) => Post(
                id: e,
                title: e.toString(),
                body: e.toString(),
                createdAt: DateTime.now()))
            .toList(),
        page + 1);
  }

  @override
  void initState() {
    controller.setPageRequestListener(fetchPage);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void creatgePost() async {
    final randomId = Random().nextInt(150);
    HttpClient client = HttpClient();
    final req =
        await client.getUrl(Uri.parse("https://dummyjson.com/posts/$randomId"));
    final res = await req.close();
    final data = await res.transform(utf8.decoder).join();
    final jsonData = json.decode(data);
    final post = Post(
      id: jsonData['id'],
      title: jsonData['title'],
      body: jsonData['body'],
      createdAt: DateTime.now(),
    );
    controller.add(post);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: () => Future(() => controller.refresh()),
        child: CustomPaginate<int, Post>(
          reverse: true,
          controller: controller,
          builder: (context, item) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (item.state == PostState.loading) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(width: 8),
                        ],
                        TextButton.icon(
                          onPressed: () {
                            final editItem = item;
                            editItem.state = PostState.loading;
                            controller.replaceWhere(
                              editItem,
                              (data) => data.id == editItem.id,
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit"),
                        ),
                        TextButton.icon(
                          onPressed: () => controller.remove(item),
                          icon: const Icon(Icons.delete),
                          label: const Text("Delete"),
                        ),
                      ],
                    ),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(item.body),
                    const SizedBox(height: 8),
                    Text(
                      item.createdAt.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: "refresh",
            onPressed: () {},
            child: const Icon(Icons.refresh),
          ),
          FloatingActionButton.small(
            heroTag: "add",
            onPressed: creatgePost,
            child: const Icon(Icons.add),
          ),
          FloatingActionButton.small(
            heroTag: "clear",
            onPressed: controller.clear,
            child: const Icon(Icons.clear_all),
          ),
          FloatingActionButton.small(
            heroTag: "error",
            onPressed: () {
              controller.error = "Error";
            },
            child: const Icon(Icons.error),
          ),
        ],
      ),
    );
  }
}
