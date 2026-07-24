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
          horizontal: 20,
        ),
        childrenPadding: const EdgeInsets.only(
          left: 15,
          bottom: 5,
        ),
        leading: Icon(
          icon,
          color: const Color(0xFF2C522A),
          size: 20,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        iconColor: const Color(0xFF2C522A),
        collapsedIconColor: const Color(0xFF2C522A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        children: children,
      ),
    );
  }
}
