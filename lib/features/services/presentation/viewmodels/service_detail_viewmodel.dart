import 'package:flutter/material.dart';
import 'package:segadi/features/services/domain/entities/recipient_entity.dart';
import 'package:segadi/features/services/domain/entities/sender_entity.dart';
import 'package:segadi/features/services/presentation/models/service_action_item.dart';
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
    print('id de la remision: ${arguments.referralId}');
    await loadService(args.serviceId);
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

  List<ServiceActionItem> get actionItems {
    if (service == null) {
      return [];
    }

    final actions = service!.actions;

    return [
      ServiceActionItem(
        title: 'Chequeo Unidad',
        icon: Icons.checklist,
        enabled: actions.checklist.enabled,
        show: actions.checklist.show,
        key: 'checklist',
      ),
      ServiceActionItem(
        title: 'Estatus Soporte',
        icon: Icons.headset,
        enabled: actions.support.enabled,
        show: actions.support.show,
        key: 'support',
      ),
      ServiceActionItem(
        title: 'Geo Ruta',
        icon: Icons.route,
        enabled: actions.route.enabled,
        show: actions.route.show,
        key: '',
      ),
      ServiceActionItem(
        title: 'Cerrar Viaje',
        icon: Icons.check_circle,
        enabled: actions.closeEvidence.enabled,
        show: actions.closeEvidence.show,
        key: '',
      ),
      ServiceActionItem(
        title: 'Viáticos',
        icon: Icons.money,
        enabled: actions.travelExpenses.enabled,
        show: actions.travelExpenses.show,
        key: '',
      ),
      ServiceActionItem(
        title: 'Descargar CCP',
        icon: Icons.picture_as_pdf,
        enabled: actions.downloadCcp.enabled,
        show: actions.downloadCcp.show,
        key: '',
      ),
    ];
  }
}
