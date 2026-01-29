import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/message_type_enum.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  /// Get or create chat for current user (Customer only)
  Future<ChatModel> getOrCreateMyChat() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getOrCreateMyChat);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChatModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get or create chat: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get specific chat by ID
  Future<ChatModel> getChatById(int chatId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getChatById(chatId));

      if (response.statusCode == 200) {
        return ChatModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get chat: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get paginated list of messages for a chat
  Future<List<MessageModel>> getChatMessages({
    required int chatId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getChatMessages(chatId, page: page, size: size),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle PagedResponseDto structure
        List<dynamic> content;
        if (data is Map && data.containsKey('content')) {
          content = data['content'] as List<dynamic>;
        } else if (data is List) {
          content = data;
        } else {
          throw Exception('Unexpected response format');
        }

        return content.map((json) => MessageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get messages: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Send text message
  Future<MessageModel> sendTextMessage({
    required int chatId,
    required String text,
  }) async {
    try {
      print('📤 [CHAT_SERVICE] Preparing to send text message');
      print('📤 [CHAT_SERVICE] Chat ID: $chatId');
      print('📤 [CHAT_SERVICE] Text: $text');

      // Backend @RequestPart has content-type issues with both octet-stream and text/plain;charset
      // The backend needs to be fixed to use @RequestParam for text-only messages
      // For now, try sending with explicit content-type header
      final data = {'messageType': 'TEXT', 'text': text};

      print('📤 [CHAT_SERVICE] Sending data: $data');

      final response = await _apiClient.post(
        ApiEndpoints.sendMessage(chatId),
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      print('📤 [CHAT_SERVICE] Response status: ${response.statusCode}');
      print('📤 [CHAT_SERVICE] Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MessageModel.fromJson(response.data);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [CHAT_SERVICE] Error sending message: $e');
      rethrow;
    }
  }

  /// Send message with file (image, video, document)
  Future<MessageModel> sendFileMessage({
    required int chatId,
    required String filePath,
    required MessageType messageType,
    String? text,
  }) async {
    try {
      final formData = FormData.fromMap({
        'messageType': messageType.name,
        if (text != null && text.isNotEmpty) 'text': text,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiClient.post(
        ApiEndpoints.sendMessage(chatId),
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MessageModel.fromJson(response.data);
      } else {
        throw Exception('Failed to send file message: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Send voice message
  Future<MessageModel> sendVoiceMessage({
    required int chatId,
    required String voiceFilePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'messageType': 'VOICE',
        'voiceFile': await MultipartFile.fromFile(voiceFilePath),
      });

      final response = await _apiClient.post(
        ApiEndpoints.sendMessage(chatId),
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MessageModel.fromJson(response.data);
      } else {
        throw Exception('Failed to send voice message: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mark a specific message as read
  Future<void> markMessageAsRead({
    required int chatId,
    required int messageId,
  }) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.markMessageAsRead(chatId, messageId),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to mark message as read: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Don't throw - marking as read failure shouldn't disrupt user
      print('Error marking message as read: $e');
    }
  }

  /// Mark all messages in chat as read
  Future<void> markChatAsRead(int chatId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.markChatAsRead(chatId),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark chat as read: ${response.statusCode}');
      }
    } catch (e) {
      // Don't throw - marking as read failure shouldn't disrupt user
      print('Error marking chat as read: $e');
    }
  }

  /// Get all chats (Admin only)
  Future<List<ChatModel>> getAllChats({
    int page = 0,
    int size = 10,
    String sortDir = 'desc',
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getAllChats(page: page, size: size, sortDir: sortDir),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle PagedResponseDto structure
        List<dynamic> content;
        if (data is Map && data.containsKey('content')) {
          content = data['content'] as List<dynamic>;
        } else if (data is List) {
          content = data;
        } else {
          throw Exception('Unexpected response format');
        }

        return content.map((json) => ChatModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get chats: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
