import '../../domain/entities/delivery_confirmation.dart';

class DeliveryConfirmationModel extends DeliveryConfirmation {
  const DeliveryConfirmationModel({
    required super.serviceRequestId,
    required super.fileSignature,
    required super.strDateTime,
    required super.strReceiverName,
  });

  factory DeliveryConfirmationModel.fromEntity(
    DeliveryConfirmation entity,
  ) {
    return DeliveryConfirmationModel(
      serviceRequestId: entity.serviceRequestId,
      fileSignature: entity.fileSignature,
      strDateTime: entity.strDateTime,
      strReceiverName: entity.strReceiverName,
    );
  }
}
