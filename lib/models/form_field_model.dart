class FormFieldModel {
  final String id;
  final String type;
  final String label;
  final String? placeholder;
  final String? description;
  final bool required;
  final int order;
  final List<FormFieldOption>? options;
  final FormFieldValidation? validation;
  final bool? multiple;
  final List<String>? accept;
  final int? maxFileSize;
  final int? maxFiles;
  final int?
  columns; // Page number for multi-page forms (1 or 2), also used for grid layout

  FormFieldModel({
    required this.id,
    required this.type,
    required this.label,
    this.placeholder,
    this.description,
    this.required = false,
    this.order = 0,
    this.options,
    this.validation,
    this.multiple,
    this.accept,
    this.maxFileSize,
    this.maxFiles,
    this.columns,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'text',
      label: json['label'] ?? '',
      placeholder: json['placeholder'],
      description: json['description'],
      required: json['required'] ?? false,
      order: json['order'] ?? 0,
      options: json['options'] != null
          ? (json['options'] as List)
                .map((opt) => FormFieldOption.fromJson(opt))
                .toList()
          : null,
      validation: json['validation'] != null
          ? FormFieldValidation.fromJson(json['validation'])
          : null,
      multiple: json['multiple'],
      accept: json['accept'] != null ? List<String>.from(json['accept']) : null,
      maxFileSize: json['maxFileSize'],
      maxFiles: json['maxFiles'],
      columns: json['columns'], // Page number for multi-page forms
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'label': label,
      'placeholder': placeholder,
      'description': description,
      'required': required,
      'order': order,
      'options': options?.map((opt) => opt.toJson()).toList(),
      'validation': validation?.toJson(),
      'multiple': multiple,
      'accept': accept,
      'maxFileSize': maxFileSize,
      'maxFiles': maxFiles,
      'columns': columns,
    };
  }
}

class FormFieldOption {
  final String value;
  final String label;
  final String? image;
  final String? description;

  FormFieldOption({
    required this.value,
    required this.label,
    this.image,
    this.description,
  });

  factory FormFieldOption.fromJson(Map<String, dynamic> json) {
    return FormFieldOption(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
      'image': image,
      'description': description,
    };
  }
}

class FormFieldValidation {
  final int? minLength;
  final int? maxLength;
  final num? min;
  final num? max;
  final String? minDate;
  final String? maxDate;

  FormFieldValidation({
    this.minLength,
    this.maxLength,
    this.min,
    this.max,
    this.minDate,
    this.maxDate,
  });

  factory FormFieldValidation.fromJson(Map<String, dynamic> json) {
    return FormFieldValidation(
      minLength: json['minLength'],
      maxLength: json['maxLength'],
      min: json['min'],
      max: json['max'],
      minDate: json['minDate'],
      maxDate: json['maxDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minLength': minLength,
      'maxLength': maxLength,
      'min': min,
      'max': max,
      'minDate': minDate,
      'maxDate': maxDate,
    };
  }
}
