import 'package:segadi/features/local_service/domain/entities/stretch.dart';

sealed class TramoState {
  const TramoState();
}

final class TramoInitial extends TramoState {
  const TramoInitial();
}

final class TramoLoading extends TramoState {
  const TramoLoading();
}

final class TramoEmpty extends TramoState {
  const TramoEmpty();
}

final class TramoLoaded extends TramoState {
  final Tramo tramo;
  final bool updatingStatus;

  const TramoLoaded({
    required this.tramo,
    this.updatingStatus = false,
  });

  TramoLoaded copyWith({
    Tramo? tramo,
    bool? updatingStatus,
  }) {
    return TramoLoaded(
      tramo: tramo ?? this.tramo,
      updatingStatus: updatingStatus ?? this.updatingStatus,
    );
  }
}

final class TramoError extends TramoState {
  final String message;

  const TramoError({
    required this.message,
  });
}
