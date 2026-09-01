import 'dart:io';

class DeliveryEvidence {
  final String serviceRequestId;
  final File? evidence1;
  final File? evidence2;
  final File? evidence3;
  final File? evidence4;
  final File? evidence5;
  final String notes;
  final String referralId;

  const DeliveryEvidence({
    required this.serviceRequestId,
    this.evidence1,
    this.evidence2,
    this.evidence3,
    this.evidence4,
    this.evidence5,
    required this.notes,
    required this.referralId,
  });
}
