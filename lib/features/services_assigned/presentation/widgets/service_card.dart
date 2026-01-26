import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/services_assigned/domain/entities/service_entity.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/services_viewmodel.dart';

class ServiceCard extends StatelessWidget {
  final ServiceEntity item;

  const ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          '/detail_service',
          arguments: item.id,
        );

        if (result == true) {
          context.watch()<ServicesViewModel>().refresh();
        }
      },
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF84A756)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title(item),
              const Divider(),
              _Section(
                title: 'Origen de Carga',
                icon: Icons.location_on,
                rows: [
                  _info('Origen', item.origin),
                  _info('Fecha', item.loadDate),
                ],
              ),
              _Section(
                title: 'Destino de Carga',
                icon: Icons.flag,
                rows: [
                  _info('Destino', item.destination),
                  _info('Fecha', item.unloadDate),
                ],
              ),
              _Section(
                title: 'Escalas',
                icon: Icons.map,
                rows: [
                  _info('Primera', item.scaleOne),
                  _info('Segunda', item.scaleTwo),
                ],
              ),
              const SizedBox(height: 12),
              _StatusButton(item.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: ${value ?? '-'}',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final ServiceEntity item;

  const _Title(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(FontAwesomeIcons.truck, color: Colors.green),
      title: Text(
        'Remisión: ${item.service ?? '-'}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Cliente: ${item.client ?? '-'}'),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> rows;

  const _Section({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...rows,
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String? status;

  const _StatusButton(this.status);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2C522A),
        disabledBackgroundColor: Colors.green,
        minimumSize: const Size.fromHeight(40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Text(
        status ?? 'Desconocido',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
