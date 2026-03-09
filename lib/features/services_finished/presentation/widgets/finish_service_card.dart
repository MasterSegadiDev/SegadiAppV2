import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/models/services/services_finished.dart';

class FinishServiceCard extends StatelessWidget {
  final ServicesFinished item;
  final VoidCallback onTap;

  const FinishServiceCard({Key? key, required this.item, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F0), // Un verde muy tenue de fondo
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.truckFast,
                      size: 18, color: Color(0xFF2C522A)),
                  const SizedBox(width: 10),
                  Text(
                    'Remisión: ${item.service}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow(Icons.business, "Cliente", item.client),
                  const Divider(height: 20),
                  _locationRow("Origen", item.origin, item.loadDate),
                  const SizedBox(height: 12),
                  _locationRow("Destino", item.destination, item.unloadDate),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ",
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13))),
      ],
    );
  }

  Widget _locationRow(String label, String city, String date) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on_outlined,
            size: 16, color: Color(0xFF2C522A)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(city,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13)),
              Text(date,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
