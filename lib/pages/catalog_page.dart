import 'package:flutter/material.dart';
import '../models/dummy_data.dart';
import '../widgets/package_card.dart';
import 'additional_page.dart'; 

class PackageCatalogPage extends StatelessWidget {
  const PackageCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double globalPadding = screenWidth < 600 ? 12.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Paket Laundry'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
                return GestureDetector(
                  onTap: () {},
                  child: Hero(
                    tag: 'package_${dummyData[index].id}',
                    child: PackageCard(package: dummyData[index]),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman lain dengan scale transition
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AdditionalPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = 0.0;
                    const end = 1.0;
                    const curve = Curves.elasticOut;

                    var scaleTween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    var scaleAnimation = animation.drive(scaleTween);

                    return ScaleTransition(scale: scaleAnimation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
