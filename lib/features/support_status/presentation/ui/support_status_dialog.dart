import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/support_status/presentation/viewmodel/support_status_viewmodel.dart';

class SupportStatusDialog extends StatelessWidget {
  const SupportStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SupportStatusViewModel>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Estatus de soporte',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...vm.options.map((opt) {
              return ListTile(
                leading: Icon(opt.icon),
                title: Text(opt.label),
                onTap: vm.loading
                    ? null
                    : () async {
                        await vm.send(opt.id, context);
                      },
              );
            }),
            if (vm.loading)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: CupertinoActivityIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
