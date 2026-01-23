import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/orders_provider.dart';
import '../../routes/route_names.dart';
import '../../theme/colors.dart';
import '../../Widgets/button.dart';

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
    _loadOrderDetails();
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
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
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Top Card with Service Info
                  _buildServiceInfoCard(order),
                  const SizedBox(height: 20),

                  // Price Breakdown
                  _buildPriceBreakdownCard(order),
                  const SizedBox(height: 20),

                  // Payment / Status Section
                  _buildPaymentSection(context, canUpload, order),
                ],
              ),
            ),
      bottomNavigationBar: (_isLoading || _error != null)
          ? null
          : _buildBottomBar(context, canUpload, order),
    );
  }

  Widget _buildServiceInfoCard(Map<String, dynamic> order) {
    // Extract title or fallback
    final title = order['title'] ?? 'Order';

    // Extract service name from serviceCategory or serviceName field
    final serviceName =
        order['serviceName'] ??
        order['serviceCategory'] ??
        order['category'] ??
        'Service';

    // Get reference number
    final refNumber = order['orderNumber'] ?? 'ORD-${order['id']}';

    // Get description from various possible fields
    final description =
        order['objectives'] ??
        order['description'] ??
        order['designerName'] ??
        'No description';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ref: $refNumber',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Description', description),
          const SizedBox(height: 12),
          _buildInfoRow('Deadline', _formatDate(order['deadline'])),
          const SizedBox(height: 12),
          _buildInfoRow('Status', _formatStatus(order['status'])),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownCard(Map<String, dynamic> order) {
    if (order['status'] == 'PENDING') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Order is pending pricing by admin',
            style: GoogleFonts.dmSans(
              color: Colors.grey,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Service Charge',
            '${order['totalPrice'] ?? '0.00'} DA',
          ),
          // Using total price as service charge for now as we don't have breakdown
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${order['totalPrice'] ?? '0.00'} DA',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.roseColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(
    BuildContext context,
    bool canUpload,
    Map<String, dynamic> order,
  ) {
    if (!canUpload) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.upload_file, color: AppColors.roseColor),
            title: Text(
              'Upload Payment Receipt',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(
                context,
                RouteNames.paymentUpload,
                arguments: order,
              );
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.credit_card, color: Colors.grey),
            title: Text(
              'ECCP Info',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.paymentInfo);
            },
          ),
        ],
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: PrimaryButton(
        text: 'Upload Payment Receipt',
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
            style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 14),
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

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(color: Colors.grey[600], fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
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
    if (status == null) return 'Unknown';
    // Convert PRICED to "Priced", AWAITING_PAYMENT_VALIDATION to "Awaiting Payment"
    return status
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
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
