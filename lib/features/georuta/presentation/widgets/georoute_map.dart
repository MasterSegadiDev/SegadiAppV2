import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:segadi/features/georuta/data/models/georoute_model.dart';

class GeorouteMap extends StatefulWidget {
  final GeorouteModel georoute;
  final LatLng? currentLocation;
  final bool isOffRoute;

  const GeorouteMap({
    super.key,
    required this.georoute,
    required this.currentLocation,
    required this.isOffRoute,
  });

  @override
  State<GeorouteMap> createState() => _GeorouteMapState();
}

class _GeorouteMapState extends State<GeorouteMap> {
  GoogleMapController? _mapController;

  /// Cuando es true, la cámara sigue automáticamente al operador.
  bool _followOperator = true;

  /// Evita que el movimiento programático de la cámara
  /// sea interpretado como movimiento manual del usuario.
  bool _isProgrammaticCameraMove = false;

  /// Última posición utilizada para mover la cámara.
  LatLng? _lastCameraLocation;

  @override
  void didUpdateWidget(covariant GeorouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newLocation = widget.currentLocation;

    if (newLocation == null) {
      return;
    }

    if (!_followOperator) {
      return;
    }

    if (_mapController == null) {
      return;
    }

    // Evitamos mover la cámara por cambios insignificantes.
    if (_lastCameraLocation != null) {
      final distance = _distanceBetween(
        _lastCameraLocation!,
        newLocation,
      );

      if (distance < 10) {
        return;
      }
    }

    _lastCameraLocation = newLocation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_followOperator) {
        return;
      }

