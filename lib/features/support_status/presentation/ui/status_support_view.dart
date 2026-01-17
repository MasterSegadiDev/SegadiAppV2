import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/support_status/presentation/viewmodel/support_status_viewmodel.dart';

class StatusSupportView extends StatelessWidget {
  const StatusSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SupportStatusViewModel>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selecciona un tipo de apoyo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, i) {
              final opt = vm.options[i];
              final selected = vm.isSelected(opt.id);

              return GestureDetector(
                onTap: vm.loading ? null : () => vm.send(opt.id, context),
                child: Card(
                  elevation: 4,
                  color: vm.cardColor(opt.id),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        opt.icon,
                        size: 48,
                        color: vm.iconColor(opt.id),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        opt.label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selected ? Colors.black : Colors.grey[700],
                        ),
                      ),
                      if (selected)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(Icons.check_circle, color: Colors.green),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: vm.loading ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
