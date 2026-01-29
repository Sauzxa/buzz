import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/message_type_enum.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final StorageService _storageService = StorageService();

  // State variables
  ChatModel? _currentChat;
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isLoadingMessages = false;
  bool _isSendingMessage = false;
  String? _error;
  Timer? _pollingTimer;
  bool _isChatActive = false;
  int _currentPage = 0;
  bool _hasMoreMessages = true;

  // Getters
  ChatModel? get currentChat => _currentChat;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSendingMessage => _isSendingMessage;
  String? get error => _error;
  int get unreadCount => _currentChat?.unreadCount ?? 0;
  bool get hasMoreMessages => _hasMoreMessages;

  /// Initialize chat - Get or create chat and start polling
  Future<void> initializeChat() async {
    _setLoading(true);
    _error = null;

    try {
      // Get or create chat
      _currentChat = await _chatService.getOrCreateMyChat();

      // Load cached messages first for instant display
      await _loadCachedMessages();

      // Fetch latest messages from server
      await fetchMessages(refresh: true);

      // Start polling for new messages
      startPolling();

      _isChatActive = true;
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to initialize chat: ${e.toString()}';
      _setLoading(false);
      print('Error initializing chat: $e');
      rethrow;
    }
  }

  /// Fetch messages from server
  Future<void> fetchMessages({bool refresh = false}) async {
    if (_currentChat == null) return;

    if (refresh) {
      _currentPage = 0;
      _hasMoreMessages = true;
    }

    _isLoadingMessages = true;
    notifyListeners();

    try {
      final newMessages = await _chatService.getChatMessages(
        chatId: _currentChat!.id,
        page: _currentPage,
        size: 20,
      );

      if (refresh) {
        _messages = newMessages;
      } else {
        // Append old messages for pagination
        _messages.addAll(newMessages);
      }

      _hasMoreMessages = newMessages.length == 20;
      _currentPage++;

      // Cache messages
      await _cacheMessages();

      _isLoadingMessages = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMessages = false;
      print('Error fetching messages: $e');
      notifyListeners();
    }
  }

  /// Start polling for new messages
  void startPolling() {
    stopPolling(); // Clear any existing timer

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isChatActive && _currentChat != null) {
        _fetchNewMessagesQuietly();
      }
    });

    print('✅ Chat polling started (every 5 seconds)');
  }

  /// Stop polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isChatActive = false;
    print('⏸️ Chat polling stopped');
  }

  /// Fetch new messages silently (for polling)
  Future<void> _fetchNewMessagesQuietly() async {
    if (_currentChat == null || _messages.isEmpty) return;

    try {
      final latestMessages = await _chatService.getChatMessages(
        chatId: _currentChat!.id,
        page: 0,
        size: 20,
      );

      // Check if there are new messages
      if (_hasNewMessages(latestMessages)) {
        _messages = latestMessages;
        await _cacheMessages();
        notifyListeners(); // ← UI REBUILDS INSTANTLY
        print('🔄 New messages received via polling');
      }
    } catch (e) {
      // Silent fail - don't disrupt user experience
      print('Polling error: $e');
    }
  }

  /// Check if there are new messages
  bool _hasNewMessages(List<MessageModel> newMessages) {
    if (_messages.isEmpty) return newMessages.isNotEmpty;
    if (newMessages.isEmpty) return false;

    final latestLocalId = _messages.first.id;
    final latestRemoteId = newMessages.first.id;

    return latestRemoteId != latestLocalId ||
        newMessages.length != _messages.length;
  }

  /// Send text message with optimistic UI update
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _currentChat == null) return;

    final userId = await _storageService.getUserId();
    final userData = await _storageService.getUserData();

    if (userId == null || userData == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    // Create temporary message for optimistic UI
    final tempMessage = MessageModel(
      id: -DateTime.now().millisecondsSinceEpoch, // Negative = temporary
      chatId: _currentChat!.id,
      senderId: int.parse(userId),
      senderFullName: userData.fullName ?? 'You',
      senderEmail: userData.email,
      text: text,
      messageType: MessageType.TEXT,
      readBy: {},
      isRead: false,
      createdAt: DateTime.now(),
      isPending: true,
    );

    // Add to messages list IMMEDIATELY
    _messages.insert(0, tempMessage);
    notifyListeners(); // ← USER SEES MESSAGE INSTANTLY

    _isSendingMessage = true;
    notifyListeners();

    try {
      // Send to backend
      final sentMessage = await _chatService.sendTextMessage(
        chatId: _currentChat!.id,
        text: text,
      );

      // Replace temp message with real one
      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        _messages[index] = sentMessage;
      }

      await _cacheMessages();
      _isSendingMessage = false;
      notifyListeners();

      print('✅ Message sent successfully');
    } catch (e) {
      // Mark message as failed
      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        _messages[index] = tempMessage.copyWith(
          isPending: false,
          isFailed: true,
        );
      }

      _error = 'Failed to send message';
      _isSendingMessage = false;
      notifyListeners();

      print('❌ Failed to send message: $e');
    }
  }

  /// Send file message (image, video, document)
  Future<void> sendFileMessage({
    required String filePath,
    required MessageType messageType,
    String? text,
  }) async {
    if (_currentChat == null) return;

    _isSendingMessage = true;
    notifyListeners();

    try {
      final sentMessage = await _chatService.sendFileMessage(
        chatId: _currentChat!.id,
        filePath: filePath,
        messageType: messageType,
        text: text,
      );

      _messages.insert(0, sentMessage);
      await _cacheMessages();

      _isSendingMessage = false;
      notifyListeners();

      print('✅ File message sent successfully');
    } catch (e) {
      _error = 'Failed to send file';
      _isSendingMessage = false;
      notifyListeners();

      print('❌ Failed to send file: $e');
    }
  }

  /// Send voice message
  Future<void> sendVoiceMessage(String voiceFilePath) async {
    if (_currentChat == null) return;

    _isSendingMessage = true;
    notifyListeners();

    try {
      final sentMessage = await _chatService.sendVoiceMessage(
        chatId: _currentChat!.id,
        voiceFilePath: voiceFilePath,
      );

      _messages.insert(0, sentMessage);
      await _cacheMessages();

      _isSendingMessage = false;
      notifyListeners();

      print('✅ Voice message sent successfully');
    } catch (e) {
      _error = 'Failed to send voice message';
      _isSendingMessage = false;
      notifyListeners();

      print('❌ Failed to send voice message: $e');
    }
  }

  /// Mark message as read
  Future<void> markMessageAsRead(int messageId) async {
    if (_currentChat == null) return;

    // Update locally immediately
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1 && !_messages[index].isRead) {
      _messages[index] = _messages[index].copyWith(isRead: true);
      notifyListeners();
    }

    // Update on server in background
    await _chatService.markMessageAsRead(
      chatId: _currentChat!.id,
      messageId: messageId,
    );
  }

  /// Mark all messages as read
  Future<void> markAllMessagesAsRead() async {
    if (_currentChat == null) return;

    try {
      await _chatService.markChatAsRead(_currentChat!.id);

      // Update all messages locally
      _messages = _messages.map((m) => m.copyWith(isRead: true)).toList();
      _currentChat = _currentChat!.copyWith(unreadCount: 0);

      notifyListeners();
      print('✅ All messages marked as read');
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// Handle FCM notification for new message
  void onNewMessageNotification() {
    print('🔔 FCM: New message notification received');
    if (_isChatActive && _currentChat != null) {
      _fetchNewMessagesQuietly();
    }
  }

  /// Retry sending failed message
  Future<void> retryMessage(MessageModel failedMessage) async {
    if (failedMessage.text != null) {
      // Remove failed message
      _messages.removeWhere((m) => m.id == failedMessage.id);
      notifyListeners();

      // Resend
      await sendMessage(failedMessage.text!);
    }
  }

  /// Load more old messages (pagination)
  Future<void> loadMoreMessages() async {
    if (!_hasMoreMessages || _isLoadingMessages) return;
    await fetchMessages(refresh: false);
  }

  /// Cache messages locally
  Future<void> _cacheMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages.map((m) => m.toJson()).toList();
      await prefs.setString(
        'chat_${_currentChat!.id}_messages',
        jsonEncode(messagesJson),
      );
    } catch (e) {
      print('Error caching messages: $e');
    }
  }

  /// Load cached messages
  Future<void> _loadCachedMessages() async {
    if (_currentChat == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('chat_${_currentChat!.id}_messages');

      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        _messages = decoded.map((json) => MessageModel.fromJson(json)).toList();
        notifyListeners();
        print('📦 Loaded ${_messages.length} cached messages');
      }
    } catch (e) {
      print('Error loading cached messages: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
