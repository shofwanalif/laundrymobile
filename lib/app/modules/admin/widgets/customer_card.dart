import 'package:flutter/material.dart';

class CustomerCard extends StatelessWidget {
  final String customerName;
  final String? phoneNumber;
  final String totalSpend;
  final int totalOrders;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  const CustomerCard({
    super.key,
    required this.customerName,
    this.phoneNumber,
    required this.totalSpend,
    required this.totalOrders,
    this.onTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            // Header: Avatar, Name, Phone, Menu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue,
                    child: Text(
                      customerName.isNotEmpty
                          ? customerName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & Phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phoneNumber?.isNotEmpty == true
                              ? phoneNumber!
                              : 'No phone number',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu Button
                  if (onMenuTap != null)
                    GestureDetector(
                      onTap: onMenuTap,
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey[500],
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),

            // Divider
            Divider(
              height: 1,
              thickness: 0.5,
              color: isDark ? Colors.grey[700] : Colors.grey[200],
            ),

            // Stats: Total Spend & Total Orders
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Total Spend
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.payments_outlined,
                      label: 'Total Spend',
                      value: totalSpend,
                      color: Colors.green,
                      isDark: isDark,
                    ),
                  ),

                  // Separator
                  Container(
                    width: 1,
                    height: 40,
                    color: isDark ? Colors.grey[700] : Colors.grey[200],
                  ),

                  // Total Orders
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Total Orders',
                      value: '$totalOrders',
                      color: Colors.blue,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
