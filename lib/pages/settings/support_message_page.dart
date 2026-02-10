import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/colors.dart';
import '../../services/bug_report_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/chat/message_input_field.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../Widgets/notification_popup.dart';
import '../../Widgets/notification_badge.dart'; // Assuming this exists based on homePage usage
import '../../routes/route_names.dart';
import '../../l10n/app_localizations.dart';

class SupportMessagePage extends StatefulWidget {
  final String messageType;

  const SupportMessagePage({super.key, this.messageType = 'BUG_REPORT'});

  @override
  State<SupportMessagePage> createState() => _SupportMessagePageState();
}

class _SupportMessagePageState extends State<SupportMessagePage> {
  final BugReportService _bugReportService = BugReportService();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _sentMessages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, RouteNames.search);
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, RouteNames.orderManagement);
    } else if (index == 3) {
      // Already in settings section context
      Navigator.pushReplacementNamed(context, RouteNames.settings);
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, RouteNames.chat);
    }
  }

  void _showNotificationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationBottomSheet(),
    );
  }

  Future<void> _submitReport(String message, {String? filePath}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    // Add message to list immediately (optimistic update)
    setState(() {
      _sentMessages.add({
        'text': message,
        'timestamp': DateTime.now(),
        'isPending': true,
        'isFailed': false,
      });
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Basic platform info since we can't use package_info/device_info packages
      String platform = 'Unknown';
      try {
        if (Platform.isAndroid) platform = 'Android';
        if (Platform.isIOS) platform = 'iOS';
      } catch (_) {}

      await _bugReportService.submitBugReport(
        user: user,
        messageType: widget.messageType,
        title:
            "${_getPageTitle()} from mobile app", // Default title as we only have message input
        description: message,
        platform: platform,
        appVersion: "1.0.0", // Hardcoded as we don't have package_info_plus
        deviceModel: "Unknown", // Placeholder
        filePath: filePath,
      );

      if (mounted) {
        // Update the message status to success
        setState(() {
          _sentMessages.last['isPending'] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                    context,
                  )?.translate('support_report_success') ??
                  'Report submitted successfully',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Mark message as failed
        setState(() {
          _sentMessages.last['isPending'] = false;
          _sentMessages.last['isFailed'] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                    context,
                  )?.translate('support_report_failed') ??
                  'Failed to submit report',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getPageTitle() {
    return widget.messageType == 'SUPPORT'
        ? (AppLocalizations.of(context)?.translate('settings_send_feedback') ??
              'Send Feedback')
        : (AppLocalizations.of(context)?.translate('settings_report_bug') ??
              'Report a Bug');
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.roseColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.messageType == 'SUPPORT'
                    ? Icons.feedback_outlined
                    : Icons.bug_report_outlined,
                size: 60,
                color: AppColors.roseColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getPageTitle(),
              style: GoogleFonts.dmSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.messageType == 'SUPPORT'
                  ? (AppLocalizations.of(
                          context,
                        )?.translate('support_feedback_desc') ??
                        'We would love to hear your thoughts, suggestions, or concerns.')
                  : (AppLocalizations.of(
                          context,
                        )?.translate('support_bug_desc') ??
                        'Describe the issue you\'re facing and we\'ll get back to you as soon as possible.'),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium!.color,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isPending = message['isPending'] as bool;
    final isFailed = message['isFailed'] as bool;
    final text = message['text'] as String;
    final timestamp = message['timestamp'] as DateTime;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFailed
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.roseColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
                border: isFailed
                    ? Border.all(color: Colors.red, width: 1)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: isFailed ? Colors.red[900] : Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(timestamp),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: isFailed
                              ? Colors.red[700]
                              : Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (isPending)
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isFailed
                                  ? Colors.red
                                  : Colors.white.withOpacity(0.8),
                            ),
                          ),
                        )
                      else if (isFailed)
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: Colors.red[700],
                        )
                      else
                        Icon(
                          Icons.done,
                          size: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (isFailed)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  AppLocalizations.of(context)?.translate('failed_to_send') ??
                      'Failed to send',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.red[700],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return AppLocalizations.of(context)?.translate('just_now') ?? 'Just now';
    } else if (difference.inMinutes < 60) {
      return (AppLocalizations.of(context)?.translate('time_m_ago') ??
              '{time}m ago')
          .replaceAll('{time}', difference.inMinutes.toString());
    } else if (difference.inHours < 24) {
      return (AppLocalizations.of(context)?.translate('time_h_ago') ??
              '{time}h ago')
          .replaceAll('{time}', difference.inHours.toString());
    } else {
      return (AppLocalizations.of(context)?.translate('time_d_ago') ??
              '{time}d ago')
          .replaceAll('{time}', difference.inDays.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.roseColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/Logos/WhiteLogo.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) => Icon(
                widget.messageType == 'SUPPORT'
                    ? Icons.feedback
                    : Icons.bug_report,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.messageType == 'SUPPORT'
                  ? (AppLocalizations.of(context)?.translate('buzz_feedback') ??
                        'Buzz Feedback')
                  : (AppLocalizations.of(context)?.translate('buzz_support') ??
                        'Buzz Support'),
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          NotificationIconWithBadge(
            onPressed: _showNotificationBottomSheet,
            iconColor: Colors.white,
            iconSize: 28,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Column(
            children: [
              // Messages list
              Expanded(
                child: _sentMessages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _sentMessages.length,
                        itemBuilder: (context, index) {
                          final message = _sentMessages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
              ),

              // Message Input Area
              MessageInputField(
                onSendMessage: (text) => _submitReport(text),
                onSendFile: (path, type) =>
                    _submitReport("File Attachment Bug Report", filePath: path),
                isSending: _isLoading,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3, // Settings
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
