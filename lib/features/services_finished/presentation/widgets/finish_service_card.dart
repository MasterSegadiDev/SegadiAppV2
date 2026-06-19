import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/features/services_finished/domain/entities/service_finished.dart';

/*
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
                  _buildStatusBadge(item.status),
                  const SizedBox(width: 8),
                  // -------------------------------------
                  const Icon(Icons.chevron_right, color: Colors.green),
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

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // Usamos un color neutro que combine con tu diseño verde
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
        ),
      ),
    );
  }
}
*/
class FinishServiceCard extends StatelessWidget {
  final ServicesFinished item;
  final VoidCallback onTap;

  const FinishServiceCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Encabezado con color de marca sutil
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRouteSection(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, thickness: 0.5),
                    ),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS INTERNOS ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF2C522A).withOpacity(0.08),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.truckFast.data,
              size: 18, color: Color(0xFF2C522A)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'REMISIÓN: ${item.service}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
                color: Color(0xFF2C522A),
              ),
            ),
          ),
          _StatusBadge(status: item.status),
        ],
      ),
    );
  }

  Widget _buildRouteSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Línea de tiempo visual (Punto A a Punto B)
        Column(
          children: [
            const Icon(Icons.radio_button_checked,
                size: 18, color: Colors.green),
            Container(width: 2, height: 40, color: Colors.grey[300]),
            const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
          ],
        ),
        const SizedBox(width: 12),
        // Información de Origen y Destino
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _locationInfo('ORIGEN', item.origin, item.loadDate),
              const SizedBox(height: 22),
              _locationInfo('DESTINO', item.destination, item.unloadDate),
            ],
          ),
        ),
      ],
    );
  }

  Widget _locationInfo(String label, String city, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold),
        ),
        Text(
          city,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          date,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CLIENTE',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              Text(
                item.client,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[600],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
