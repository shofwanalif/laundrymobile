import 'package:laundrymobile/app/data/models/laundry_service.dart';

final List<LaundryService> dummyData = [
  LaundryService(
    id: '1',
    serviceName: 'Cuci Kering',
    description: 'Pakaian dicuci dan dikeringkan tanpa di setrika',
    price: 6000,
  ),
  LaundryService(
    id: '2',
    serviceName: 'Cuci Setrika',
    description: 'Pakaian dicuci, dikeringkan dan di setrika rapi',
    price: 9000,
  ),
  LaundryService(
    id: '3',
    serviceName: 'Cuci Ekspress',
    description: 'Selesai dalam 4 jam',
    price: 12000,
  ),
  LaundryService(
    id: '4',
    serviceName: 'Cuci Selimut/Bed Cover',
    description: 'Cuci khusus untuk bahan tebal seperti selimut dll',
    price: 15000,
  ),
  LaundryService(
    id: '5',
    serviceName: 'Dry Cleaning',
    description: 'Cuci uap tanpa air untuk bahan kain sensitif',
    price: 6000,
  ),
];
