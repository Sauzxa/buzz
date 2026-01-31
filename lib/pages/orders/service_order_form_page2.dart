import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/service_model.dart';
import '../../models/form_field_model.dart';
import '../../Widgets/button.dart';
import '../../Widgets/dynamic_form_builder.dart';
import '../../Widgets/file_upload_widget.dart';
import '../../services/order_service.dart';
import '../../utils/category_theme.dart';
import 'order_success_page.dart';

class ServiceOrderFormPage2 extends StatefulWidget {
  final ServiceModel service;
  final Map<String, dynamic> page1FormData;
  final List<File> page1Files;
  final CategoryTheme categoryTheme;

  const ServiceOrderFormPage2({
    Key? key,
    required this.service,
    required this.page1FormData,
    required this.page1Files,
    required this.categoryTheme,
  }) : super(key: key);

  @override
  State<ServiceOrderFormPage2> createState() => _ServiceOrderFormPage2State();
}

class _ServiceOrderFormPage2State extends State<ServiceOrderFormPage2> {
  final Map<String, dynamic> _page2FormData = {};
  final List<File> _page2Files = [];
  final OrderService _orderService = OrderService();
  bool _isSubmitting = false;

  List<FormFieldModel> get _page2Fields {
    if (widget.service.formFields == null) return [];
    return widget.service.formFields!
        .where((field) => (field.columns ?? 1) == 2)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  void initState() {
    super.initState();
    // Initialize page 2 files with files from page 1
    _page2Files.addAll(widget.page1Files);
  }

  void _onFieldChanged(String fieldId, dynamic value) {
    setState(() {
      _page2FormData[fieldId] = value;
    });
  }

  void _onFilesChanged(List<File> files) {
    setState(() {
      _page2Files.clear();
      _page2Files.addAll(files);
    });
  }

  bool _validatePage2() {
    for (var field in _page2Fields) {
      if (field.type == 'file') continue; // Skip file fields for now

      final value = _page2FormData[field.id];

      // Check required fields
      if (field.required) {
        if (value == null) {
          _showError('${field.label} is required');
          return false;
        }

        if (value is String && value.trim().isEmpty) {
          _showError('${field.label} is required');
          return false;
        }

        if (value is List && value.isEmpty) {
          _showError('${field.label} is required');
          return false;
        }
      }

      // Validate field-specific rules
      if (value != null && field.validation != null) {
        final validation = field.validation!;

        // String length validation
        if (value is String && value.isNotEmpty) {
          if (validation.minLength != null &&
              value.length < validation.minLength!) {
            _showError(
              '${field.label} must be at least ${validation.minLength} characters',
            );
            return false;
          }

          if (validation.maxLength != null &&
              value.length > validation.maxLength!) {
            _showError(
              '${field.label} must not exceed ${validation.maxLength} characters',
            );
            return false;
          }
        }

        // Number range validation
        if (field.type == 'number') {
          final numValue = double.tryParse(value.toString());
          if (numValue != null) {
            if (validation.min != null && numValue < validation.min!) {
              _showError('${field.label} must be at least ${validation.min}');
              return false;
            }

            if (validation.max != null && numValue > validation.max!) {
              _showError('${field.label} must not exceed ${validation.max}');
              return false;
            }
          }
        }
      }
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _submitOrder() async {
    if (!_validatePage2()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Combine page 1 and page 2 form data
      final completeFormData = {...widget.page1FormData, ..._page2FormData};

      // Call API to submit order with complete data
      final orderId = await _orderService.createOrder(
        serviceId: widget.service.id,
        formData: completeFormData,
        files: _page2Files,
      );

      print('Order submitted successfully with ID: $orderId');

      // Navigate to success page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessPage(
              categoryName: widget.service.categoryName,
              orderId: orderId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: widget.categoryTheme.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Place Order - Page 2',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Name
              Text(
                widget.service.name,
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete the remaining details',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Page indicator
              _buildPageIndicator(),
              const SizedBox(height: 24),

              // Dynamic Form Fields for page 2
              _buildPage2Fields(),

              const SizedBox(height: 24),

              // File Upload Section (if page 2 has file fields)
              _buildFileUploadSection(),

              const SizedBox(height: 32),

              // Submit Button
              PrimaryButton(
                text: _isSubmitting ? 'Submitting...' : 'Submit Order',
                onPressed: () {
                  if (!_isSubmitting) {
                    _submitOrder();
                  }
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Page 1 indicator (completed)
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: widget.categoryTheme.color.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        // Page 2 indicator (current)
        Container(
          width: 30,
          height: 10,
          decoration: BoxDecoration(
            color: widget.categoryTheme.color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }

  Widget _buildPage2Fields() {
    // Filter regular fields (non-file fields) for DynamicFormBuilder
    final regularFields = _page2Fields.where((f) => f.type != 'file').toList();

    if (regularFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return DynamicFormBuilder(
      formFields: regularFields,
      formData: _page2FormData,
      onFieldChanged: _onFieldChanged,
      focusColor: widget.categoryTheme.color,
    );
  }

  Widget _buildFileUploadSection() {
    // Check if any fields in page 2 are file upload fields
    final hasFileFields = _page2Fields.any((f) => f.type == 'file');

    if (!hasFileFields) {
      return const SizedBox.shrink();
    }

    return FileUploadWidget(
      uploadedFiles: _page2Files,
      onFilesChanged: _onFilesChanged,
    );
  }
}
