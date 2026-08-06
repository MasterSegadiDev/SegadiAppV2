import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:segadi/core/network/api_exceptions.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/features/check_list/data/datasources/checklist_remote_dataosurce.dart';
import 'package:segadi/features/check_list/data/repositories/checklist_repository_impl.dart';
import 'package:segadi/features/check_list/presentation/pages/checklist_page.dart';
import 'package:segadi/features/check_list/presentation/viewmodels/checklist_viewmodel.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_permissions.dart';
import 'package:segadi/features/service_detail/presentation/viewmodel/detail_service_viewmodel.dart';
import 'package:segadi/features/support_status/data/api/support_status_api.dart';
import 'package:segadi/features/support_status/data/repositories/support_status_repository_impl.dart';
import 'package:segadi/features/support_status/presentation/ui/status_support_view.dart';
import 'package:segadi/features/support_status/presentation/viewmodel/support_status_viewmodel.dart';
import 'package:segadi/features/trip_closure/presentation/pages/capture_trip_evidence_page.dart';

import 'package:segadi/features/trip_closure/presentation/viewmodels/trip_closure_viewmodel.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class ActionsCard extends StatelessWidget {
  final DetailServiceEntity ui;
  final VoidCallback onRefresh;

  const ActionsCard({
    super.key,
    required this.ui,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final state = ui;
    final rules = DetailServicePermissions(ui);

    debugPrint('activar boton de subir EIR? ${rules.canShowEIR}');

    // Definimos la lista de acciones dinámicamente para el Grid
    final List<Widget> actions = [
      ActionButton(
        icon: FontAwesomeIcons.clipboard.data,
        label: 'Chequeo',
        color: Colors.blue,
        enabled: state.ui.enableCheckList,
        onPressed: null,
        // onPressed: () async {
        //   // 1. Instanciamos dependencias

        //   final remoteDS = ChecklistRemoteDataSource();

        //   // Agregamos Connectivity() aquí para que NetworkInfo pueda trabajar
        //   final networkInfo = NetworkInfoImpl(Connectivity());

        //   final ok = await showModalBottomSheet<bool>(
        //     context: context,
        //     isScrollControlled: true,
        //     backgroundColor: Colors.transparent,
        //     builder: (context) => ChangeNotifierProvider(
        //       create: (_) => ChecklistViewModel(
        //         repo: ChecklistRepositoryImpl(
        //           remoteDataSource: remoteDS,
        //           networkInfo: networkInfo,
        //         ),
        //         serviceId: state.id,
        //       ),
        //       child: const _ChecklistModal(),
        //     ),
        //   );

        //   if (ok == true) {
        //     if (context.mounted) {
        //       context.read<DetailServiceViewModel>().loadDetail(state.id);
        //     }
        //   }
        // },
      ),
      ActionButton(
        icon: FontAwesomeIcons.locationDot.data,
        label: 'Soporte',
        color: Colors.red,
        enabled: state.ui.enableSupport,
        onPressed: () async {
          final updated = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black54,
            builder: (_) => ChangeNotifierProvider(
              create: (_) => SupportStatusViewModel(
                repo: SupportStatusRepositoryImpl(
                  SupportStatusApi(), // <--- AQUÍ PASAS EL DIO
                ),
                serviceId: state.id,
                statusId: state.statusId,
                type: state.type,
              ),
              child: const StatusSupportView(),
            ),
          );

          if (updated == true && context.mounted) {
            context.read<DetailServiceViewModel>().loadDetail(state.id);
          }
        },
      ),
      ActionButton(
        icon: FontAwesomeIcons.mapLocation.data,
        label: 'Geocerca',
        color: Colors.grey,
        enabled: false,
        onPressed: null,
      ),
      if (ui.serviceType == 'contenedor')
        Consumer<TripClosureViewModel>(
          builder: (context, tripVm, child) {
            return ActionButton(
              icon: FontAwesomeIcons.circleCheck.data,
              label: 'Subir EIR',
              color: Colors.green,
              enabled: rules.canShowEIR,
              onPressed: rules.canShowEIR
                  ? () async {
                      tripVm.startNewTripClosure(ui.id, ui.service);

                      // 2. Navegamos
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CaptureTripEvidencePage()),
                      );

                      if (result == true && context.mounted) {
                        print(
                            'Usuario regresó de evidencias. Forzando recarga de seguridad...');

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              // Quitamos el const de aquí porque Expanded no lo es
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.white),
                                const SizedBox(width: 12),
                                // 🔥 Usamos Expanded para evitar la franja amarilla/negra
                                const Expanded(
                                  child: Text(
                                    'EIR enviado correctamente. Tu Remisión sera finalizada ...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green[700],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        context
                            .read<DetailServiceViewModel>()
                            .loadDetail(state.id);
                      }
                    }
                  : null,
            );
          },
        ),
      ActionButton(
        icon: FontAwesomeIcons.moneyBillTransfer.data,
        label: 'Viáticos',
        color: Colors.teal,
        enabled: state.ui.hasMoneyChecks,
        onPressed: rules.canShowViaticos
            ? () {
                Navigator.pushNamed(context, '/travel_expenses',
                    arguments: state.id);
              }
            : null,
      ),
      ActionButton(
        icon: FontAwesomeIcons.solidFilePdf.data,
        label: 'Descargar CCP',
        color: Colors.red,
        enabled: true,
        onPressed: () async {
          try {
            // 1. Pedir permisos
            await [Permission.storage, Permission.notification].request();

            final dioClient = context.read<DioClient>();
            // final res = await PdfService(dioClient.dio).getPdf(state.id);
            final res = 'xyz';

            if (res != null) {
              // 2. Nombre de archivo seguro
              String safeName = "CFDI_Remision_${state.service}"
                  .replaceAll(RegExp(r'[^\w\s]+'), '_')
                  .replaceAll(' ', '_');

              if (!safeName.toLowerCase().endsWith('.pdf')) {
                safeName += '.pdf';
              }

              // 3. Descarga silenciosa (Sin spam en consola)
              await FileDownloader.downloadFile(
                url: res,
                name: safeName,
                notificationType: NotificationType.all,
                // Dejamos los callbacks vacíos o con logs mínimos
                // para que la librería no use sus logs por defecto
                onProgress: null,
                onDownloadCompleted: (String path) {
                  // Solo imprimimos una vez al finalizar
                  debugPrint('✅ Descarga completada: $path');
                },
                onDownloadError: (String error) {
                  debugPrint('❌ Error en descarga: $error');
                },
              );
            }
          } on ApiException catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message), backgroundColor: Colors.red),
            );
          } catch (e) {
            // Usar debugPrint en lugar de print es mejor práctica en Flutter
            debugPrint("Error detalle: $e");
          }
        },
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Si la pantalla es muy pequeña, usamos 3 columnas pero con escala menor
          // Si es mediana/grande, 3 columnas cómodas.
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio:
                0.9, // Ajusta esto para dar más/menos aire vertical
            children: actions,
          );
        },
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback? onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adaptamos el tamaño del icono al ancho disponible del slot del grid
        final double availableWidth = constraints.maxWidth;
        final double iconSize = (availableWidth * 0.35).clamp(24.0, 32.0);
        final double fontSize = (availableWidth * 0.18).clamp(10.0, 12.0);

        return Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: enabled
                        ? color.withOpacity(0.12)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    icon as FaIconData?,
                    size: iconSize,
                    color: enabled ? color : Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChecklistModal extends StatelessWidget {
  const _ChecklistModal();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Lista de chequeo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            // const Expanded(
            //   child: CheckListView(),
            // ),
          ],
        ),
      ),
    );
  }
}
