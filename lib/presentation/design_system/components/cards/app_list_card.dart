import 'package:flutter/material.dart';

class AppListCard extends StatelessWidget {
  final Widget header;
  final Widget body;
  final VoidCallback? onTap;

  const AppListCard({
    super.key,
    required this.header,
    required this.body,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 12),
              body,
            ],
          ),
        ),
      ),
    );
  }
}
