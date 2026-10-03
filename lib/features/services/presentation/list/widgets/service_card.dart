import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:segadi/app/router/app_routes.dart';
import 'package:segadi/features/services/presentation/detail/arguments/service_detail_arguments.dart';
import 'package:segadi/features/services/presentation/list/widgets/expandable_stops.dart';

import '../../../domain/entities/assigned_service.dart';
import '../../../../../core/theme/app_colors.dart'; // ajusta la ruta a donde la dejes

class ServiceCard extends StatelessWidget {
  final AssignedService service;

  const ServiceCard({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          AppRoutes.serviceDetail,
          extra: ServiceDetailArguments(
            idSolicitud: service.serviceId,
            idRemision: service.referralId,
            serviceNumber: service.serviceNumber,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.surfaceDark.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRouteSection(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        height: 1,
                        thickness: .5,
                        color: AppColors.border,
                      ),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.primaryGreenSoft,
      child: Row(
        children: [
          const FaIcon(
            FontAwesomeIcons.truckFast,
            size: 18,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'REMISIÓN: ${service.serviceNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: .5,
                color: AppColors.surfaceDark,
              ),
            ),
          ),
          _StatusBadge(status: service.serviceStatus),
        ],
      ),
    );
  }

  Widget _buildRouteSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(
              Icons.radio_button_checked,
              size: 18,
              color: AppColors.primaryGreen,
            ),
            Container(width: 2, height: 40, color: AppColors.border),
            const Icon(
              Icons.location_on,
              size: 18,
              color: AppColors.errorRed,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _locationInfo('ORIGEN', service.origin, service.loadingDate),
              const SizedBox(height: 22),
              _locationInfo(
                  'DESTINO', service.destination, service.unloadingDate),
              if (service.stops.isNotEmpty) ...[
                const SizedBox(height: 18),
                ExpandableStops(stops: service.stops),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _locationInfo(String label, String city, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          city,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CLIENTE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                service.customer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'RESPONSABLE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                service.responsible,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textMuted,
        ),
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
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Colores semánticos por estatus — se mantienen distintos entre sí
  // a propósito, pero "finalizado" ahora usa el verde de marca.
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'inicio':
        return const Color(0xFF2E6BB8); // azul
      case 'en ruta':
        return const Color(0xFFC77A1F); // naranja
      case 'finalizado':
        return AppColors.primaryGreen;
      case 'cancelado':
        return AppColors.errorRed;
      default:
        return AppColors.textMuted;
    }
  }
}
