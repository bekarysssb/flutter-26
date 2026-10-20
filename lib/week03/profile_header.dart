import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  final String name;
  final String university;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.account_circle, size: 120),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Text(university),
      ],
    );
  }
}