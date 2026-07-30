import 'package:flutter/material.dart';

class ExpandableStops extends StatefulWidget {
  final List<String> stops;

  const ExpandableStops({
    super.key,
    required this.stops,
  });

  @override
  State<ExpandableStops> createState() => _ExpandableStopsState();
}

class _ExpandableStopsState extends State<ExpandableStops> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final showExpandButton = widget.stops.length > 3;

    final visibleStops = expanded || !showExpandButton
        ? widget.stops
        : widget.stops.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESCALAS (${widget.stops.length})',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...visibleStops.map(
          (stop) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    stop,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showExpandButton)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
              ),
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
              },
              icon: Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 20,
              ),
              label: Text(
                expanded ? 'Ocultar escalas' : 'Ver todas las escalas',
              ),
            ),
          ),
      ],
    );
  }
}
