# custom_paginate

Example

``` dart

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


```

