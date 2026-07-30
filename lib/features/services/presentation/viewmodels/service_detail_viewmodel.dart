import 'package:flutter/material.dart';
import 'package:segadi/features/services/domain/entities/recipient_entity.dart';
import 'package:segadi/features/services/domain/entities/sender_entity.dart';
import 'package:segadi/features/services/presentation/models/service_detail_arguments.dart';

import '../../domain/entities/service_detail_entity.dart';
import '../../domain/usecases/get_service_detail_usecase.dart';

class ServiceDetailViewModel extends ChangeNotifier {
  late ServiceDetailArguments arguments;
  final GetServiceDetailUseCase getServiceDetailUseCase;

  ServiceDetailViewModel({
    required this.getServiceDetailUseCase,
  });

  bool isLoading = false;
  String? error;

  Future<void> initialize(
    ServiceDetailArguments args,
  ) async {
    arguments = args;

    await loadService(
      args.id,
    );
  }

  String get serviceNumber => arguments.serviceNumber;
  ServiceDetailEntity? service;
  SenderEntity get sender => service!.sender;
  RecipientEntity get recipient => service!.recipient;

  Future<void> loadService(
    String referralId,
  ) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      service = await getServiceDetailUseCase(
        referralId,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
