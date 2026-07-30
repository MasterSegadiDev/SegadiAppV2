import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/services/presentation/viewmodels/service_detail_viewmodel.dart';

import 'sender_card.dart';

class RecipientCard extends StatelessWidget {
  final String name;
  final String phone;
  final String directContact;
  final String address;

  const RecipientCard({
    super.key,
    required this.name,
    required this.phone,
    required this.directContact,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServiceDetailViewModel>();
    return PersonCard(
      title: 'DESTINATARIO',
      icon: FontAwesomeIcons.locationDot,
      name: vm.recipient.name,
      phone: vm.recipient.phone,
      directContact: vm.recipient.directContact,
      address: vm.recipient.address,
      headerColor: Colors.redAccent,
    );
  }
}
