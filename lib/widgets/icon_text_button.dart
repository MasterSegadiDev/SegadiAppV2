import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? activeColor;
  final bool isEnabled;
  final VoidCallback? onPressed;
  final double iconSize;

  const IconTextButton({
    Key? key,
    required this.icon,
    required this.label,
    this.activeColor,
    required this.isEnabled,
    this.onPressed,
    this.iconSize = 25.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        IconButton(
          icon: Icon(
            icon,
            color: isEnabled ? activeColor : null,
          ),
          iconSize: iconSize,
          onPressed: isEnabled ? onPressed : null,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }
}
