import 'package:flutter/material.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_info_row.dart';
import 'package:segadi/features/service_detail/presentation/widgets/info_row_tile_card.dart';

class InfoGroup extends StatelessWidget {
  final List<InfoRow> rows;

  const InfoGroup({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows
          .map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: InfoRowTile(row),
              ))
          .toList(),
    );
  }
}
