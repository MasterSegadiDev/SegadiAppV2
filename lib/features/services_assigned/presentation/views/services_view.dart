import 'package:flutter/material.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/service_state.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/services_viewmodel.dart';
import 'package:segadi/features/services_assigned/presentation/widgets/service_card.dart';

Widget buildBody(ServicesViewModel vm) {
  return switch (vm.state) {
    ServicesLoading() => const Center(child: CircularProgressIndicator()),
    ServicesEmpty() => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: Text('No hay servicios disponibles')),
        ],
      ),
    ServicesLoaded(:final items) => ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: items.length,
        itemBuilder: (_, i) => ServiceCard(item: items[i]),
      ),
    ServicesError(:final message) => Center(child: Text(message)),
  };
}
