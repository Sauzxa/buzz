import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'Supprimer la notification',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
            ),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer cette notification ?',
              style: GoogleFonts.dmSans(
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Annuler',
                  style: GoogleFonts.dmSans(
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Supprimer',
                  style: GoogleFonts.dmSans(
                    color: AppColors.roseColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: notification.isRead
                    ? Colors.transparent
                    : AppColors.roseColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: notification.isRead
                    ? null
                    : Border.all(
                        color: AppColors.roseColor.withOpacity(0.3),
                        width: 1,
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Icon or Image
                  _buildNotificationIcon(),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleLarge!.color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(notification.createdAt),
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.message,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Unread indicator dot
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6, left: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.roseColor,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.roseColor.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Builder(
      builder: (context) {
        // If notification has a base64 image, decode and display it
        if (notification.notificationImage != null &&
            notification.notificationImage!.isNotEmpty) {
          try {
            // Remove data URI prefix if present
            String base64String = notification.notificationImage!;
            if (base64String.contains(',')) {
              base64String = base64String.split(',').last;
            }

            final bytes = base64Decode(base64String);

            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image fails to load
                    return _buildDefaultIcon(context);
                  },
                ),
              ),
            );
          } catch (e) {
            print('Error decoding notification image: $e');
            // Fallback to icon if decoding fails
            return _buildDefaultIcon(context);
          }
        }

        // Default icon display
        return _buildDefaultIcon(context);
      },
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(_getNotificationIcon(), color: _getIconColor(), size: 20),
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.notificationType) {
      case NotificationType.ORDER_CREATED:
      case NotificationType.ORDER_PRICED:
      case NotificationType.ORDER_COMPLETED:
      case NotificationType.ORDER_CANCELED:
        return Icons.shopping_bag_outlined;
      case NotificationType.CHAT:
        return Icons.message_outlined;
      case NotificationType.NEWS:
        return Icons.article_outlined;
      case NotificationType.DISCOUNT:
        return Icons.local_offer_outlined;
      case NotificationType.PAYMENT_PROOF_UPLOADED:
      case NotificationType.PAYMENT_PROOF_VALIDATED:
      case NotificationType.PAYMENT_PROOF_REJECTED:
        return Icons.payment_outlined;
      case NotificationType.INVOICE_UPDATED:
        return Icons.receipt_long_outlined;
      case NotificationType.ASSIGNE_DESIGNER:
        return Icons.person_add_outlined;
    }
  }

  Color _getIconColor() {
    switch (notification.notificationType) {
      case NotificationType.ORDER_CREATED:
      case NotificationType.ORDER_PRICED:
        return AppColors.roseColor;
      case NotificationType.ORDER_COMPLETED:
        return Colors.green;
      case NotificationType.ORDER_CANCELED:
      case NotificationType.PAYMENT_PROOF_REJECTED:
        return Colors.red;
      case NotificationType.CHAT:
        return Colors.blue;
      case NotificationType.NEWS:
        return Colors.orange;
      case NotificationType.DISCOUNT:
        return Colors.purple;
      case NotificationType.PAYMENT_PROOF_UPLOADED:
      case NotificationType.PAYMENT_PROOF_VALIDATED:
        return Colors.teal;
      case NotificationType.INVOICE_UPDATED:
        return Colors.indigo;
      case NotificationType.ASSIGNE_DESIGNER:
        return Colors.cyan;
    }
  }

  Color _getIconBackgroundColor() {
    return _getIconColor().withOpacity(0.1);
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return "À l'instant";
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
    }
  }
}
