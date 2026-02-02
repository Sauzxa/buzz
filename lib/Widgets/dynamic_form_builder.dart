import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/form_field_model.dart';
import '../theme/colors.dart';

class DynamicFormBuilder extends StatefulWidget {
  final List<FormFieldModel> formFields;
  final Map<String, dynamic> formData;
  final Function(String fieldId, dynamic value) onFieldChanged;
  final Color? focusColor;

  const DynamicFormBuilder({
    Key? key,
    required this.formFields,
    required this.formData,
    required this.onFieldChanged,
    this.focusColor,
  }) : super(key: key);

  @override
  State<DynamicFormBuilder> createState() => _DynamicFormBuilderState();
}

class _SideBySideDropdown extends StatefulWidget {
  final FormFieldModel field;
  final String? selectedValue;
  final Function(String) onChanged;
  final Color? focusColor;

  const _SideBySideDropdown({
    required this.field,
    required this.selectedValue,
    required this.onChanged,
    this.focusColor,
  });

  @override
  State<_SideBySideDropdown> createState() => _SideBySideDropdownState();
}

class _SideBySideDropdownState extends State<_SideBySideDropdown> {
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void deactivate() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _showOverlay() {
    if (!mounted) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final size = renderBox.size;

    return OverlayEntry(
      builder: (overlayContext) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: widget.field.options?.length ?? 0,
                itemBuilder: (context, index) {
                  final option = widget.field.options![index];
                  final isSelected = widget.selectedValue == option.value;

                  return InkWell(
                    onTap: () {
                      _removeOverlay();
                      widget.onChanged(option.value);
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Text(
                        option.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = widget.field.options?.firstWhere(
      (opt) => opt.value == widget.selectedValue,
      orElse: () => widget.field.options!.first,
    );
    final displayLabel = widget.selectedValue != null
        ? (selectedOption?.label ?? widget.selectedValue)
        : (widget.field.placeholder ?? 'Select');

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).inputDecorationTheme.fillColor ??
                (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkInputFill
                    : Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayLabel!,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: widget.selectedValue != null
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).hintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Theme.of(context).iconTheme.color ?? Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    // Check if we have H and L fields (for printing services)
    final hField = widget.formFields.firstWhere(
      (f) => f.id.toLowerCase() == 'h' || f.label.toLowerCase() == 'h',
      orElse: () => FormFieldModel(
        id: '',
        label: '',
        type: '',
        required: false,
        order: 0,
      ),
    );
    final lField = widget.formFields.firstWhere(
      (f) => f.id.toLowerCase() == 'l' || f.label.toLowerCase() == 'l',
      orElse: () => FormFieldModel(
        id: '',
        label: '',
        type: '',
        required: false,
        order: 0,
      ),
    );

    final hasHAndL = hField.id.isNotEmpty && lField.id.isNotEmpty;
    // Check if we have Quantity and Type fields
    final quantityField = widget.formFields.firstWhere(
      (f) =>
          f.label.toLowerCase() == 'quantity' ||
          f.label.toLowerCase() == 'quantité' ||
          f.id.toLowerCase() == 'quantity',
      orElse: () => FormFieldModel(
        id: '',
        label: '',
        type: '',
        required: false,
        order: 0,
      ),
    );

    final typeField = widget.formFields.firstWhere(
      (f) => f.label.toLowerCase() == 'type' || f.id.toLowerCase() == 'type',
      orElse: () => FormFieldModel(
        id: '',
        label: '',
        type: '',
        required: false,
        order: 0,
      ),
    );

    final fieldsToRender = widget.formFields
        .where(
          (f) =>
              (hasHAndL ? (f.id != hField.id && f.id != lField.id) : true) &&
              (quantityField.id.isNotEmpty ? f.id != quantityField.id : true) &&
              (typeField.id.isNotEmpty ? f.id != typeField.id : true),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Render H and L fields together if they exist
        if (hasHAndL) ...[
          _buildHLFields(hField, lField),
          const SizedBox(height: 16),
        ],

        // Render Quantity field if exists
        if (quantityField.id.isNotEmpty) ...[
          _buildSideBySideField(quantityField),
          const SizedBox(height: 16),
        ],

        // Render Type field if exists
        if (typeField.id.isNotEmpty) ...[
          _buildSideBySideField(typeField),
          const SizedBox(height: 16),
        ],

        // Render other fields
        ...fieldsToRender.asMap().entries.map((entry) {
          final field = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildField(field),
          );
        }).toList(),
      ],
    );
  }

  // Build H and L fields side by side with "Size" label on left
  Widget _buildHLFields(FormFieldModel hField, FormFieldModel lField) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // "Size" label
        Text(
          'Size',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
          ),
        ),

        // H and L inputs
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSmallInput(hField, 'H'),
            const SizedBox(width: 12),
            _buildSmallInput(lField, 'L'),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallInput(FormFieldModel field, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withOpacity(0.7) ??
                Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60, // Minimized width
          height: 40,
          child: TextField(
            controller: _controllers[field.id],
            focusNode: _focusNodes[field.id],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (value) => widget.onFieldChanged(field.id, value),
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  Theme.of(context).inputDecorationTheme.fillColor ??
                  Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.focusColor ?? AppColors.greenColor,
                  width: 2,
                ),
              ),
            ),
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }

  // Build field with label on left and input on right
  Widget _buildSideBySideField(FormFieldModel field) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          field.label,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 150, // Fixed width for right aligned inputs
          height: 40,
          child: field.type == 'dropdown'
              ? _buildSideBySideDropdown(field)
              : _buildSideBySideTextField(field),
        ),
      ],
    );
  }

  Widget _buildSideBySideTextField(FormFieldModel field) {
    return TextField(
      controller: _controllers[field.id],
      focusNode: _focusNodes[field.id],
      keyboardType: field.type == 'number'
          ? TextInputType.number
          : TextInputType.text,
      textAlign: TextAlign.start,
      onChanged: (value) => widget.onFieldChanged(field.id, value),
      decoration: InputDecoration(
        filled: true,
        fillColor:
            Theme.of(context).inputDecorationTheme.fillColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkInputFill
                : Colors.white),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: widget.focusColor ?? AppColors.greenColor,
            width: 2,
          ),
        ),
      ),
      style: GoogleFonts.dmSans(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildSideBySideDropdown(FormFieldModel field) {
    final selectedValue = widget.formData[field.id];

    return _SideBySideDropdown(
      field: field,
      selectedValue: selectedValue,
      onChanged: (value) => widget.onFieldChanged(field.id, value),
      focusColor: widget.focusColor,
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
              color:
                  Theme.of(context).inputDecorationTheme.hintStyle?.color ??
                  Colors.grey[400],
            ),
            filled: true,
            fillColor:
                Theme.of(context).inputDecorationTheme.fillColor ??
                const Color(0xFFF5F7FA),
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
              borderSide: BorderSide(
                color: widget.focusColor ?? AppColors.greenColor,
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
              color:
                  Theme.of(context).inputDecorationTheme.hintStyle?.color ??
                  Colors.grey[400],
            ),
            filled: true,
            fillColor:
                Theme.of(context).inputDecorationTheme.fillColor ??
                const Color(0xFFF5F7FA),
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
              borderSide: BorderSide(
                color: widget.focusColor ?? AppColors.greenColor,
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
                    : Theme.of(context).inputDecorationTheme.fillColor ??
                          const Color(0xFFF5F7FA),
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
                            : Theme.of(context).dividerColor,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    widget.focusColor ?? AppColors.greenColor,
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
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black87,
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
                    : Theme.of(context).inputDecorationTheme.fillColor ??
                          const Color(0xFFF5F7FA),
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
                            : Theme.of(context).dividerColor,
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
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black87,
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
    final selectedValue = widget.formData[field.id];
    final selectedOption = field.options?.firstWhere(
      (opt) => opt.value == selectedValue,
      orElse: () => field.options!.first,
    );

    return _CustomDropdownField(
      field: field,
      selectedValue: selectedValue,
      selectedLabel: selectedValue != null ? selectedOption?.label : null,
      onChanged: (value) => widget.onFieldChanged(field.id, value),
      focusColor: widget.focusColor,
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
                    colorScheme: ColorScheme.light(
                      primary: AppColors.greenColor,
                      onPrimary: Colors.white,
                      surface: Theme.of(context).cardColor,
                      onSurface:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black,
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
              color:
                  Theme.of(context).inputDecorationTheme.fillColor ??
                  const Color(0xFFF5F7FA),
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
                        ? Theme.of(context).textTheme.bodyLarge?.color ??
                              Colors.black87
                        : Theme.of(
                                context,
                              ).inputDecorationTheme.hintStyle?.color ??
                              Colors.grey[400],
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color:
                      Theme.of(context).textTheme.bodySmall?.color ??
                      Colors.grey[600],
                ),
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
                      : Theme.of(context).inputDecorationTheme.fillColor ??
                            const Color(0xFFF5F7FA),
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
                            color: Theme.of(context).disabledColor,
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
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black87,
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
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
        ),
        children: [
          if (field.required)
            const TextSpan(
              text: ' ',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}

// Custom Dropdown Field Widget
class _CustomDropdownField extends StatefulWidget {
  final FormFieldModel field;
  final String? selectedValue;
  final String? selectedLabel;
  final Function(String?) onChanged;
  final Color? focusColor;

  const _CustomDropdownField({
    required this.field,
    required this.selectedValue,
    required this.selectedLabel,
    required this.onChanged,
    this.focusColor,
  });

  @override
  State<_CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<_CustomDropdownField> {
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void deactivate() {
    // Just remove overlay without setState during deactivate
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _showOverlay() {
    if (!mounted) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      // Return a dummy overlay if render box is not ready
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final size = renderBox.size;

    return OverlayEntry(
      builder: (overlayContext) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: widget.field.options?.length ?? 0,
                itemBuilder: (context, index) {
                  final option = widget.field.options![index];
                  final isSelected = widget.selectedValue == option.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Remove overlay first, then trigger callback
                          _removeOverlay();
                          // Use post-frame callback to ensure overlay is removed
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            widget.onChanged(option.value);
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Text(
                            option.label,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color ??
                                  Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).inputDecorationTheme.fillColor ??
                    const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
                border: _isOpen
                    ? Border.all(
                        color: widget.focusColor ?? AppColors.greenColor,
                        width: 2,
                      )
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedLabel ??
                          widget.field.placeholder ??
                          'Select ${widget.field.label.toLowerCase()}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: widget.selectedLabel != null
                            ? Theme.of(context).textTheme.bodyLarge?.color ??
                                  Colors.black87
                            : Theme.of(
                                    context,
                                  ).inputDecorationTheme.hintStyle?.color ??
                                  Colors.grey[400],
                      ),
                    ),
                  ),
                  Icon(
                    _isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return RichText(
      text: TextSpan(
        text: widget.field.label,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
        ),
        children: [
          if (widget.field.required)
            const TextSpan(
              text: ' ',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
