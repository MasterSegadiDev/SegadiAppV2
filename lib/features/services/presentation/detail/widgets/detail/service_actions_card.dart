import 'package:flutter/material.dart';

import 'package:segadi/features/services/domain/entities/support_status_current_entity.dart';
import 'package:segadi/features/services/presentation/list/arguments/service_action_item.dart';
import 'package:segadi/features/services/presentation/detail/widgets/support_status/active_status_support.dart';

class ServiceActionsCard extends StatelessWidget {
  final List<ServiceActionItem> actions;
  final SupportStatusCurrentEntity? supportStatus;
  final Function(ServiceActionItem action)? onActionTap;
  final Future<bool> Function(
    SupportStatusCurrentEntity supportStatus,
  )? onFinishSupport;

  const ServiceActionsCard({
    super.key,
    required this.actions,
    this.supportStatus,
    this.onActionTap,
    this.onFinishSupport,
  });

  static const double _spacing = 10;

  @override
  Widget build(BuildContext context) {
    final bool hasActiveSupport = supportStatus?.active == true;

    final visibleActions = actions.where((action) => action.show).toList();

    if (!hasActiveSupport && visibleActions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: Text(
            'ACCIONES DEL SERVICIO',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (hasActiveSupport)
          ActiveSupportStatus(
            supportStatus: supportStatus!,
            onFinishSupport: () {
              return onFinishSupport?.call(supportStatus!) ??
                  Future<bool>.value(false);
            },
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _buildActionsGrid(visibleActions),
          ),
      ],
    );
  }

  /// Acomoda las acciones en 2 columnas. Si el total es impar, la última
  /// acción ocupa todo el ancho (formato horizontal), así nunca quedan huecos.
  Widget _buildActionsGrid(List<ServiceActionItem> items) {
    final rows = <Widget>[];

    for (var i = 0; i < items.length; i += 2) {
      final bool isLastAlone = i + 1 >= items.length;

      if (rows.isNotEmpty) {
        rows.add(const SizedBox(height: _spacing));
      }

      if (isLastAlone) {
        rows.add(
          SizedBox(
            height: 56,
            child: _ActionButton(
              item: items[i],
              wide: true,
              onTap: () => _handleTap(items[i]),
            ),
          ),
        );
      } else {
        rows.add(
          SizedBox(
            height: 92,
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    item: items[i],
                    onTap: () => _handleTap(items[i]),
                  ),
                ),
                const SizedBox(width: _spacing),
                Expanded(
                  child: _ActionButton(
                    item: items[i + 1],
                    onTap: () => _handleTap(items[i + 1]),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Column(children: rows);
  }

  void _handleTap(ServiceActionItem item) {
    if (item.enabled) {
      onActionTap?.call(item);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final ServiceActionItem item;
  final VoidCallback onTap;
  final bool wide;

  const _ActionButton({
    required this.item,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color contentColor =
        item.enabled ? Theme.of(context).colorScheme.primary : Colors.grey;

    final icon = Icon(
      item.icon,
      size: wide ? 24 : 28,
      color: contentColor,
    );

    final label = Text(
      item.title,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: wide ? 13 : 12,
        fontWeight: FontWeight.w600,
        color: item.enabled ? null : Colors.grey,
      ),
    );

    return Material(
      color: item.enabled
          ? Theme.of(context).cardColor
          : Colors.grey.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: item.enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          child: wide
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 10),
                    Flexible(child: label),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(height: 8),
                    label,
                  ],
                ),
        ),
      ),
    );
  }
}
