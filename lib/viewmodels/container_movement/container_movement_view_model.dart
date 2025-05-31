import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/models/containers/container_movement.dart';
import 'package:segadi/models/containers/container_movements.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UbicacionesViewModel extends ChangeNotifier {
  final UbicationMovement _ubicationMovement = UbicationMovement();

  List<Ubicacion> _ubicaciones = [];

  List<Ubicacion> get ubicaciones => _ubicaciones;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _token;
  get token => _token;

  String? _weight = null;
  get weight => _weight;

  get crane_movement_id => null;
  get movement_type => null;
  get crane_operator_id => null;
  get container_location_id => null;
  get new_container_location_id => null;
  get status => null;

  get document_name => null;
  get document => null;

  Future<void> cargarUbicacionesDesdeApi() async {
    final url = Uri.parse(
        'http://198.251.68.42/DesarrolloSEGADI/web/index.php?r=esegadi/getubicaciones&id=100&token=1000'); // 👈 cambia esto

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final ubicacionesList = jsonData['ubicaciones'] as List<dynamic>;

        _ubicaciones =
            ubicacionesList.map((e) => Ubicacion.fromJson(e)).toList();

        notifyListeners();
      } else {
        throw Exception('Error al cargar ubicaciones: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception al cargar ubicaciones: $e');
    }
  }

  List<String> getAreas() {
    return _ubicaciones.map((u) => u.area).toSet().toList();
  }

  List<String> getEspaciosPorArea(String area) {
    return _ubicaciones
        .where((u) => u.area == area)
        .map((u) => u.espacio)
        .toSet()
        .toList();
  }

  List<String> getNivelesPorEspacio(String area, String espacio) {
    return _ubicaciones
        .where((u) => u.area == area && u.espacio == espacio)
        .map((u) => u.nivel)
        .toSet()
        .toList();
  }

  List<Ubicacion> getUbicacionesPorAreaEspacioYNivel(
      String area, String espacio, String nivel) {
    return _ubicaciones
        .where(
            (u) => u.area == area && u.espacio == espacio && u.nivel == nivel)
        .toList();
  }

  Future<void> saveMovement(Movimiento movimiento) async {
    _errorMessage = null;
    try {
      final response = await _ubicationMovement.saveMovement(movimiento);

      if (response.statusCode == 200) {
        print('Movimiento registrado con éxito.');
        // Aquí podrías recargar datos si hace falta.
      } else {
        throw Exception('Error al guardar movimiento: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'No se pudo guardar el movimiento.';
      debugPrint('Excepción: $e');
    }

    notifyListeners();
  }

  Future<void> registrarMovimiento({
    required String movementType,
    required Ubicacion ubicacionSeleccionada,
    required String ubicationId,
    String? serviceId,
  }) async {
    print('SERVICIO ID: ${serviceId}');
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    var userId = prefs.getInt('id') ?? 0;
    Movimiento movimiento;

    switch (movementType) {
      case 'Camion-Piso':
        movimiento = Movimiento(
          service_id: serviceId,
          crane_movement_id: '123',
          movement_type: 'Camion-Piso',
          crane_operator_id: userId.toString(),
          container_location_id: ubicationId,
          new_container_location_id: ubicacionSeleccionada.codigo,
          status:
              'Lleno o Vacio', //validar este parametro, puede venir lleno o vacio el contenedor
          token: _token ?? '',
          weight: '',
          document_name: '',
          document: '',
        );
        print(
          'crane movement id ${movimiento.crane_movement_id}, '
          'movement type ${movimiento.movement_type}, '
          'crane_operator_id ${movimiento.crane_operator_id}, '
          'container_location_id ${movimiento.container_location_id}, '
          'codigo ${movimiento.new_container_location_id}',
        );
        break;
      case 'Piso-Camion':
        movimiento = Movimiento(
          service_id: serviceId,
          crane_movement_id: '123',
          movement_type: 'Piso-Camion',
          crane_operator_id: userId.toString(),
          container_location_id: ubicationId,
          new_container_location_id: ubicacionSeleccionada.codigo,
          status:
              'Lleno o Vacio', //validar este parametro, puede venir lleno o vacio el contenedor
          token: _token ?? '',
          weight: '',
          document_name: '',
          document: '',
        );
        print(
          'crane movement id ${movimiento.crane_movement_id}, '
          'movement type ${movimiento.movement_type}, '
          'crane_operator_id ${movimiento.crane_operator_id}, '
          'container_location_id ${movimiento.container_location_id}, '
          'codigo ${movimiento.new_container_location_id}',
        );
        break;

      case 'Reacomodo':
        movimiento = Movimiento(
          service_id: '',
          crane_movement_id: null,
          movement_type: 'Reacomodo',
          crane_operator_id: userId.toString(),
          container_location_id: 'container location id',
          new_container_location_id: ubicacionSeleccionada.codigo,
          status:
              'Lleno o Vacio', //validar este parametro, puede venir lleno o vacio el contenedor
          token: _token ?? '',
          weight: '',
          document_name: '',
          document: '',
        );
        print(
          'crane movement id ${movimiento.crane_movement_id}, '
          'movement type ${movimiento.movement_type}, '
          'crane_operator_id ${movimiento.crane_operator_id}, '
          'container_location_id ${movimiento.container_location_id}, '
          'codigo ${movimiento.new_container_location_id}',
        );

      case 'Pesaje':
        movimiento = Movimiento(
          service_id: '',
          crane_movement_id: null,
          movement_type: null,
          crane_operator_id: '',
          container_location_id: null,
          new_container_location_id: null,
          status: null,
          token: _token ?? '',
          weight: 'weight',
          document_name: 'document_name',
          document: 'document',
        );
        print(
          'weight ${movimiento.weight} '
          'document_name ${movimiento.document_name} '
          'document ${movimiento.document}',
        );
        break;

      default:
        throw Exception('Tipo de movimiento desconocido: $movementType');
    }

    await saveMovement(movimiento);
  }
}
