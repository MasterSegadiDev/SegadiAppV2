import '../errors/failure.dart';

class Result<T> {
  final T? data;

  final Failure? failure;

  const Result._({
    this.data,
    this.failure,
  });

  factory Result.success(T data) {
    return Result._(
      data: data,
    );
  }

  factory Result.failure(Failure failure) {
    return Result._(
      failure: failure,
    );
  }

  bool get isSuccess => data != null;

  bool get isFailure => failure != null;
}
