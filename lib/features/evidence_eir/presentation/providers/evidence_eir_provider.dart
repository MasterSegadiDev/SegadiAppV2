import 'package:flutter_riverpod/legacy.dart';
import 'package:segadi/features/evidence_eir/presentation/viewmodels/delivery_evidecen_eir_view_model.dart';

import 'package:segadi/app/di/injection_container.dart';

final deliveryEvidenceEirViewModelProvider =
    ChangeNotifierProvider<DeliveryEvidenceEirViewModel>((ref) {
  return getIt<DeliveryEvidenceEirViewModel>();
});
