import 'package:flutter/material.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';
import 'package:segadi/features/service_detail/presentation/widgets/detail_main_card.dart';
import 'package:segadi/features/service_detail/presentation/widgets/status_primary_button.dart';

class DetailContent extends StatelessWidget {
  final DetailServiceEntity entity;
  const DetailContent({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DetailMainCard(entity: entity),
        const SizedBox(height: 24),
        const StatusPrimaryButton(),
        const SizedBox(height: 32),
      ],
    );
  }
}
