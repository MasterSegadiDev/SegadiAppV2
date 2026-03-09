import 'package:dartz/dartz.dart';
import 'package:segadi/models/services/detail_finished.dart';
import 'package:segadi/models/services/services_finished.dart';

import '../../core/error/failures.dart';

abstract class ServiceRepository {
  Future<Either<Failure, List<ServicesFinished>>> getFinishedServices();

  Future<Either<Failure, DetailFinished>> getServiceDetail(int serviceId);
}
