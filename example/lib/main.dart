import 'package:custom_paginate/custom_paginate/custom_paginate.dart';
import 'package:custom_paginate/custom_paginate/custom_paginate_controller.dart';
import 'package:custom_paginate_example/logger_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
      observers: [
        LoggerProvider(),
      ],
    ),
  );
}

class Observer extends ProviderObserver {}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => Home())),
          child: Text("home"),
        ),
      ),
    );
  }
}

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  late final controller = CustomPaginateController<int, int>(initialPage: 1);

  appendPage() {
    controller.appendPage(List.generate(10, (index) => index), 2);
  }

  Future<void> _fetchPage(int page) async {
    await Future.delayed(const Duration(seconds: 2));
    controller.appendPage(
      List.generate(10, (index) => index + (page * 10)),
      page + 1,
    );
  }

  @override
  void initState() {
    super.initState();
    controller.setPageRequestListener(_fetchPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AppBar"),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => Future(() => controller.refresh()),
          child: CustomPaginate(
            controller: controller,
            builder: (context, item) {
              return ListTile(
                title: Text(item.toString()),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: appendPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}