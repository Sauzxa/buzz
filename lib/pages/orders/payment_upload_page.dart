import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/invoice_service.dart';
import '../../theme/colors.dart';
import '../../Widgets/button.dart';
import '../../l10n/app_localizations.dart';
import 'invoice_uploaded_success.dart';

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
          _error =
              AppLocalizations.of(context)?.translate('no_invoice_found') ??
              'No invoice found for this order yet.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error =
            '${AppLocalizations.of(context)?.translate('failed_fetch_invoice') ?? 'Failed to fetch invoice info'}: $e';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)?.translate('error_picking_image') ?? 'Error picking image'}: $e',
          ),
        ),
      );
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

      // Navigate to success page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InvoiceUploadedSuccess(order: widget.order),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)?.translate('upload_failed') ?? 'Upload failed'}: $e',
          ),
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
          AppLocalizations.of(context)?.translate('upload_payment_title') ??
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
                    '${AppLocalizations.of(context)?.translate('upload_receipt_instruction') ?? 'Upload your payment receipt for Order #'} ${widget.order['orderNumber'] ?? widget.order['id']}',
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
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
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
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 64,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color
                                        ?.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppLocalizations.of(
                                          context,
                                        )?.translate('tap_select_image') ??
                                        'Tap to select image',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodySmall!.color,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  PrimaryButton(
                    text: _isLoading
                        ? (AppLocalizations.of(
                                context,
                              )?.translate('uploading_status') ??
                              'Uploading...')
                        : (AppLocalizations.of(
                                context,
                              )?.translate('submit_receipt_btn') ??
                              'Submit Receipt'),
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
              title: Text(
                AppLocalizations.of(context)?.translate('gallery_option') ??
                    'Gallery',
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(
                AppLocalizations.of(context)?.translate('camera_option') ??
                    'Camera',
              ),
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
