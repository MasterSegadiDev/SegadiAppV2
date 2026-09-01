import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/services/presentation/viewmodels/service_detail_viewmodel.dart';

class SenderCard extends StatelessWidget {
  final String name;
  final String phone;
  final String directContact;
  final String address;

  const SenderCard({
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
      title: 'REMITENTE',
      icon: FontAwesomeIcons.locationDot,
      name: vm.sender?.name ?? 'Sin nombre',
      phone: vm.sender?.phone ?? 'Sin teléfono',
      directContact: vm.sender?.directContact ?? 'Sin contacto',
      address: vm.sender?.address ?? 'Sin dirección',
      headerColor: const Color(0xFF2C522A),
    );
  }
}

class PersonCard extends StatelessWidget {
  final String title;
  final FaIconData icon;
  final String name;
  final String phone;
  final String directContact;
  final String address;
  final Color headerColor;

  const PersonCard({
    super.key,
    required this.title,
    required this.icon,
    required this.name,
    required this.phone,
    required this.directContact,
    required this.address,
    required this.headerColor,
  });

  Widget _item(
    FaIconData icon,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            icon,
            size: 15,
            color: Colors.grey,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(.05),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                FaIcon(
                  icon,
                  color: headerColor,
                  size: 17,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: headerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _item(
                  FontAwesomeIcons.building,
                  name,
                ),
                _item(
                  FontAwesomeIcons.phone,
                  phone,
                ),
                _item(
                  FontAwesomeIcons.mobileScreen,
                  directContact,
                ),
                _item(
                  FontAwesomeIcons.locationDot,
                  address,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
