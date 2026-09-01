import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/features/georuta/presentation/providers/georoute_provider.dart';
import 'package:segadi/features/georuta/presentation/widgets/georoute_map.dart';

class GeoroutePage extends ConsumerStatefulWidget {
  final String serviceRequestId;

  const GeoroutePage({
    super.key,
    required this.serviceRequestId,
  });

  @override
  ConsumerState<GeoroutePage> createState() => _GeoroutePageState();
}

class _GeoroutePageState extends ConsumerState<GeoroutePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(georouteViewModelProvider.notifier).loadGeoroute(
            widget.serviceRequestId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(georouteViewModelProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ruta'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.error!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final georoute = state.georoute;

    if (georoute == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No se encontró información de la ruta.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          georoute.route.name,
        ),
      ),
      body: GeorouteMap(
        georoute: georoute,
        currentLocation: state.currentLocation,
        isOffRoute: state.isOffRoute,
      ),
    );
  }
}
