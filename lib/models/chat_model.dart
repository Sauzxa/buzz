class ChatModel {
  final int id;
  final int userId;
  final String userFullName;
  final String? userEmail;
  final int? adminCount;
  final int? messageCount;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    this.userEmail,
    this.adminCount,
    this.messageCount,
    required this.unreadCount,
    this.lastMessageAt,
    this.lastMessagePreview,
    required this.createdAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      userFullName: json['userFullName'] as String,
      userEmail: json['userEmail'] as String?,
      adminCount: json['adminCount'] as int?,
      messageCount: json['messageCount'] as int?,
      unreadCount: (json['unreadCount'] as int?) ?? 0,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userFullName': userFullName,
      'userEmail': userEmail,
      'adminCount': adminCount,
      'messageCount': messageCount,
      'unreadCount': unreadCount,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastMessagePreview': lastMessagePreview,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ChatModel copyWith({
    int? id,
    int? userId,
    String? userFullName,
    String? userEmail,
    int? adminCount,
    int? messageCount,
    int? unreadCount,
    DateTime? lastMessageAt,
    String? lastMessagePreview,
    DateTime? createdAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userFullName: userFullName ?? this.userFullName,
      userEmail: userEmail ?? this.userEmail,
      adminCount: adminCount ?? this.adminCount,
      messageCount: messageCount ?? this.messageCount,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
