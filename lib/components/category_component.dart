import 'package:flutter/material.dart';

class CategoryComponent extends StatelessWidget {
  const CategoryComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [Text("Category Title")],
          ),
        ),
      ),
    );
  }
}
