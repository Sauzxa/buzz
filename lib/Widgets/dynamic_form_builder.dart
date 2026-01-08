import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/form_field_model.dart';
import '../theme/colors.dart';

class DynamicFormBuilder extends StatefulWidget {
  final List<FormFieldModel> formFields;
  final Map<String, dynamic> formData;
  final Function(String fieldId, dynamic value) onFieldChanged;

  const DynamicFormBuilder({
    Key? key,
    required this.formFields,
    required this.formData,
    required this.onFieldChanged,
  }) : super(key: key);

  @override
  State<DynamicFormBuilder> createState() => _DynamicFormBuilderState();
}

class _DynamicFormBuilderState extends State<DynamicFormBuilder> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    for (var field in widget.formFields) {
      if (field.type == 'text' ||
          field.type == 'textarea' ||
          field.type == 'number' ||
          field.type == 'email') {
        _controllers[field.id] = TextEditingController(
          text: widget.formData[field.id]?.toString() ?? '',
        );
        _focusNodes[field.id] = FocusNode();
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    _focusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.formFields.length,
      itemBuilder: (context, index) {
        final field = widget.formFields[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildField(field),
        );
      },
    );
  }

  Widget _buildField(FormFieldModel field) {
    switch (field.type) {
      case 'text':
      case 'email':
      case 'number':
        return _buildTextField(field);
      case 'textarea':
        return _buildTextAreaField(field);
      case 'radio':
        return _buildRadioField(field);
      case 'checkbox':
        return _buildCheckboxField(field);
      case 'dropdown':
        return _buildDropdownField(field);
      case 'date':
        return _buildDateField(field);
      case 'grid_select':
        return _buildGridSelectField(field);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextField(FormFieldModel field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        const SizedBox(height: 8),
        TextField(
          controller: _controllers[field.id],
          focusNode: _focusNodes[field.id],
          keyboardType: field.type == 'number'
              ? TextInputType.number
              : field.type == 'email'
              ? TextInputType.emailAddress
              : TextInputType.text,
          onChanged: (value) => widget.onFieldChanged(field.id, value),
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
            hintStyle: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.greenColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTextAreaField(FormFieldModel field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        const SizedBox(height: 8),
        TextField(
          controller: _controllers[field.id],
          focusNode: _focusNodes[field.id],
          maxLines: 5,
          onChanged: (value) => widget.onFieldChanged(field.id, value),
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
            hintStyle: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.greenColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRadioField(FormFieldModel field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        const SizedBox(height: 12),
        ...field.options!.map((option) {
          final isSelected = widget.formData[field.id] == option.value;
          return GestureDetector(
            onTap: () => widget.onFieldChanged(field.id, option.value),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.greenColor.withOpacity(0.1)
                    : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.greenColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.greenColor
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.greenColor,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCheckboxField(FormFieldModel field) {
    final selectedValues = (widget.formData[field.id] as List<String>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        const SizedBox(height: 12),
        ...field.options!.map((option) {
          final isSelected = selectedValues.contains(option.value);
          return GestureDetector(
            onTap: () {
              final newValues = List<String>.from(selectedValues);
              if (isSelected) {
                newValues.remove(option.value);
              } else {
                newValues.add(option.value);
              }
              widget.onFieldChanged(field.id, newValues);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.greenColor.withOpacity(0.1)
                    : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.greenColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.greenColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.greenColor
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDropdownField(FormFieldModel field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: widget.formData[field.id],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.greenColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            hint: Text(
              field.placeholder ?? 'Select ${field.label.toLowerCase()}',
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[400]),
            ),
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black87),
            dropdownColor: Colors.white,
            items: field.options!.map((option) {
              return DropdownMenuItem<String>(
                value: option.value,
                child: Text(option.label),
              );
            }).toList(),
            onChanged: (value) => widget.onFieldChanged(field.id, value),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(FormFieldModel field) {
    final selectedDate = widget.formData[field.id] as DateTime?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.greenColor,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              widget.onFieldChanged(field.id, date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                      : field.placeholder ?? 'Select date',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: selectedDate != null
                        ? Colors.black87
                        : Colors.grey[400],
                  ),
                ),
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridSelectField(FormFieldModel field) {
    final selectedValue = widget.formData[field.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: field.options!.length,
          itemBuilder: (context, index) {
            final option = field.options![index];
            final isSelected = selectedValue == option.value;

            return GestureDetector(
              onTap: () => widget.onFieldChanged(field.id, option.value),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.greenColor.withOpacity(0.1)
                      : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.greenColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (option.image != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          option.image!,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      option.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLabel(FormFieldModel field) {
    return RichText(
      text: TextSpan(
        text: field.label,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: [
          if (field.required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
