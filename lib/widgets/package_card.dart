import 'package:flutter/material.dart';
import '../models/laundry_package.dart';

class PackageCard extends StatefulWidget {
  final LaundryPackage package;

  const PackageCard({super.key, required this.package});

  @override
  State<PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard>
    with SingleTickerProviderStateMixin {
  bool _isSelected = false;
  AnimationController? _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.package.id == 4 || widget.package.id == 5) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );

      _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.easeInOutBack),
      );

      _controller!.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleSelection() {
    setState(() => _isSelected = !_isSelected);

    if (widget.package.id == 4 || widget.package.id == 5) {
      if (_isSelected) {
        _controller?.forward();
      } else {
        _controller?.reverse();
      }
    }
  }

  Widget _buildControlButtons() {
    if (widget.package.id != 4 && widget.package.id != 5)
      return const SizedBox();

    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _controller?.forward(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: const Text('Start', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () => _controller?.stop(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: const Text('Stop', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () => _controller?.repeat(reverse: true),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: const Text('Repeat', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool clicked = _isSelected;
    final Color backgroundColor = clicked
        ? const Color(0xFF1D4ED8)
        : const Color(0xFFF6F8FF);
    final Color accentColor = clicked ? Colors.white : const Color(0xFF3B82F6);
    final Color textColor = clicked ? Colors.white : Colors.black87;

    final card = _buildAnimatedCard(backgroundColor, accentColor, textColor);

    return Material(
      // ← TAMBAHKAN MATERIAL DI SINI
      color: Colors.transparent, // Penting untuk Hero animation
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 180,
            child: Align(
              alignment: Alignment.center,
              child: ClipRect(
                child: (widget.package.id == 4 || widget.package.id == 5)
                    ? Transform.scale(
                        scale: _scaleAnimation.value,
                        child: GestureDetector(
                          onTap: _toggleSelection,
                          child: card,
                        ),
                      )
                    : GestureDetector(
                        onTap: _toggleSelection,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          child: card,
                        ),
                      ),
              ),
            ),
          ),
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(
    Color backgroundColor,
    Color accentColor,
    Color textColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Icon(Icons.auto_awesome, color: accentColor, size: 24),
          ),
          const SizedBox(height: 12),

          Text(
            widget.package.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          Text(
            widget.package.description,
            style: TextStyle(
              fontSize: 13,
              color: textColor.withValues(alpha: 0.7),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),

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
    );
  }
}
