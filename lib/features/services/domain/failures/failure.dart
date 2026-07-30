import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message; // <--- Agregamos esto
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure(
      {String message = "No tienes conexción a internet, revisa tu conexión"})
      : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({String message = "Sesión expirada"})
      : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message)
      : super(message); // Aquí pasamos el error del API
}

class UnknownFailure extends Failure {
  const UnknownFailure({String message = "Error desconocido"}) : super(message);
}
