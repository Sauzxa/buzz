import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/message_type_enum.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input_field.dart';
import '../../theme/colors.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../routes/route_names.dart';
import '../settings/profile/edit_profile_settings.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  ChatProvider? _chatProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupScrollListener();

    // Initialize chat after first frame to avoid accessing Provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to provider for use in dispose
    _chatProvider ??= Provider.of<ChatProvider>(context, listen: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    // Stop polling when leaving chat (use saved reference)
    _chatProvider?.stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final chatProvider = context.read<ChatProvider>();

    if (state == AppLifecycleState.resumed) {
      // App came to foreground - resume polling
      chatProvider.startPolling();
      chatProvider.fetchMessages(refresh: true);
    } else if (state == AppLifecycleState.paused) {
      // App went to background - stop polling (rely on FCM)
      chatProvider.stopPolling();
    }
  }

  Future<void> _initializeChat() async {
    if (_isInitialized) return;

    try {
      await context.read<ChatProvider>().initializeChat();
      _isInitialized = true;

      // Mark all messages as read when chat opens
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.read<ChatProvider>().markAllMessagesAsRead();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load chat: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                setState(() {
                  _isInitialized = false;
                });
                _initializeChat();
              },
            ),
          ),
        );
      }
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Load more messages when scrolling to top (old messages)
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        context.read<ChatProvider>().loadMoreMessages();
      }
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else if (index == 2) {
      Navigator.pushNamed(context, RouteNames.orderManagement);
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditProfileSettings()),
      );
    }
    // index == 4 is current page (Chat)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Support Chat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (chatProvider.currentChat != null)
                  Text(
                    'Customer Support Team',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          // Refresh button
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return IconButton(
                icon: chatProvider.isLoadingMessages
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white),
                onPressed: chatProvider.isLoadingMessages
                    ? null
                    : () => chatProvider.fetchMessages(refresh: true),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatProvider.error != null && !_isInitialized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load chat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      chatProvider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isInitialized = false;
                      });
                      _initializeChat();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Messages list
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount:
                            chatProvider.messages.length +
                            (chatProvider.isLoadingMessages ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Show loading indicator at bottom
                          if (index == chatProvider.messages.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final message = chatProvider.messages[index];
                          final isMyMessage =
                              message.senderId.toString() ==
                              context
                                  .read<ChatProvider>()
                                  .currentChat
                                  ?.userId
                                  .toString();

                          return MessageBubble(
                            message: message,
                            isMine: isMyMessage,
                            onRetry: message.isFailed == true
                                ? () => chatProvider.retryMessage(message)
                                : null,
                          );
                        },
                      ),
              ),

              // Error banner
              if (chatProvider.error != null && _isInitialized)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.red[100],
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          chatProvider.error!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => chatProvider.clearError(),
                      ),
                    ],
                  ),
                ),

              // Message input field
              MessageInputField(
                onSendMessage: (text) => chatProvider.sendMessage(text),
                onSendFile: (filePath, fileType) {
                  final messageType = MessageType.values.firstWhere(
                    (e) => e.name == fileType,
                    orElse: () => MessageType.IMAGE,
                  );
                  chatProvider.sendFileMessage(
                    filePath: filePath,
                    messageType: messageType,
                  );
                },
                isSending: chatProvider.isSendingMessage,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 4, // Chat page
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with our support team',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
