import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/features/georuta/presentation/viewmodels/georoute_viewmodel.dart';

class GeoroutePage extends StatelessWidget {
  final String serviceRequestId;

  const GeoroutePage({
    super.key,
    required this.serviceRequestId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GeorouteViewModel>(
      create: (_) {
        final vm = getIt<GeorouteViewModel>();

        vm.loadGeofences(serviceRequestId);

        return vm;
      },
      child: const _GeorouteView(),
    );
  }
}

class _GeorouteView extends StatelessWidget {
  const _GeorouteView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GeorouteViewModel>();

    if (vm.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Geo Ruta'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (vm.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Geo Ruta'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              vm.error!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo Ruta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ServiceInfoCard(
              serviceRequestId: vm.geofences?.serviceRequestId ?? '',
              serviceStatus: vm.geofences?.serviceStatus ?? 0,
            ),
            const SizedBox(height: 16),
            _RouteCard(
              routeName: vm.geofences?.wialonGeofenceLineName,
            ),
            const SizedBox(height: 16),
            _LocationCard(
              title: 'Origen',
              icon: Icons.trip_origin,
              name: vm.geofences?.wialonOriginCircleName,
              id: vm.geofences?.wialonOriginCircleId,
            ),
            const SizedBox(height: 16),
            _LocationCard(
              title: 'Destino',
              icon: Icons.location_on,
              name: vm.geofences?.wialonDestinationCircleName,
              id: vm.geofences?.wialonDestinationCircleId,
            ),
            const SizedBox(height: 16),
            _DestinationCoordinatesCard(
              latitude: vm.geofences?.destinationLat,
              longitude: vm.geofences?.destinationLng,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceInfoCard extends StatelessWidget {
  final String serviceRequestId;
  final int serviceStatus;

  const _ServiceInfoCard({
    required this.serviceRequestId,
    required this.serviceStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del servicio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Solicitud',
              value: serviceRequestId.isEmpty
                  ? 'Sin información'
                  : serviceRequestId,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Estatus',
              value: serviceStatus.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final String? routeName;

  const _RouteCard({
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    final hasRoute = routeName != null && routeName!.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.route,
              color: Color(0xFF2C522A),
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Georuta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasRoute ? routeName! : 'Sin georuta asignada',
                    style: TextStyle(
                      color: hasRoute ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? name;
  final int? id;

  const _LocationCard({
    required this.title,
    required this.icon,
    required this.name,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = name != null && name!.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF2C522A),
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasLocation ? name! : 'Sin información',
                  ),
                  if (id != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ID Wialon: $id',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationCoordinatesCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const _DestinationCoordinatesCard({
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = latitude != null && longitude != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.location_searching,
              color: Color(0xFF2C522A),
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coordenadas de destino',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasCoordinates
                        ? 'Latitud: $latitude\nLongitud: $longitude'
                        : 'Sin coordenadas disponibles',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
