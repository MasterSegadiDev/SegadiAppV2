class Service {
  final int id;
  final String service;
  final String client;
  final String loadOrigen;
  final String loadSource;
  final String loadDate;
  final String sourceDate;
  final String documentator;

  const Service(
      {required this.id,
      required this.service,
      required this.client,
      required this.loadOrigen,
      required this.loadSource,
      required this.loadDate,
      required this.sourceDate,
      required this.documentator});
}

final services = [
  new Service(
      id: 1,
      service: 'S36112',
      client: 'DIVERSIDAD GLOBAL',
      loadOrigen: 'Manzanillo',
      loadSource: 'Guadalajara',
      loadDate: '21/09/2023',
      sourceDate: '22/10/2023',
      documentator: 'Itzel Garcia'),
  new Service(
      id: 2,
      service: 'S36113',
      client: 'DIVERSIDAD GLOBAL',
      loadOrigen: 'Manzanillo',
      loadSource: 'Guadalajara',
      loadDate: '21/09/2023',
      sourceDate: '22/10/2023',
      documentator: 'Itzel Garcia'),
  new Service(
      id: 3,
      service: 'S36114',
      client: 'DIVERSIDAD GLOBAL',
      loadOrigen: 'Manzanillo',
      loadSource: 'Guadalajara',
      loadDate: '21/09/2023',
      sourceDate: '22/10/2023',
      documentator: 'Itzel Garcia'),
  new Service(
      id: 4,
      service: 'S36115',
      client: 'DIVERSIDAD GLOBAL',
      loadOrigen: 'Manzanillo',
      loadSource: 'Guadalajara',
      loadDate: '21/09/2023',
      sourceDate: '22/10/2023',
      documentator: 'Itzel Garcia'),
  new Service(
      id: 5,
      service: 'S36116',
      client: 'DIVERSIDAD GLOBAL',
      loadOrigen: 'Manzanillo',
      loadSource: 'Guadalajara',
      loadDate: '21/09/2023',
      sourceDate: '22/10/2023',
      documentator: 'Itzel Garcia'),
];
