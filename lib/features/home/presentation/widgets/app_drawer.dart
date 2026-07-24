import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segadi/core/security/providers/permission_service_provider.dart';

import '../../../../core/security/permission_codes.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

import 'drawer_group.dart';
import 'drawer_header.dart';
import 'drawer_menu_item.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionService = ref.watch(permissionServiceProvider);

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          const DrawerHeaderWidget(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    DrawerMenuItem(
                      title: 'Inicio',
                      icon: Icons.home_rounded,
                      onTap: () {
                        context.pop();
                        context.go('/home');
                      },
                    ),
                    DrawerMenuItem(
                      title: 'Perfil',
                      icon: Icons.person_outline,
                      onTap: () {
                        context.pop();
                        context.go('/profile');
                      },
                    ),
                    DrawerMenuItem(
                      title: 'Pruebas servicios',
                      icon: Icons.home_rounded,
                      onTap: () {
                        context.pop();
                        context.go('/screenDevelop');
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Divider(),
                    ),
                    if (permissionService.hasPermission(
                      PermissionCodes.viewServices,
                    ))
                      DrawerGroup(
                        title: 'Servicios',
                        icon: Icons.miscellaneous_services,
                        children: [
                          DrawerMenuItem(
                            title: 'Servicios Asignados',
                            icon: Icons.assignment_outlined,
                            onTap: () {
                              context.pop();
                              context.go('/services');
                            },
                          ),
                          DrawerMenuItem(
                            title: 'Servicios Finalizados',
                            icon: Icons.task_alt,
                            onTap: () {
                              context.pop();
                              context.go('/services/history');
                            },
                          ),
                        ],
                      ),
                    if (permissionService.hasPermission(
                      PermissionCodes.viewContainers,
                    ))
                      DrawerGroup(
                        title: 'Contenedores',
                        icon: Icons.inventory_2_outlined,
                        children: [
                          DrawerMenuItem(
                            title: 'Listado',
                            icon: Icons.list_alt,
                            onTap: () {
                              context.pop();
                              context.go('/containers');
                            },
                          ),
                        ],
                      ),
                    if (permissionService.hasPermission(
                      PermissionCodes.viewTrips,
                    ))
                      DrawerMenuItem(
                        title: 'Viajes',
                        icon: Icons.local_shipping_outlined,
                        onTap: () {
                          context.pop();
                          context.go('/trips');
                        },
                      ),
                    if (permissionService.hasPermission(
                      PermissionCodes.viewExpenses,
                    ))
                      DrawerMenuItem(
                        title: 'Gastos',
                        icon: Icons.payments_outlined,
                        onTap: () {
                          context.pop();
                          context.go('/expenses');
                        },
                      ),
                    if (permissionService.hasPermission(
                      PermissionCodes.viewMaintenance,
                    ))
                      DrawerMenuItem(
                        title: 'Mantenimiento',
                        icon: Icons.build_outlined,
                        onTap: () {
                          context.pop();
                          context.go('/maintenance');
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              25,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();

                if (context.mounted) {
                  context.go('/login');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.red.shade100,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
