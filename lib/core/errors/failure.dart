abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('Usuario o contraseña incorrectos');
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Verifica tu conexión a internet');
}

class ParsingFailure extends Failure {
  const ParsingFailure() : super('Error procesando información');
}
