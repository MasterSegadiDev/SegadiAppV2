import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaGooglePage extends StatefulWidget {
  const MapaGooglePage({Key? key}) : super(key: key);

  @override
  State<MapaGooglePage> createState() => _MapaGooglePageState();
}

class _MapaGooglePageState extends State<MapaGooglePage> {
  GoogleMapController? _mapController;

  final List<LatLng> _ruta = [
    LatLng(19.0514, -104.3187), // Manzanillo
    LatLng(19.2433, -103.7255), // Colima
    LatLng(19.8000, -103.4167), // Sayula
    LatLng(20.6597, -103.3496), // Guadalajara
  ];

  final List<LatLng> _geocercaColima = [
    LatLng(19.2400, -103.7400),
    LatLng(19.2480, -103.7400),
    LatLng(19.2480, -103.7100),
    LatLng(19.2400, -103.7100),
  ];

  Set<Polyline> _crearPolyline() {
    return {
      Polyline(
        polylineId: const PolylineId('ruta'),
        points: _ruta,
        color: Colors.blue,
        width: 5,
      ),
    };
  }

  Set<Polygon> _crearGeocercas() {
    return {
      Polygon(
        polygonId: const PolygonId('geocerca_colima'),
        points: _geocercaColima,
        strokeColor: Colors.red,
        fillColor: Colors.red.withOpacity(0.3),
        strokeWidth: 2,
      ),
    };
  }

  Set<Marker> _crearMarkers() {
    return {
      Marker(
        markerId: const MarkerId('inicio'),
        position: _ruta.first,
        infoWindow: const InfoWindow(title: 'Inicio - Manzanillo'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('fin'),
        position: _ruta.last,
        infoWindow: const InfoWindow(title: 'Destino - Guadalajara'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Georuta con geocercas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C522A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(19.6, -103.8),
          zoom: 7.5,
        ),
        onMapCreated: (controller) => _mapController = controller,
        polylines: _crearPolyline(),
        polygons: _crearGeocercas(),
        markers: _crearMarkers(),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}
