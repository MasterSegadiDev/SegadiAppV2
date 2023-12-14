class Success {
  int? code;
  Object response;
  Success({this.code, required this.response});
}

class Failure {
  int code;
  String errorResponse;
  Failure({required this.code, required this.errorResponse});
}
