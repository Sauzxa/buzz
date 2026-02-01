import 'form_field_model.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String? categoryId;
  final String? categoryName;
  final double? price;
  final String? imageUrl;
  final String? mainImage;
  final bool? isActive;
  final String? color;
  final List<FormFieldModel>? formFields;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    this.categoryId,
    this.categoryName,
    this.price,
    this.imageUrl,
    this.mainImage,
    this.isActive,
    this.color,
    this.formFields,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    List<FormFieldModel>? fields;

    // Parse formFields - handle multiple formats
    // IMPORTANT: Backend currently returns malformed JSON for formFields
    // It returns: "formFields": "fields": [...] instead of "formFields": {"fields": [...]}
    // So we skip parsing it for now to prevent crashes
    if (json['formFields'] != null) {
      try {
        List? fieldsList;

        // Check if formFields is an object with 'fields' key (new format)
        if (json['formFields'] is Map) {
          final formFieldsMap = json['formFields'] as Map<String, dynamic>;

          // The backend might return {" fields": [...]} or just {...}
          if (formFieldsMap.containsKey('fields')) {
            fieldsList = formFieldsMap['fields'] as List?;
          } else {
            // If no 'fields' key, the map itself might be malformed
            // Try to extract any array value
            for (var value in formFieldsMap.values) {
              if (value is List) {
                fieldsList = value;
                break;
              }
            }
          }
        }
        // Check if formFields is a direct array (old format)
        else if (json['formFields'] is List) {
          fieldsList = json['formFields'] as List;
        }
        // Check if formFields is a STRING (malformed JSON from backend)
        else if (json['formFields'] is String) {
          print(
            '⚠️ [SERVICE_MODEL] formFields is a STRING (malformed JSON from backend)',
          );
          print('⚠️ [SERVICE_MODEL] Skipping formFields parsing');
          // Cannot parse string, skip it
          fieldsList = null;
        }

        // Parse the fields list
        if (fieldsList != null && fieldsList.isNotEmpty) {
          fields = fieldsList
              .map((field) {
                try {
                  return FormFieldModel.fromJson(field as Map<String, dynamic>);
                } catch (e) {
                  print('⚠️ [SERVICE_MODEL] Error parsing form field: $field');
                  print('⚠️ [SERVICE_MODEL] Error: $e');
                  return null;
                }
              })
              .whereType<FormFieldModel>() // Filter out nulls
              .toList();

          // Sort by order
          fields.sort((a, b) => a.order.compareTo(b.order));
        }
      } catch (e) {
        print('⚠️ [SERVICE_MODEL] Error parsing formFields: $e');
        print('⚠️ [SERVICE_MODEL] formFields data: ${json['formFields']}');
        fields = null; // Just skip formFields if parsing fails
      }
    }

    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['serviceName']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      imageUrl:
          json['serviceImage']?.toString() ?? json['imageUrl']?.toString(),
      mainImage: json['mainImage']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      formFields: fields,
      color:
          json['color']?.toString() ??
          json['backgroundColor']
              ?.toString(), // Support both naming conventions
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'price': price,
      'imageUrl': imageUrl,
      'mainImage': mainImage,
      'isActive': isActive,
      'color': color,
      'formFields': formFields?.map((field) => field.toJson()).toList(),
    };
  }
}
