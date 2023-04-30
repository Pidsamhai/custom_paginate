import 'package:custom_paginate/custom_paginate/custom_paginate.dart';
import 'package:custom_paginate/custom_paginate/custom_paginate_controller.dart';
import 'package:custom_paginate_example/logger_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      observers: [
        LoggerProvider(),
      ],
      child: const MyApp(),
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

  gotoExtra() {
    // controller.appendLastPage(List.generate(10, (index) => index));
    controller.error = "error";
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const ExtraPage(),
    //   ),
    // );
  }

  Future<void> _fetchPage(int page) async {
    await Future.delayed(const Duration(seconds: 2));
    controller.appendPage(
      List.generate(10, (index) => index + (page * 10)),
      page + 1,
    );
    await Future.delayed(const Duration(seconds: 2));
    controller.error = "Error";
  }

  @override
  void initState() {
    super.initState();
    controller.setPageRequestListener(_fetchPage);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
            noItemWidget: (r) => Center(
              child: Text("Custom NoItem"),
            ),
            pageErrorWidget: (e) => Center(
              child: Text("Custom Error"),
            ),
            errorWidget: Text("Page Custom Error"),
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
        onPressed: gotoExtra,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExtraPage extends StatelessWidget {
  const ExtraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Extra Page"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
          ),
          child: const Text("back"),
        ),
      ),
    );
  }
}
