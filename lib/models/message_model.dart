import 'message_type_enum.dart';

class MessageModel {
  final int id;
  final int chatId;
  final int senderId;
  final String senderFullName;
  final String? senderEmail;
  final String? text;
  final String? fileUrl;
  final String? voiceUrl;
  final MessageType messageType;
  final Set<int> readBy;
  final bool isRead;
  final DateTime createdAt;
  final bool? isFailed; // For optimistic UI updates
  final bool? isPending; // For optimistic UI updates

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderFullName,
    this.senderEmail,
    this.text,
    this.fileUrl,
    this.voiceUrl,
    required this.messageType,
    required this.readBy,
    required this.isRead,
    required this.createdAt,
    this.isFailed,
    this.isPending,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      chatId: json['chatId'] as int,
      senderId: json['senderId'] as int,
      senderFullName: json['senderFullName'] as String,
      senderEmail: json['senderEmail'] as String?,
      text: json['text'] as String?,
      fileUrl: json['fileUrl'] as String?,
      voiceUrl: json['voiceUrl'] as String?,
      messageType: MessageType.fromJson(json['messageType'] as String),
      readBy:
          (json['readBy'] as List<dynamic>?)?.map((e) => e as int).toSet() ??
          {},
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFailed: json['isFailed'] as bool?,
      isPending: json['isPending'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderFullName': senderFullName,
      'senderEmail': senderEmail,
      'text': text,
      'fileUrl': fileUrl,
      'voiceUrl': voiceUrl,
      'messageType': messageType.toJson(),
      'readBy': readBy.toList(),
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'isFailed': isFailed,
      'isPending': isPending,
    };
  }

  MessageModel copyWith({
    int? id,
    int? chatId,
    int? senderId,
    String? senderFullName,
    String? senderEmail,
    String? text,
    String? fileUrl,
    String? voiceUrl,
    MessageType? messageType,
    Set<int>? readBy,
    bool? isRead,
    DateTime? createdAt,
    bool? isFailed,
    bool? isPending,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderFullName: senderFullName ?? this.senderFullName,
      senderEmail: senderEmail ?? this.senderEmail,
      text: text ?? this.text,
      fileUrl: fileUrl ?? this.fileUrl,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      messageType: messageType ?? this.messageType,
      readBy: readBy ?? this.readBy,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      isFailed: isFailed ?? this.isFailed,
      isPending: isPending ?? this.isPending,
    );
  }
}
