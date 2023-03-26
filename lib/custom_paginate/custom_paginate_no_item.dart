import 'package:flutter/material.dart';

import 'spacer_box.dart';

class CustomPaginateNoItem extends StatelessWidget {
  const CustomPaginateNoItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "No item found",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SpaceBox.s,
      ],
    );
  }
}
