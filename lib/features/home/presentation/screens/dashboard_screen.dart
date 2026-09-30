import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/permission_codes.dart';
import '../../../../core/security/providers/permission_service_provider.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';

/// Contenido de la pantalla Home. Se monta directo dentro de MainLayout
/// (que ya pone su propio Scaffold/AppBar/Drawer) — no debe traer los suyos.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  ConsumerState<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final permissionService = ref.watch(permissionServiceProvider);

    if (user == null) {
      return const Center(
        child: Text('Usuario no encontrado'),
      );
    }

    final items = _buildDashboardItems(permissionService);

    return Container(
      color: const Color(0xFFF7F8F6),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${user.name}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B6B66)),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '¿Qué necesitas hacer hoy?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF101812),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          'No tienes módulos asignados',
                          style: TextStyle(color: Color(0xFF9A9A94)),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _DashboardCard(item: items[index]);
                        },
                      ),
              ),
            ],
          ),
          // FAB manual: al no tener Scaffold propio, no hay slot
          // floatingActionButton, así que se posiciona con Stack.
          Positioned(
            right: 18,
            bottom: 22,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF101812),
              onPressed: () {
                // TODO: acción de llamada a soporte/emergencia
              },
              child: const Icon(Icons.call, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Un módulo por cada card visible. Se agrega solo si el usuario
  /// tiene el permiso correspondiente — así el mapeo real de
  /// rol → permisos vive en el backend / permissionService, no aquí.
  List<_DashboardItem> _buildDashboardItems(dynamic permissionService) {
    final items = <_DashboardItem>[];

    // rol: operador
    if (permissionService.hasPermission(PermissionCodes.viewServices)) {
      items.add(
        const _DashboardItem(
          title: 'Servicio',
          subtitle: 'Asignados',
          icon: Icons.local_shipping_outlined,
          route: '/services',
        ),
      );
    }

    // rol: operador
    if (permissionService.hasPermission(PermissionCodes.viewContainers)) {
      items.add(
        const _DashboardItem(
          title: 'Expediente',
          subtitle: 'Documentos',
          icon: Icons.folder_outlined,
          route: '/containers',
        ),
      );
    }

    // rol: operador_grua
    // TODO: agrega este código en tu PermissionCodes si aún no existe.
    if (permissionService.hasPermission(
      PermissionCodes.viewContainers,
    )) {
      items.add(
        const _DashboardItem(
          title: 'Movimiento de\ncontenedores',
          subtitle: 'Grúa',
          icon: Icons.swap_horiz_rounded,
          route: '/containers/movements',
        ),
      );
    }

    // rol: guardia_seguridad, mecanico
    if (permissionService.hasPermission(PermissionCodes.viewMaintenance)) {
      items.add(
        const _DashboardItem(
          title: 'Mantenimiento',
          subtitle: 'Al día',
          icon: Icons.build_outlined,
          route: '/maintenance',
        ),
      );
    }

    return items;
  }
}

class _DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final int? badgeCount;

  const _DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    this.badgeCount,
  });
}

class _DashboardCard extends StatelessWidget {
  final _DashboardItem item;

  const _DashboardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go(item.route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101812).withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F0E3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    size: 21,
                    color: const Color(0xFF1E7A3C),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101812),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF9A9A94)),
                ),
              ],
            ),
            if (item.badgeCount != null && item.badgeCount! > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E7A3C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${item.badgeCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
