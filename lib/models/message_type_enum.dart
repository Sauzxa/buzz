enum MessageType {
  TEXT,
  IMAGE,
  VIDEO,
  DOCUMENT,
  VOICE;

  String toJson() => name;

  static MessageType fromJson(String json) {
    return MessageType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => MessageType.TEXT,
    );
  }
}
