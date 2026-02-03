import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;
  final VoidCallback? onUploadReceipt;
  final Function(DismissDirection)? onDismissed;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;
  final String? paymentDeadline;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
    this.onUploadReceipt,
    this.onDismissed,
    this.confirmDismiss,
    this.paymentDeadline,
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

    final cardWidget = Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
                        color: Theme.of(context).textTheme.titleLarge!.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Status Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(status),
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusLabel(status),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
                              color: Theme.of(
                                context,
                              ).textTheme.titleLarge!.color,
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
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.color,
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
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge!.color,
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
                        color: Theme.of(context).textTheme.titleLarge!.color,
                      ),
                    ),
                    Text(
                      _formatDate(paymentDeadline ?? order['deadline']),
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge!.color,
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'PRICED':
        return Colors.blue;
      case 'AWAITING_PAYMENT_VALIDATION':
        return Colors.purple;
      case 'IN_PROGRESS':
        return Colors.teal;
      case 'COMPLETED':
        return AppColors.greenColor;
      case 'CANCELLED':
        return Colors.red;
      case 'DELIVERED':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'PRICED':
        return Icons.attach_money;
      case 'AWAITING_PAYMENT_VALIDATION':
        return Icons.pending_actions;
      case 'IN_PROGRESS':
        return Icons.work_outline;
      case 'COMPLETED':
        return Icons.check_circle_outline;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      case 'DELIVERED':
        return Icons.local_shipping_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'PRICED':
        return 'Priced';
      case 'AWAITING_PAYMENT_VALIDATION':
        return 'Awaiting Payment';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'DELIVERED':
        return 'Delivered';
      default:
        return status;
    }
  }
}
