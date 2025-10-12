import 'package:flutter/material.dart';
import '../models/dummy_data.dart';
import '../widgets/package_card.dart';

class PackageCatalogPage extends StatelessWidget {
  const PackageCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double globalPadding = screenWidth < 600 ? 12.0 : 24.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Paket Laundry')),
      body: Padding(
        padding: EdgeInsets.all(globalPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount;

            if (constraints.maxWidth < 600) {
              crossAxisCount = 2; // ponsel
            } else if (constraints.maxWidth < 900) {
              crossAxisCount = 3; // tablet kecil
            } else {
              crossAxisCount = 4; // tablet besar / desktop
            }

            return GridView.builder(
              itemCount: dummyData.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return PackageCard(package: dummyData[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
