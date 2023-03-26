import 'package:flutter/material.dart';

class CustomPaginateLoadMoreIndicator extends StatelessWidget {
  const CustomPaginateLoadMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        height: 24,
        width: 24,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
