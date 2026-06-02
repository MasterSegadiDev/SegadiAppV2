import 'package:dartz/dartz.dart';
import 'package:segadi/features/services_finished/domain/entities/detail_finished_model.dart';
import 'package:segadi/features/services_finished/domain/entities/service_finished.dart';

import '../../core/error/failures.dart';

abstract class ServiceRepository {
  Future<Either<Failure, List<ServicesFinished>>> getFinishedServices();

  Future<Either<Failure, DetailFinished>> getServiceDetail(int serviceId);
}
