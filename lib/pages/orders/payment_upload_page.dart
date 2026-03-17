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
  Map<String, dynamic>? _invoiceData;

  @override
  void initState() {
    super.initState();
    _fetchInvoice();
  }

  // Determine if this is initial or final payment
  bool get _isFinalPayment =>
      widget.order['status']?.toString().toUpperCase() ==
      'AWAITING_FINAL_PAYMENT';

  bool get _isSplitPayment =>
      _invoiceData?['paymentMethodType']?.toString().toUpperCase() ==
      'SPLIT_PAYMENT';

  double? get _paymentAmount {
    if (_invoiceData == null) return null;
    if (_isFinalPayment) {
      return _invoiceData!['finalAmount']?.toDouble();
    } else {
      // Initial payment
      if (_isSplitPayment) {
        return _invoiceData!['initialAmount']?.toDouble();
      } else {
        // Full payment
        return _invoiceData!['totalAmount']?.toDouble();
      }
    }
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
          _invoiceData = invoice.toJson();
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

      // Extract user-friendly error message
      String errorMessage =
          AppLocalizations.of(context)?.translate('upload_failed') ??
          'Upload failed';

      final errorString = e.toString();
      if (errorString.contains('Exception:')) {
        // Extract the actual message after "Exception: "
        errorMessage = errorString.replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
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
          _isFinalPayment
              ? (AppLocalizations.of(
                      context,
                    )?.translate('upload_final_payment_title') ??
                    'Upload Final Payment')
              : (AppLocalizations.of(
                      context,
                    )?.translate('upload_payment_title') ??
                    'Upload Payment'),
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
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Payment Type Info
                  if (_isSplitPayment)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isFinalPayment
                                  ? (AppLocalizations.of(
                                          context,
                                        )?.translate('final_payment_info') ??
                                        'This is your final payment (50%)')
                                  : (AppLocalizations.of(
                                          context,
                                        )?.translate('initial_payment_info') ??
                                        'This is your initial payment (50%)'),
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_isSplitPayment) const SizedBox(height: 16),

                  // Payment Amount
                  if (_paymentAmount != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.roseColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isFinalPayment
                                ? (AppLocalizations.of(
                                        context,
                                      )?.translate('final_amount_label') ??
                                      'Final Amount:')
                                : (AppLocalizations.of(context)?.translate(
                                        _isSplitPayment
                                            ? 'initial_amount_label'
                                            : 'total_amount_label',
                                      ) ??
                                      (_isSplitPayment
                                          ? 'Initial Amount:'
                                          : 'Total Amount:')),
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${_paymentAmount!.toStringAsFixed(2)} DH',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.roseColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_paymentAmount != null) const SizedBox(height: 16),

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
    if (widget.order['paymentMethod'] == 'ESPECE') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
                  context,
                )?.translate('cannot_upload_invoice_espece') ??
                "You can't upload invoice for ESPECE order type",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
