class UpdateMandatoryStatusParams {
  final String referralId;
  final String serviceRequestId;
  final String statusId;

  const UpdateMandatoryStatusParams({
    required this.referralId,
    required this.serviceRequestId,
    required this.statusId,
  });
}
