import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    return PersonCard(
      title: 'DESTINATARIO',
      icon: FontAwesomeIcons.locationDot,
      name: name.isNotEmpty ? name : 'Sin nombre',
      phone: phone.isNotEmpty ? phone : 'Sin teléfono',
      directContact: directContact.isNotEmpty ? directContact : 'Sin contacto',
      address: address.isNotEmpty ? address : 'Sin dirección',
    );
  }
}
