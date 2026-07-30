import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServiceActionsCard extends StatelessWidget {
  final VoidCallback? onEvidence;
  final VoidCallback? onDocuments;
  final VoidCallback? onStartTrip;
  final VoidCallback? onLocation;
  final VoidCallback? onSignature;
  final VoidCallback? onFinishTrip;

  const ServiceActionsCard({
    super.key,
    this.onEvidence,
    this.onDocuments,
    this.onStartTrip,
    this.onLocation,
    this.onSignature,
    this.onFinishTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          16,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
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
              color: const Color(0xFF2C522A).withOpacity(.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.dashboard_customize,
                  color: Color(0xFF2C522A),
                ),
                SizedBox(width: 10),
                Text(
                  'ACCIONES DEL SERVICIO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C522A),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: .95,
              children: [
                _ActionButton(
                  icon: FontAwesomeIcons.camera,
                  title: 'Evidencias',
                  onTap: onEvidence,
                ),
                _ActionButton(
                  icon: FontAwesomeIcons.fileLines,
                  title: 'Documentos',
                  onTap: onDocuments,
                ),
                _ActionButton(
                  icon: FontAwesomeIcons.truckFast,
                  title: 'Inicio',
                  onTap: onStartTrip,
                ),
                _ActionButton(
                  icon: FontAwesomeIcons.locationDot,
                  title: 'Ubicación',
                  onTap: onLocation,
                ),
                _ActionButton(
                  icon: FontAwesomeIcons.signature,
                  title: 'Firma',
                  onTap: onSignature,
                ),
                _ActionButton(
                  icon: FontAwesomeIcons.flagCheckered,
                  title: 'Finalizar',
                  onTap: onFinishTrip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final FaIconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(
        14,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          14,
        ),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              14,
            ),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon as FaIconData?,
                color: const Color(0xFF2C522A),
                size: 24,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
