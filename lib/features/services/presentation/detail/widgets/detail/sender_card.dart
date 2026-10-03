import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class _C {
  static const surfaceDark = Color(0xFF101812);
  static const primaryGreen = Color(0xFF1E7A3C);
  static const primaryGreenSoft = Color(0xFFE1F0E3);

  static const textPrimary = Color(0xFF101812);
  static const textSecondary = Color(0xFF6B6B66);
  static const textMuted = Color(0xFF9A9A94);

  static const border = Color(0xFFE0E0DA);
}

// ============================================================
// REMITENTE
// ============================================================

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
    return PersonCard(
      title: 'REMITENTE',
      icon: FontAwesomeIcons.arrowUpFromBracket,
      name: name.isNotEmpty ? name : 'Sin nombre',
      phone: phone.isNotEmpty ? phone : 'Sin teléfono',
      directContact: directContact.isNotEmpty ? directContact : 'Sin contacto',
      address: address.isNotEmpty ? address : 'Sin dirección',
    );
  }
}

// ============================================================
// TARJETA PERSONA
// ============================================================

class PersonCard extends StatelessWidget {
  final String title;
  final FaIconData? icon; // <-- Updated type from IconData? to FaIconData?
  final String name;
  final String phone;
  final String directContact;
  final String address;

  const PersonCard({
    super.key,
    required this.title,
    required this.icon,
    required this.name,
    required this.phone,
    required this.directContact,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _C.surfaceDark.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              color: _C.primaryGreenSoft,
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FaIcon(
                      icon,
                      size: 14,
                      color: _C.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .5,
                        color: _C.surfaceDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // INFORMACIÓN
            // ==================================================

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _PersonInfoRow(
                    icon: Icons.business_outlined,
                    label: 'Nombre',
                    value: name,
                  ),
                  const _InfoDivider(),
                  _PersonInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: phone,
                  ),
                  const _InfoDivider(),
                  _PersonInfoRow(
                    icon: Icons.smartphone_outlined,
                    label: 'Contacto directo',
                    value: directContact,
                  ),
                  const _InfoDivider(),
                  _PersonInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Dirección',
                    value: address,
                    multiline: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FILA DE INFORMACIÓN
// ============================================================

class _PersonInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  const _PersonInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _C.primaryGreenSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 17,
            color: _C.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: _C.textSecondary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DIVISOR
// ============================================================

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(
        left: 50,
        top: 12,
        bottom: 12,
      ),
      child: Divider(
        height: 1,
        thickness: .5,
        color: _C.border,
      ),
    );
  }
}
