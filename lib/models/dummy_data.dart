import 'package:laundrymobile/models/laundry_package.dart';

final List<LaundryPackage> dummyData = [
  LaundryPackage(
    id: 1,
    name: 'Cuci Kering',
    description: 'Pakaian dicuci dan dikeringkan tanpa di setrika',
    price: 6000,
  ),
  LaundryPackage(
    id: 2,
    name: 'Cuci Setrika',
    description: 'Pakaian dicuci, dikeringkan dan di setrika rapi',
    price: 9000,
  ),
  LaundryPackage(
    id: 3,
    name: 'Cuci Ekspress',
    description: 'Selesai dalam 4 jam',
    price: 12000,
  ),
  LaundryPackage(
    id: 4,
    name: 'Cuci Selimut/Bed Cover',
    description: 'Cuci khusus untuk bahan tebal seperti selimut dll',
    price: 15000,
  ),
  LaundryPackage(
    id: 5,
    name: 'Dry Cleaning',
    description: 'Cuci uap tanpa air untuk bahan kain sensitif',
    price: 6000,
  ),
];
