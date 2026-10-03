import 'package:flutter/material.dart';

import 'package:segadi/features/services/domain/entities/support_status_current_entity.dart';
import 'package:segadi/features/services/presentation/list/arguments/service_action_item.dart';
import 'package:segadi/features/services/presentation/detail/widgets/support_status/active_status_support.dart';

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
// ACCIONES DEL SERVICIO
// ============================================================

class ServiceActionsCard extends StatelessWidget {
  final List<ServiceActionItem> actions;
  final SupportStatusCurrentEntity? supportStatus;
  final Function(ServiceActionItem action)? onActionTap;

  const ServiceActionsCard({
    super.key,
    required this.actions,
    this.supportStatus,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleActions = actions
        .where(
          (action) => action.show,
        )
        .toList();

    if (visibleActions.isEmpty && supportStatus == null) {
      return const SizedBox.shrink();
    }

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              color: _C.primaryGreenSoft,
              child: const Row(
                children: [
                  Icon(
                    Icons.dashboard_customize_outlined,
                    size: 18,
                    color: _C.primaryGreen,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ACCIONES DEL SERVICIO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _C.surfaceDark,
                        fontSize: 13,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // SOPORTE ACTIVO
            // ==================================================

            if (supportStatus?.active == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  0,
                ),
                child: ActiveSupportStatus(
                  supportStatus: supportStatus!,
                ),
              ),

            // ==================================================
            // ACCIONES
            // ==================================================

            if (visibleActions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleActions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: .88,
                  ),
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final item = visibleActions[index];

                    return _ActionButton(
                      icon: item.icon,
                      title: item.title,
                      enabled: item.enabled,
                      onTap: item.enabled
                          ? () {
                              onActionTap?.call(item);
                            }
                          : null,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BOTÓN DE ACCIÓN
// ============================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool enabled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: _C.primaryGreen.withOpacity(.08),
        highlightColor: _C.primaryGreen.withOpacity(.04),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF7F8F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled ? _C.border : _C.border.withOpacity(.65),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ==================================================
              // ICONO
              // ==================================================

              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      enabled ? _C.primaryGreenSoft : const Color(0xFFEDEDEA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: enabled ? _C.primaryGreen : _C.textMuted,
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // TEXTO
              // ==================================================

              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: enabled ? _C.textPrimary : _C.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
