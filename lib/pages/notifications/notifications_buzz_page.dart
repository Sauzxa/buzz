import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_navigation_service.dart';
import '../../Widgets/notification_card.dart';

class NotificationsBuzzPage extends StatefulWidget {
  const NotificationsBuzzPage({super.key});

  @override
  State<NotificationsBuzzPage> createState() => _NotificationsBuzzPageState();
}

class _NotificationsBuzzPageState extends State<NotificationsBuzzPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Delay fetching until after first frame to ensure providers are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadNotifications() async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    await notificationProvider.fetchNotifications(isRead: null);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  void _loadMore() async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    if (!notificationProvider.hasMore || notificationProvider.isLoading) {
      return;
    }

    setState(() => _isLoadingMore = true);

    await notificationProvider.fetchNotifications(isRead: null, loadMore: true);

    setState(() => _isLoadingMore = false);
  }

  Future<void> _handleRefresh() async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    await notificationProvider.refreshNotifications();
  }

  void _handleNotificationTap(int notificationId, bool isRead) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    final notification = notificationProvider.notifications.firstWhere(
      (n) => n.id == notificationId,
    );

    // Mark as read if unread
    if (!isRead) {
      final userId = authProvider.user?.id;
      if (userId != null) {
        await notificationProvider.markAsRead(
          notificationId,
          userId.toString(),
        );
      }
    }

    // Navigate based on notification type
    if (mounted) {
      final navigationService = NotificationNavigationService();
      navigationService.handleNotificationNavigation(
        context,
        notification.notificationType,
        notification.referenceId,
      );

      // Go back after navigation
      Navigator.pop(context);
    }
  }

  void _handleNotificationDelete(int notificationId) async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    try {
      await notificationProvider.deleteNotification(notificationId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notification supprimée',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la suppression',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.roseColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              'Notifications',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${provider.unreadCount}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.roseColor,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return _buildLoadingState();
          }

          if (provider.error != null && provider.notifications.isEmpty) {
            return _buildErrorState(provider.error!);
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.roseColor,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount:
                  provider.notifications.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.notifications.length) {
                  return _buildLoadingMoreIndicator();
                }

                final notification = provider.notifications[index];
                return NotificationCard(
                  notification: notification,
                  onTap: () => _handleNotificationTap(
                    notification.id,
                    notification.isRead,
                  ),
                  onDelete: () => _handleNotificationDelete(notification.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.roseColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement...',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium!.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.roseColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Réessayer',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune notification',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Vous serez notifié quand un agent devient\ndisponible',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.roseColor),
        ),
      ),
    );
  }
}
