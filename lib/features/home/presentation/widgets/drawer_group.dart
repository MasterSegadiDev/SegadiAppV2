import 'package:flutter/material.dart';

class DrawerGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const DrawerGroup({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        childrenPadding: const EdgeInsets.only(
          left: 8,
          bottom: 4,
        ),
        leading: Icon(
          icon,
          color: const Color(0xFF1E7A3C),
          size: 19,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF101812),
          ),
        ),
        iconColor: const Color(0xFF1E7A3C),
        collapsedIconColor: const Color(0xFF1E7A3C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        children: children,
      ),
    );
  }
}
