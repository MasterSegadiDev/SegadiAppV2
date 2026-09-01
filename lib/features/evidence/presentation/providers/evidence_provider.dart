import 'package:flutter_riverpod/legacy.dart';
import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/features/evidence/presentation/viewmodels/delivery_evidence_view_model.dart';

final deliveryEvidenceViewModelProvider =
    ChangeNotifierProvider<DeliveryEvidenceViewModel>((ref) {
  return getIt<DeliveryEvidenceViewModel>();
});
