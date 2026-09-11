/// Represents a gazetted Quality Control Order (QCO) under Section 16 of the BIS Act, 2016.
class QcoOrder {
  final String id;
  final String orderName;
  final String gazetteNo;
  final String ministry;
  final String scheme;
  final String enforcementDate;
  final String status;
  final List<String> standards;
  final String msmeConcession;
  final String? statutoryNote;

  const QcoOrder({
    required this.id,
    required this.orderName,
    required this.gazetteNo,
    required this.ministry,
    this.scheme = 'Scheme-I (ISI Mark)',
    required this.enforcementDate,
    this.status = 'ACTIVE',
    required this.standards,
    required this.msmeConcession,
    this.statutoryNote,
  });
}
