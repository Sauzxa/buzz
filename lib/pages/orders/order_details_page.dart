import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/orders_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../routes/route_names.dart';
import '../../theme/colors.dart';
import '../../Widgets/button.dart';
import '../../l10n/app_localizations.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;

  // Constructor accepts the order map passed from navigation arguments
  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<String, dynamic>? _fullOrderDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Defer provider access until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadOrderDetails();
        _loadInvoice();
      }
    });
  }

  Future<void> _loadInvoice() async {
    final orderId = widget.order['id'].toString();
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );
    await invoiceProvider.fetchInvoiceByOrderId(orderId);
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ordersProvider = Provider.of<OrdersProvider>(
        context,
        listen: false,
      );
      final orderId = widget.order['id'].toString();
      final details = await ordersProvider.getOrderDetails(orderId);

      if (mounted) {
        setState(() {
          _fullOrderDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load order details: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use full details if loaded, otherwise use basic order data
    final order = _fullOrderDetails ?? widget.order;

    // Determine status to show appropriate buttons
    final String status = order['status'] ?? 'PENDING';
    final bool canUpload =
        status == 'PRICED' || status == 'AWAITING_PAYMENT_VALIDATION';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.translate('order_details_title') ??
              'Order Details',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.roseColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: GoogleFonts.dmSans(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOrderDetails,
                    child: Text(
                      AppLocalizations.of(context)?.translate('retry_btn') ??
                          'Retry',
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Consumer<InvoiceProvider>(
                builder: (context, invoiceProvider, child) {
                  return Column(
                    children: [
                      // Top Card with Service Info
                      _buildServiceInfoCard(order, invoiceProvider.invoice),
                      const SizedBox(height: 20),

                      // Price Breakdown
                      _buildPriceBreakdownCard(order),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
      bottomNavigationBar: (_isLoading || _error != null)
          ? null
          : _buildBottomBar(context, canUpload, order),
    );
  }

  Widget _buildServiceInfoCard(Map<String, dynamic> order, dynamic invoice) {
    // Extract title or fallback
    final title =
        order['title'] ??
        (AppLocalizations.of(context)?.translate('default_order_title') ??
            'Order');

    // Extract service name from serviceCategory or serviceName field
    final serviceName =
        order['serviceName'] ??
        order['serviceCategory'] ??
        order['category'] ??
        (AppLocalizations.of(context)?.translate('default_service_name') ??
            'Service');

    // Get reference number
    final refNumber = order['orderNumber'] ?? 'ORD-${order['id']}';

    // Get description from various possible fields
    final description =
        order['objectives'] ??
        order['description'] ??
        order['designerName'] ??
        (AppLocalizations.of(context)?.translate('no_description') ??
            'No description');

    // Get deadline from invoice if available, otherwise from order
    final deadline = invoice?.paymentDeadline ?? order['deadline'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    order['serviceCategory'],
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(order['serviceCategory']),
                  color: _getCategoryColor(order['serviceCategory']),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceName,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ref: $refNumber',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            AppLocalizations.of(context)?.translate('description_label') ??
                'Description',
            description,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            AppLocalizations.of(context)?.translate('payment_deadline_label') ??
                'Payment Deadline',
            _formatDate(deadline),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            AppLocalizations.of(context)?.translate('status_label') ?? 'Status',
            _formatStatus(order['status']),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownCard(Map<String, dynamic> order) {
    if (order['status'] == 'PENDING') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context)?.translate('order_pending_pricing') ??
                'Order is pending pricing by admin',
            style: GoogleFonts.dmSans(
              color: Theme.of(context).textTheme.bodySmall!.color,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
        if (invoiceProvider.isLoading) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (invoiceProvider.error != null) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(
                      context,
                    )?.translate('unable_load_pricing') ??
                    'Unable to load pricing details',
                style: GoogleFonts.dmSans(
                  color: Theme.of(context).textTheme.bodySmall!.color,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        final invoice = invoiceProvider.invoice;
        if (invoice == null) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(
                      context,
                    )?.translate('no_invoice_available') ??
                    'No invoice available',
                style: GoogleFonts.dmSans(
                  color: Theme.of(context).textTheme.bodySmall!.color,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              // Header
              Text(
                AppLocalizations.of(
                      context,
                    )?.translate('service_charges_title') ??
                    'Service Charges & Payments',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),

              // Pricing Breakdown Section
              _buildSectionHeader(
                AppLocalizations.of(
                      context,
                    )?.translate('pricing_breakdown_title') ??
                    '💰 Pricing Breakdown',
              ),
              _buildPriceRow(
                AppLocalizations.of(context)?.translate('subtotal_label') ??
                    'Subtotal',
                '${invoice.subtotal?.toStringAsFixed(2) ?? '0.00'} DA',
              ),
              _buildPriceRow(
                AppLocalizations.of(context)?.translate('discount_label') ??
                    'Discount',
                '-${invoice.discountAmount?.toStringAsFixed(2) ?? '0.00'} DA',
                valueColor: AppColors.greenColor,
              ),
              _buildPriceRow(
                AppLocalizations.of(context)?.translate('fee_label') ?? 'Fee',
                '+${invoice.fee?.toStringAsFixed(2) ?? '0.00'} DA',
              ),
              const Divider(),
              _buildPriceRow(
                AppLocalizations.of(context)?.translate('total_amount_label') ??
                    'Total Amount',
                '${invoice.totalAmount?.toStringAsFixed(2) ?? '0.00'} DA',
                isTotal: true,
              ),
              const SizedBox(height: 16),

              // Payment Details Section (if split payment)
              if (invoice.isSplitPayment) ...[
                const Divider(),
                _buildSectionHeader(
                  AppLocalizations.of(
                        context,
                      )?.translate('payment_plan_title') ??
                      '📋 Payment Plan',
                ),
                _buildPriceRow(
                  AppLocalizations.of(
                        context,
                      )?.translate('first_payment_label') ??
                      'First Payment (Versement)',
                  '${invoice.initialAmount?.toStringAsFixed(2) ?? '0.00'} DA',
                ),
                _buildPriceRow(
                  AppLocalizations.of(
                        context,
                      )?.translate('remaining_payment_label') ??
                      'Remaining Payment',
                  '${invoice.finalAmount?.toStringAsFixed(2) ?? '0.00'} DA',
                ),
                const SizedBox(height: 16),
              ],

              // Payment Status Section
              const Divider(),
              _buildSectionHeader(
                AppLocalizations.of(
                      context,
                    )?.translate('payment_status_header') ??
                    '✅ Payment Status',
              ),
              if (invoice.isSplitPayment) ...[
                _buildPriceRow(
                  AppLocalizations.of(
                        context,
                      )?.translate('initial_paid_label') ??
                      'Initial Paid',
                  '${invoice.initialAmountPaid?.toStringAsFixed(2) ?? '0.00'} DA',
                  valueColor: AppColors.greenColor,
                ),
                _buildPriceRow(
                  AppLocalizations.of(context)?.translate('final_paid_label') ??
                      'Final Paid',
                  '${invoice.finalAmountPaid?.toStringAsFixed(2) ?? '0.00'} DA',
                  valueColor: AppColors.greenColor,
                ),
              ],
              _buildPriceRow(
                AppLocalizations.of(context)?.translate('total_paid_label') ??
                    'Total Paid',
                '${invoice.totalPaidAmount?.toStringAsFixed(2) ?? '0.00'} DA',
                valueColor: AppColors.greenColor,
              ),
              _buildPriceRow(
                AppLocalizations.of(context)?.translate('still_owed_label') ??
                    'Still Owed',
                '${invoice.remainingAmount?.toStringAsFixed(2) ?? '0.00'} DA',
                valueColor: (invoice.remainingAmount ?? 0) > 0
                    ? Colors.orange
                    : AppColors.greenColor,
                isTotal: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleLarge!.color,
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    bool canUpload,
    Map<String, dynamic> order,
  ) {
    if (!canUpload) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: PrimaryButton(
        text:
            AppLocalizations.of(context)?.translate('upload_receipt_btn') ??
            'Upload Payment Receipt',
        onPressed: () {
          Navigator.pushNamed(
            context,
            RouteNames.paymentUpload,
            arguments: order,
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              color: Theme.of(context).textTheme.bodySmall!.color,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color:
                  valueColor ??
                  (isTotal
                      ? AppColors.roseColor
                      : Theme.of(context).textTheme.titleLarge!.color),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '--';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatStatus(String? status) {
    if (status == null)
      return AppLocalizations.of(context)?.translate('unknown_status') ??
          'Unknown';
    return AppLocalizations.of(
          context,
        )?.translate('status_${status.toLowerCase()}') ??
        status;
  }

  Color _getCategoryColor(String? category) {
    if (category == null) return AppColors.greenColor;
    final cat = category.toLowerCase();
    if (cat.contains('graphic')) return AppColors.GraphicDesing;
    if (cat.contains('print')) return AppColors.Printing;
    if (cat.contains('audio') || cat.contains('visual'))
      return AppColors.AudioVisual;
    return AppColors.greenColor;
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.design_services;
    final cat = category.toLowerCase();
    if (cat.contains('graphic')) return Icons.design_services;
    if (cat.contains('print')) return Icons.print;
    if (cat.contains('audio') || cat.contains('visual')) return Icons.videocam;
    return Icons.design_services;
  }
}
