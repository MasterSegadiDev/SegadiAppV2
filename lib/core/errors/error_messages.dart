class ErrorMessages {
  ErrorMessages._();

  // Network
  static const noInternet = 'No hay conexión a internet.';

  static const connectionTimeout = 'No fue posible conectar con el servidor.';

  static const sendTimeout = 'La solicitud tardó demasiado en enviarse.';

  static const receiveTimeout = 'El servidor tardó demasiado en responder.';

  static const requestCancelled = 'La solicitud fue cancelada.';

  static const badCertificate =
      'No fue posible validar el certificado del servidor.';

  // HTTP

  static const badRequest = 'La solicitud es incorrecta.';

  static const unauthorized = 'Tu sesión ha expirado.';

  static const forbidden = 'No tienes permisos para realizar esta acción.';

  static const notFound = 'El recurso solicitado no existe.';

  static const conflict = 'Ya existe un registro con esa información.';

  static const unprocessable = 'Los datos enviados no son válidos.';

  static const tooManyRequests =
      'Se realizaron demasiadas solicitudes. Intenta nuevamente más tarde.';

  static const internalServerError = 'Ocurrió un error interno en el servidor.';

  static const badGateway = 'El servidor no está disponible.';

  static const serviceUnavailable =
      'El servicio no se encuentra disponible temporalmente.';

  static const gatewayTimeout = 'El servidor no respondió a tiempo.';

  static const unknown = 'Ha ocurrido un error inesperado.';
}
