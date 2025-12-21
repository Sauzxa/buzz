class NewsModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime? date;
  final String? category;
  final bool? isActive;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.date,
    this.category,
    this.isActive,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      category: json['category']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': date?.toIso8601String(),
      'category': category,
      'isActive': isActive,
    };
  }

  String get formattedDate {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date!);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date!.day}/${date!.month}/${date!.year}';
    }
  }
}
