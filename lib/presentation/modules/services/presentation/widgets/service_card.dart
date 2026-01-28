import 'package:flutter/material.dart';
import 'package:segadi/features/services_assigned/domain/entities/service_entity.dart';
import 'package:segadi/presentation/design_system/components/cards/app_list_card.dart';
import 'package:segadi/presentation/modules/services/presentation/widgets/service_body.dart';
import 'package:segadi/presentation/modules/services/presentation/widgets/service_header.dart';

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
      onTap: onTap,
      header: Header(item),
      body: Body(item),
    );
  }
}
