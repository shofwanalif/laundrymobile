import 'package:flutter/material.dart';
import '../models/laundry_package.dart';

class PackageCard extends StatefulWidget {
  final LaundryPackage package;

  const PackageCard({super.key, required this.package});

  @override
  State<PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    final bool clicked = _isSelected;
    final Color backgroundColor = clicked
        ? const Color(0xFF1D4ED8) // biru tua saat di klik
        : const Color(0xFFF6F8FF); // abu abu saat normal
    final Color accentColor = clicked ? Colors.white : const Color(0xFF3B82F6);
    final Color textColor = clicked ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: () => setState(() => _isSelected = !_isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon bintang di pojok atas
            Align(
              alignment: Alignment.topLeft,
              child: Icon(Icons.auto_awesome, color: accentColor, size: 26),
            ),
            const SizedBox(height: 16),

            // Nama Paket
            Text(
              widget.package.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),

            // Deskripsi Singkat
            Text(
              widget.package.description,
              style: TextStyle(
                fontSize: 13,
                color: textColor.withOpacity(0.7),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Harga
            Text(
              'Rp ${widget.package.price.toStringAsFixed(0)}/kg',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
