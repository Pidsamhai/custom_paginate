import 'package:flutter/material.dart';

import 'spacer_box.dart';

class CustomPaginateError extends StatelessWidget {
  final VoidCallback? refresh;
  final dynamic error;
  const CustomPaginateError({
    super.key,
    this.refresh,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(error.toString()),
        SpaceBox.s,
        ElevatedButton.icon(
          onPressed: refresh,
          icon: const Icon(
            Icons.refresh_rounded,
            semanticLabel: "refresh icon",
          ),
          label: const Text("Try again"),
        ),
      ],
    );
  }
}
