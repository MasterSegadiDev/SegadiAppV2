import 'dart:io';

abstract class PesajeRepository {
  Future<bool> registrarPesaje({
    required String movementId,
    required String serie,
    required String peso,
    required String nameImage,
    required File image,
    required String siteId,
  });
}
