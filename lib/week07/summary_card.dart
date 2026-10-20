import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birth,
  });

  final String name;
  final String email;
  final String group;
  final String birth;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ListTile(leading: const Icon(Icons.person), title: Text(name)),
      ListTile(leading: const Icon(Icons.email), title: Text(email)),
      ListTile(leading: const Icon(Icons.group), title: Text(group)),
      ListTile(leading: const Icon(Icons.cake), title: Text(birth)),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 4,
            children: tiles,
          );
        }
        return Column(children: tiles);
      },
    );
  }
}