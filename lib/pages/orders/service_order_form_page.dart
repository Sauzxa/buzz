import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/service_model.dart';
import '../../Widgets/button.dart';
import '../../Widgets/dynamic_form_builder.dart';
import '../../Widgets/file_upload_widget.dart';
import '../../theme/colors.dart';
import 'order_success_page.dart';

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
  bool _isSubmitting = false;

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

  bool _validateForm() {
    if (widget.service.formFields == null ||
        widget.service.formFields!.isEmpty) {
      return false;
    }

    for (var field in widget.service.formFields!) {
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

  Future<void> _submitOrder() async {
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Implement actual API call to submit order
      // For now, simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Prepare order data
      final orderData = {
        'serviceId': widget.service.id,
        'formData': _formData,
        'files': _uploadedFiles.map((f) => f.path).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('Order submitted: $orderData');

      // Navigate to success page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit order: ${e.toString()}'),
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
        backgroundColor: AppColors.greenColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Place Order',
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
            Icon(Icons.description_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Form Not Available',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The order form for this service is not available yet. Please check back later or contact support.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
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
              'Fill in the details below to place your order',
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Dynamic Form Fields
            DynamicFormBuilder(
              formFields: widget.service.formFields!,
              formData: _formData,
              onFieldChanged: _onFieldChanged,
            ),

            const SizedBox(height: 24),

            // File Upload Section
            FileUploadWidget(
              uploadedFiles: _uploadedFiles,
              onFilesChanged: _onFilesChanged,
            ),

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
    );
  }
}
