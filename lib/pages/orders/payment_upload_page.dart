import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/invoice_service.dart';
import '../../theme/colors.dart';
import '../../Widgets/button.dart';

class PaymentUploadPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const PaymentUploadPage({Key? key, required this.order}) : super(key: key);

  @override
  State<PaymentUploadPage> createState() => _PaymentUploadPageState();
}

class _PaymentUploadPageState extends State<PaymentUploadPage> {
  final InvoiceService _invoiceService = InvoiceService();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;
  String? _invoiceId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInvoice();
  }

  Future<void> _fetchInvoice() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final invoice = await _invoiceService.getInvoiceByOrderId(
        widget.order['id'].toString(),
      );
      if (invoice != null) {
        setState(() {
          _invoiceId = invoice.id.toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No invoice found for this order yet.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch invoice info: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _uploadProof() async {
    if (_imageFile == null || _invoiceId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _invoiceService.uploadPaymentProof(_invoiceId!, _imageFile!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment receipt uploaded successfully!'),
          backgroundColor: AppColors.greenColor,
        ),
      );

      // Navigate back to orders list to refresh status
      Navigator.pop(context); // Pop upload page
      Navigator.pop(context); // Pop details page (if came from there)
      // Ideally trigger a refresh on the orders list, but provider should handle if we revisit
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Payment',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.roseColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading && _invoiceId == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Upload your payment receipt for Order #${widget.order['orderNumber'] ?? widget.order['id']}',
                    style: GoogleFonts.dmSans(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Image Preview Area
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showImageSourceSheet(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tap to select image',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  PrimaryButton(
                    text: _isLoading ? 'Uploading...' : 'Submit Receipt',
                    onPressed: (_imageFile != null && !_isLoading)
                        ? _uploadProof
                        : () => _showImageSourceSheet(context),
                  ),
                ],
              ),
            ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
