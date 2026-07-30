import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  List<ServiceActionItem> get actionItems {
    if (service == null) {
      return [];
    }

    final actions = service!.actions;

    return [
      ServiceActionItem(
        id: 'checklist',
        title: 'Chequeo Unidad',
        icon: FontAwesomeIcons.listCheck,
        enabled: actions.checklist,
        onTap: () {
          // TODO: Navegar a Checklist
        },
      ),
      ServiceActionItem(
        id: 'support',
        title: 'Estatus Soporte',
        icon: FontAwesomeIcons.headset,
        enabled: actions.support,
        onTap: () {},
      ),
      ServiceActionItem(
        id: 'route',
        title: 'Geo Ruta',
        icon: FontAwesomeIcons.route,
        enabled: actions.route,
        onTap: () {},
      ),
      ServiceActionItem(
        id: 'close_evidence',
        title: 'Cerrar Viaje',
        icon: FontAwesomeIcons.circleCheck,
        enabled: actions.closeEvidence,
        onTap: () {},
      ),
      ServiceActionItem(
        id: 'travel_expenses',
        title: 'Viáticos',
        icon: FontAwesomeIcons.moneyBill,
        enabled: actions.travelExpenses,
        onTap: () {},
      ),
      ServiceActionItem(
        id: 'download_ccp',
        title: 'Descargar CCP',
        icon: FontAwesomeIcons.filePdf,
        enabled: actions.downloadCcp,
        onTap: () {},
      ),
    ];
  }
}
