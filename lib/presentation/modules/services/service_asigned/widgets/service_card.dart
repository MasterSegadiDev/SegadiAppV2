import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/services_assigned/domain/entities/service_entity.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/services_viewmodel.dart';
import 'package:segadi/presentation/design_system/components/cards/app_list_card.dart';
import 'package:segadi/presentation/modules/services/service_asigned/widgets/service_body.dart';
import 'package:segadi/presentation/modules/services/service_asigned/widgets/service_header.dart';

class ServiceCard extends StatelessWidget {
  final ServiceEntity item;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      onTap: () async {
        debugPrint('Tapped on service card with id: ${item.id}');
        final result = await Navigator.pushNamed(
          context,
          '/detail_service',
          arguments: item.id,
        );

        if (result == true) {
          context.watch()<ServicesViewModel>().refresh();
        }
      },
      header: Header(item),
      body: Body(item),
    );
  }
}
