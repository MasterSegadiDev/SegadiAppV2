import 'package:flutter/material.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';
import 'package:segadi/features/service_detail/presentation/widgets/actions_card.dart';

class DetailMainCard extends StatelessWidget {
  final DetailServiceEntity entity;
  const DetailMainCard({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // ENCABEZADO ESTILO LISTADO
          _buildTopHeader(),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // SECCIÓN DE RUTA (Línea de tiempo)
                _buildRouteTimeline(),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1, thickness: 0.5),
                ),

                // SECCIÓN DE ACCIONES (GridView de tu ActionsCard)
                ActionsCard(ui: entity, onRefresh: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C522A).withOpacity(0.08),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF2C522A),
            radius: 18,
            child:
                Icon(Icons.description_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('REMISIÓN ASIGNADA',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C522A),
                      letterSpacing: 1.1)),
              Text(entity.service,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteTimeline() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Línea visual
        Column(
          children: [
            const Icon(Icons.radio_button_checked,
                size: 20, color: Colors.green),
            Container(width: 2, height: 110, color: Colors.grey[200]),
            const Icon(Icons.location_on, size: 20, color: Colors.redAccent),
          ],
        ),
        const SizedBox(width: 16),
        // Información
        Expanded(
          child: Column(
            children: [
              _buildLocationDetails(
                'REMITENTE',
                entity.senderBusinessName,
                entity.senderName,
                entity.senderPhoneNumber,
                '${entity.senderStreet} ${entity.senderOutdoorNumber}',
              ),
              const SizedBox(height: 30),
              _buildLocationDetails(
                'DESTINATARIO',
                entity.recipientBusinessName,
                entity.recipientName,
                entity.recipientPhoneNumber,
                '${entity.recipientStreet} ${entity.recipientOutdoorNumber}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDetails(String tag, String? biz, String? contact,
      String? phone, String? address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tag,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(biz ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(contact ?? '-',
            style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.phone, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(phone ?? '-',
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          ],
        ),
        Text(address ?? '-',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            maxLines: 2),
      ],
    );
  }
}
