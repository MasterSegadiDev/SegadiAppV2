import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:segadi/features/services/presentation/models/service_action_item.dart';

class ServiceActionsCard extends StatelessWidget {
  final List<ServiceActionItem> actions;

  const ServiceActionsCard({
    super.key,
    required this.actions,
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
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions
                  .where(
                    (e) => e.enabled,
                  )
                  .length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: .95,
              ),
              itemBuilder: (context, index) {
                final item = actions
                    .where(
                      (e) => e.enabled,
                    )
                    .toList()[index];

                return _ActionButton(
                  icon: item.icon,
                  title: item.title,
                  onTap: item.onTap,
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
                icon,
                color: const Color(0xFF2C522A),
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
