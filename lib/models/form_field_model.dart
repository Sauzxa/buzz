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
  final bool? readOnly; // Field is read-only (not editable)
  final bool? computed; // Field value is computed from formula
  final List<String>? dependsOn; // List of field IDs this field depends on
  final String? formula; // Formula expression for computed fields
  final List<FormFieldRule>? rules; // Conditional rules for computed fields

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
    this.readOnly,
    this.computed,
    this.dependsOn,
    this.formula,
    this.rules,
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
      readOnly: json['readOnly'],
      computed: json['computed'],
      dependsOn: json['dependsOn'] != null
          ? List<String>.from(json['dependsOn'])
          : null,
      formula: json['formula'],
      rules: json['rules'] != null
          ? (json['rules'] as List)
                .map((rule) => FormFieldRule.fromJson(rule))
                .toList()
          : null,
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
      'readOnly': readOnly,
      'computed': computed,
      'dependsOn': dependsOn,
      'formula': formula,
      'rules': rules?.map((rule) => rule.toJson()).toList(),
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

class FormFieldRule {
  final String when; // Condition expression (e.g., "support == 'cartoon'")
  final double multiply; // Multiplier to apply when condition is true

  FormFieldRule({required this.when, required this.multiply});

  factory FormFieldRule.fromJson(Map<String, dynamic> json) {
    return FormFieldRule(
      when: json['when'] ?? '',
      multiply: (json['multiply'] ?? 1).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'when': when, 'multiply': multiply};
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
