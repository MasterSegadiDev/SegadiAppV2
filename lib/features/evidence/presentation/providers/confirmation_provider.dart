import 'package:flutter_riverpod/legacy.dart';
import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/features/evidence/presentation/viewmodels/delivery_confirmation_view_model.dart';

final deliveryConfirmationViewModelProvider =
    ChangeNotifierProvider<DeliveryConfirmationViewModel>((ref) {
  return getIt<DeliveryConfirmationViewModel>();
});
