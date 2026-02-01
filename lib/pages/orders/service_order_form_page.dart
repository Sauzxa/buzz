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
import 'service_order_form_page2.dart';

class ServiceOrderFormPage extends StatefulWidget {
  final ServiceModel service;

  const ServiceOrderFormPage({Key? key, required this.service})
    : super(key: key);

  @override
  State<ServiceOrderFormPage> createState() => _ServiceOrderFormPageState();
}

class _ServiceOrderFormPageState extends State<ServiceOrderFormPage> {
  final Map<String, dynamic> _formData = {};
  final List<File> _uploadedFiles = [];
  final OrderService _orderService = OrderService();
  bool _isSubmitting = false;

  // Get category theme colors
  CategoryTheme get _categoryTheme =>
      CategoryTheme.fromCategoryName(widget.service.categoryName);

  // Get maximum columns number to determine if multi-page
  int get _maxColumn {
    if (widget.service.formFields == null ||
        widget.service.formFields!.isEmpty) {
      return 1;
    }
    return widget.service.formFields!
        .map((f) => f.columns ?? 1)
        .reduce((a, b) => a > b ? a : b);
  }

  // Check if this service has multi-page form
  bool get _isMultiPage => _maxColumn >= 2;

  // Check if this is a printing category service
  bool get _isPrintingCategory =>
      widget.service.categoryName?.toLowerCase() == 'printing';

  // Get fields for page 1 only
  List<FormFieldModel> get _page1Fields {
    if (widget.service.formFields == null) return [];
    return widget.service.formFields!
        .where((field) => (field.columns ?? 1) == 1)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  void _onFieldChanged(String fieldId, dynamic value) {
    setState(() {
      _formData[fieldId] = value;
    });
  }

  void _onFilesChanged(List<File> files) {
    setState(() {
      _uploadedFiles.clear();
      _uploadedFiles.addAll(files);
    });
  }

  bool _validatePage(List<FormFieldModel> fields) {
    for (var field in fields) {
      final value = _formData[field.id];

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

  void _goToNextPage() {
    // Validate page 1 before navigating
    if (!_validatePage(_page1Fields)) return;

    // Navigate to page 2
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceOrderFormPage2(
          service: widget.service,
          page1FormData: Map<String, dynamic>.from(_formData),
          page1Files: List<File>.from(_uploadedFiles),
          categoryTheme: _categoryTheme,
        ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    // Validate page 1 fields (for single-page forms)
    if (!_validatePage(_page1Fields)) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Call API to submit order
      final orderId = await _orderService.createOrder(
        serviceId: widget.service.id,
        formData: _formData,
        files: _uploadedFiles,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: _categoryTheme.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isMultiPage ? 'Place Order - Page 1' : 'Place Order',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body:
          widget.service.formFields == null ||
              widget.service.formFields!.isEmpty
          ? _buildEmptyState()
          : _buildForm(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Theme.of(
                context,
              ).textTheme.bodySmall!.color?.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Form Not Available',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The order form for this service is not available yet. Please check back later or contact support.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall!.color,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    // Filter regular fields (non-file fields) for DynamicFormBuilder
    final regularFields = _page1Fields.where((f) => f.type != 'file').toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image (outside colored container for printing)
            if (_isPrintingCategory && widget.service.mainImage != null)
              _buildServiceImage(),
            if (_isPrintingCategory && widget.service.mainImage != null)
              const SizedBox(height: 20),

            // For printing category: wrap content in colored container
            if (_isPrintingCategory)
              _buildPrintingFormContent(regularFields)
            else
              _buildRegularFormContent(regularFields),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Page 1 indicator (current)
        Container(
          width: 30,
          height: 10,
          decoration: BoxDecoration(
            color: _categoryTheme.color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 8),
        // Page 2 indicator (inactive)
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    // Check if any fields in page 1 are file upload fields
    final hasFileFields = _page1Fields.any((f) => f.type == 'file');

    if (!hasFileFields) {
      return const SizedBox.shrink();
    }

    return FileUploadWidget(
      uploadedFiles: _uploadedFiles,
      onFilesChanged: _onFilesChanged,
    );
  }

  // Service image widget (outside colored container)
  Widget _buildServiceImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        widget.service.mainImage ?? widget.service.imageUrl ?? '',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.image_not_supported,
              size: 60,
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
          );
        },
      ),
    );
  }

  // Printing category form content with colored background
  Widget _buildPrintingFormContent(List<FormFieldModel> regularFields) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _categoryTheme.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Name
          Text(
            widget.service.name,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge!.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isMultiPage
                ? 'Fill in the details below (Page 1 of 2)'
                : 'Fill in the details below to place your order',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
          ),
          const SizedBox(height: 24),

          // Page indicator for multi-page forms
          if (_isMultiPage) _buildPageIndicator(),
          if (_isMultiPage) const SizedBox(height: 24),

          // Dynamic Form Fields for page 1
          DynamicFormBuilder(
            formFields: regularFields,
            formData: _formData,
            onFieldChanged: _onFieldChanged,
            focusColor: _categoryTheme.color,
          ),

          const SizedBox(height: 24),

          // File Upload Section (if page 1 has file fields)
          _buildFileUploadSection(),

          const SizedBox(height: 32),

          // Button: Next (for multi-page) or Submit Order (for single-page)
          PrimaryButton(
            text: _isMultiPage
                ? 'Next'
                : (_isSubmitting ? 'Submitting...' : 'Submit Order'),
            onPressed: () {
              if (!_isSubmitting) {
                _isMultiPage ? _goToNextPage() : _submitOrder();
              }
            },
          ),
        ],
      ),
    );
  }

  // Regular form content (for non-printing categories)
  Widget _buildRegularFormContent(List<FormFieldModel> regularFields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service Name
        Text(
          widget.service.name,
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge!.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isMultiPage
              ? 'Fill in the details below (Page 1 of 2)'
              : 'Fill in the details below to place your order',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodySmall!.color,
          ),
        ),
        const SizedBox(height: 24),

        // Page indicator for multi-page forms
        if (_isMultiPage) _buildPageIndicator(),
        if (_isMultiPage) const SizedBox(height: 24),

        // Dynamic Form Fields for page 1
        DynamicFormBuilder(
          formFields: regularFields,
          formData: _formData,
          onFieldChanged: _onFieldChanged,
          focusColor: _categoryTheme.color,
        ),

        const SizedBox(height: 24),

        // File Upload Section (if page 1 has file fields)
        _buildFileUploadSection(),

        const SizedBox(height: 32),

        // Button: Next (for multi-page) or Submit Order (for single-page)
        PrimaryButton(
          text: _isMultiPage
              ? 'Next'
              : (_isSubmitting ? 'Submitting...' : 'Submit Order'),
          onPressed: () {
            if (!_isSubmitting) {
              _isMultiPage ? _goToNextPage() : _submitOrder();
            }
          },
        ),
      ],
    );
  }
}