      _moveCameraToOperator(
        newLocation,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final originLatitude = widget.georoute.origin.latitude;
    final originLongitude = widget.georoute.origin.longitude;

    if (originLatitude == null || originLongitude == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No se encontró la ubicación del origen.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final destinationLatitude = widget.georoute.destination.latitude;

    final destinationLongitude = widget.georoute.destination.longitude;

    if (destinationLatitude == null || destinationLongitude == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No se encontró la ubicación del destino.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final origin = LatLng(
      originLatitude,
      originLongitude,
    );

    final destination = LatLng(
      destinationLatitude,
      destinationLongitude,
    );

    final routePoints = widget.georoute.route.coordinates
        .map(
          (coordinate) => LatLng(
            coordinate.latitude,
            coordinate.longitude,
          ),
        )
        .toList();

    final currentLocation = widget.currentLocation;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('origin'),
        position: origin,
        zIndexInt: 10,
        infoWindow: InfoWindow(
          title: 'Origen',
          snippet: widget.georoute.origin.name,
        ),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        zIndexInt: 10,
        infoWindow: InfoWindow(
          title: 'Destino',
          snippet: widget.georoute.destination.name,
        ),
      ),
    };

    if (currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('operator'),
          position: currentLocation,
          zIndexInt: 100,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          anchor: const Offset(
            0.5,
            0.5,
          ),
          infoWindow: const InfoWindow(
            title: 'Tu ubicación',
          ),
        ),
      );
    }

    final polylines = <Polyline>{};

    if (routePoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('georoute'),
          points: routePoints,
          width: 7,
          color: widget.isOffRoute ? Colors.red : Colors.blue,
          geodesic: false,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          zIndex: 5,
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentLocation ?? origin,
            zoom: currentLocation != null ? 16 : 10,
          ),
          markers: markers,
          polylines: polylines,

          // La ubicación la manejamos nosotros mediante
          // LocationService + GeorouteViewModel.
          myLocationEnabled: false,
          myLocationButtonEnabled: false,

          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,

          // Permite al operador manipular libremente el mapa.
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomGesturesEnabled: true,

          onMapCreated: (controller) {
            _mapController = controller;

            final location = widget.currentLocation;

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) {
                return;
              }

              if (location != null && _followOperator) {
                _lastCameraLocation = location;

                await _moveCameraToOperator(
                  location,
                );
              } else {
                await _showEntireRoute();
              }
            });
          },

          /// Si el operador mueve manualmente el mapa,
          /// dejamos de seguir automáticamente su ubicación.
          onCameraMoveStarted: () {
            if (_isProgrammaticCameraMove) {
              return;
            }

            if (_followOperator) {
              setState(() {
                _followOperator = false;
              });
            }
          },
        ),

        // ============================================================
        // ESTADO DE LA RUTA
        // ============================================================

        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildRouteStatus(),
        ),

        // ============================================================
        // BOTONES
        // ============================================================

        Positioned(
          right: 16,
          bottom: 24,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'route',
                mini: true,
                tooltip: 'Mostrar ruta completa',
                onPressed: _showEntireRoute,
                child: const Icon(
                  Icons.route,
                ),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'location',
                mini: true,
                tooltip: _followOperator
                    ? 'Siguiendo mi ubicación'
                    : 'Seguir mi ubicación',
                onPressed: _centerOnOperator,
                child: Icon(
                  _followOperator ? Icons.gps_fixed : Icons.my_location,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // ESTADO DE LA RUTA
  // ==============================================================

  Widget _buildRouteStatus() {
    if (widget.isOffRoute) {
      return Card(
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Te encuentras fuera de la ruta establecida.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ruta activa',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // CENTRAR / SEGUIR OPERADOR
  // ==============================================================

  Future<void> _centerOnOperator() async {
    final location = widget.currentLocation;

    if (location == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Todavía no se ha obtenido tu ubicación.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _followOperator = true;
    });

    _lastCameraLocation = location;

    await _moveCameraToOperator(
      location,
    );
  }

  // ==============================================================
  // MOVER CÁMARA AL OPERADOR
  // ==============================================================

  Future<void> _moveCameraToOperator(
    LatLng location,
  ) async {
    final controller = _mapController;

    if (controller == null) {
      return;
    }

    _isProgrammaticCameraMove = true;

    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 16,
          ),
        ),
      );
    } finally {
      // Esperamos un poco para que Google Maps termine
      // de procesar el movimiento antes de considerar
      // otro movimiento como interacción manual.
      await Future<void>.delayed(
        const Duration(
          milliseconds: 100,
        ),
      );

      _isProgrammaticCameraMove = false;
    }
  }

  // ==============================================================
  // MOSTRAR RUTA COMPLETA
  // ==============================================================

  Future<void> _showEntireRoute() async {
    final controller = _mapController;

    if (controller == null) {
      return;
    }

    final originLatitude = widget.georoute.origin.latitude;
    final originLongitude = widget.georoute.origin.longitude;

    final destinationLatitude = widget.georoute.destination.latitude;

    final destinationLongitude = widget.georoute.destination.longitude;

    if (originLatitude == null ||
        originLongitude == null ||
        destinationLatitude == null ||
        destinationLongitude == null) {
      return;
    }

    final points = <LatLng>[
      LatLng(
        originLatitude,
        originLongitude,
      ),
      ...widget.georoute.route.coordinates.map(
        (coordinate) => LatLng(
          coordinate.latitude,
          coordinate.longitude,
        ),
      ),
      LatLng(
        destinationLatitude,
        destinationLongitude,
      ),
    ];

    if (points.isEmpty) {
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) {
        minLat = point.latitude;
      }

      if (point.latitude > maxLat) {
        maxLat = point.latitude;
      }

      if (point.longitude < minLng) {
        minLng = point.longitude;
      }

      if (point.longitude > maxLng) {
        maxLng = point.longitude;
      }
    }

    // Evita problemas si todos los puntos fueran iguales.
    if (minLat == maxLat) {
      minLat -= 0.001;
      maxLat += 0.001;
    }

    if (minLng == maxLng) {
      minLng -= 0.001;
      maxLng += 0.001;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        minLat,
        minLng,
      ),
      northeast: LatLng(
        maxLat,
        maxLng,
      ),
    );

    setState(() {
      _followOperator = false;
    });

    _isProgrammaticCameraMove = true;

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          60,
        ),
      );
    } finally {
      await Future<void>.delayed(
        const Duration(
          milliseconds: 100,
        ),
      );

      _isProgrammaticCameraMove = false;
    }
  }

  // ==============================================================
  // DISTANCIA ENTRE DOS PUNTOS
  // ==============================================================

  double _distanceBetween(
    LatLng first,
    LatLng second,
  ) {
    return Geolocator.distanceBetween(
      first.latitude,
      first.longitude,
      second.latitude,
      second.longitude,
    );
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }
}
