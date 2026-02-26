import 'package:flutter/material.dart';

class SupportStatusCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final bool selected;
  final VoidCallback? onTap;

  const SupportStatusCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos colores desaturados para el fondo cuando no está seleccionado
    final Color baseColor = color.withOpacity(0.1);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: selected ? color : (enabled ? Colors.white : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Icono de fondo decorativo para dar profundidad
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(icon,
                  size: 80,
                  color: (selected ? Colors.white : color).withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          selected ? Colors.white.withOpacity(0.2) : baseColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: selected ? Colors.white : color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: selected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
