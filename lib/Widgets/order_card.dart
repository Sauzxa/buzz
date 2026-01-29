import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  final VoidCallback? onUploadReceipt;
  final Function(DismissDirection)? onDismissed;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
    this.onUploadReceipt,
    this.onDismissed,
    this.confirmDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = order['status'] ?? 'PENDING';
    final bool canUpload =
        status == 'PRICED' ||
        status == 'AWAITING_PAYMENT_VALIDATION' ||
        status == 'COMPLETED';
    final bool canCancel = status == 'PENDING' || status == 'PRICED';
    final Color categoryColor = _getCategoryColor(
      order['serviceCategory'] ?? '',
    );

    final cardWidget = Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category Badge + Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (order['serviceCategory'] ?? 'Service')
                          .toString()
                          .toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(order['createdAt']),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Order Number & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['title'] ??
                              'COMMANDE N ${_getOrderNumber(order['orderNumber'])}',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (order['serviceName'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            order['serviceName'],
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (order['totalPrice'] != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '${order['totalPrice']} DA',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Sub-info (RDV / Deadline)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deadline',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _formatDate(order['deadline']),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  // Details Button
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.roseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Details',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Upload Receipt Button (Only if applicable)
                  if (canUpload && onUploadReceipt != null)
                    Expanded(
                      child: GestureDetector(
                        onTap: onUploadReceipt,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.roseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'upload ur payment reciept',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Only allow dismissing for PENDING and PRICED orders
    if (canCancel && onDismissed != null) {
      return Dismissible(
        key: ValueKey('order_${order['id']}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: confirmDismiss,
        onDismissed: onDismissed,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: cardWidget,
      );
    }

    return cardWidget;
  }

  Color _getCategoryColor(String? category) {
    if (category == null) return AppColors.greenColor;
    final cat = category.toLowerCase();
    if (cat.contains('graphic')) return AppColors.GraphicDesing;
    if (cat.contains('print')) return AppColors.Printing;
    if (cat.contains('audio')) return AppColors.AudioVisual;
    return AppColors.greenColor;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '--/--/----';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateStr; // Return as is if parsing fails
    }
  }

  String _getOrderNumber(String? fullNumber) {
    // ORD-2025-000042 -> 42
    if (fullNumber == null) return '';
    try {
      final parts = fullNumber.split('-');
      if (parts.isNotEmpty) {
        return int.parse(parts.last).toString();
      }
    } catch (_) {}
    return fullNumber;
  }
}
