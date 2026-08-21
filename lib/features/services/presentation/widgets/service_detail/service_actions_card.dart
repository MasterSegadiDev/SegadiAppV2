import 'package:flutter/material.dart';

import 'package:segadi/features/services/presentation/models/service_action_item.dart';

class ServiceActionsCard extends StatelessWidget {
  final List<ServiceActionItem> actions;
  final Function(ServiceActionItem action)? onActionTap;

  const ServiceActionsCard({
    super.key,
    required this.actions,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleActions = actions.where((action) => action.show).toList();

    if (visibleActions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
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
                SizedBox(
                  width: 10,
                ),
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
            padding: const EdgeInsets.all(
              18,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleActions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: .95,
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
    );
  }
}

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
    final backgroundColor =
        enabled ? Colors.grey.shade50 : Colors.grey.shade100;

    final iconColor = enabled ? const Color(0xFF2C522A) : Colors.grey.shade400;

    final textColor = enabled ? Colors.black87 : Colors.grey.shade500;

    return Material(
      color: backgroundColor,
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
              color: enabled ? Colors.grey.shade200 : Colors.grey.shade300,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
