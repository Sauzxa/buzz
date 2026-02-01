import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/orders_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../Widgets/order_drawer.dart';
import '../../Widgets/order_tracking_stepper.dart';
import '../../routes/route_names.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, String?> _invoiceDeadlineCache = {};

  @override
  void initState() {
    super.initState();
    // Re-fetch orders to ensure up-to-date status
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _fetchOrders();
      }
    });
  }

  Future<void> _fetchOrders() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user.id?.toString();

    if (userId == null || userId.isEmpty) {
      print(
        '⚠️ [ORDER_TRACKING] User ID is null or empty, cannot fetch orders',
      );
      return;
    }

    await Provider.of<OrdersProvider>(
      context,
      listen: false,
    ).fetchAllOrders(userId);

    // Fetch invoice deadlines for all orders
    if (mounted) {
      await _fetchInvoiceDeadlines();
    }
  }

  Future<void> _fetchInvoiceDeadlines() async {
    if (!mounted) return;

    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    for (final order in ordersProvider.allOrders) {
      if (!mounted) return;

      final orderId = order['id']?.toString();
      if (orderId != null && !_invoiceDeadlineCache.containsKey(orderId)) {
        try {
          await invoiceProvider.fetchInvoiceByOrderId(orderId);
          if (!mounted) return;

          if (invoiceProvider.invoice != null) {
            _invoiceDeadlineCache[orderId] =
                invoiceProvider.invoice!.paymentDeadline;
          }
        } catch (e) {
          print('⚠️ Failed to fetch invoice for order $orderId: $e');
        }
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            // Close drawer if open
            if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
              Navigator.pop(context);
            }

            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, RouteNames.home);
            }
          },
        ),
        title: Text(
          'Tracking',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge!.color,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: const OrderDrawer(currentRoute: RouteNames.orderTracking),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          if (ordersProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = ordersProvider.allOrders;

          // Sort orders by completion status: ready -> treatment -> received -> demande
          final sortedOrders = List<Map<String, dynamic>>.from(orders);
          sortedOrders.sort((a, b) {
            final priorityA = _getStatusPriority(a['status'] ?? 'PENDING');
            final priorityB = _getStatusPriority(b['status'] ?? 'PENDING');
            return priorityA.compareTo(priorityB);
          });

          return sortedOrders.isEmpty
              ? Center(
                  child: Text(
                    'No orders to track',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: sortedOrders.length,
                  itemBuilder: (context, index) {
                    final order = sortedOrders[index];
                    final orderId = order['id']?.toString();
                    final paymentDeadline = orderId != null
                        ? _invoiceDeadlineCache[orderId]
                        : null;
                    return _buildTrackingCard(order, paymentDeadline);
                  },
                );
        },
      ),
    );
  }

  Widget _buildTrackingCard(
    Map<String, dynamic> order,
    String? paymentDeadline,
  ) {
    final String status = order['status'] ?? 'PENDING';
    final Color categoryColor = _getCategoryColor(
      order['serviceCategory'] ?? '',
    );
    final currentStep = _getStepFromStatus(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            RouteNames.orderDetails,
            arguments: order,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category Badge + Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (order['serviceCategory'] ?? 'Service')
                          .toString()
                          .toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(order['createdAt']),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge!.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Status Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusLabel(status),
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Order Number & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['title'] ??
                              'COMMANDE N ${_getOrderNumber(order['orderNumber'])}',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge!.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (order['serviceName'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            order['serviceName'],
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall!.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (order['totalPrice'] != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '${order['totalPrice']} DA',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge!.color,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Deadline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deadline',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge!.color,
                    ),
                  ),
                  Text(
                    _formatDate(paymentDeadline ?? order['deadline']),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge!.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tracking Stepper
              OrderTrackingStepper(currentStep: currentStep),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Theme.of(context).textTheme.bodySmall!.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    if (category == null) return const Color(0xFF4CAF50);
    final cat = category.toLowerCase();
    if (cat.contains('graphic')) return const Color(0xFFFFC107);
    if (cat.contains('print')) return const Color(0xFF2196F3);
    if (cat.contains('audio')) return const Color(0xFF9C27B0);
    return const Color(0xFF4CAF50);
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'PRICED':
        return Colors.blue;
      case 'AWAITING_PAYMENT_VALIDATION':
        return Colors.purple;
      case 'IN_PROGRESS':
        return Colors.teal;
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'CANCELLED':
        return Colors.red;
      case 'DELIVERED':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'PRICED':
        return Icons.attach_money;
      case 'AWAITING_PAYMENT_VALIDATION':
        return Icons.pending_actions;
      case 'IN_PROGRESS':
        return Icons.work_outline;
      case 'COMPLETED':
        return Icons.check_circle_outline;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      case 'DELIVERED':
        return Icons.local_shipping_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'PRICED':
        return 'Priced';
      case 'AWAITING_PAYMENT_VALIDATION':
        return 'Awaiting Payment';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'DELIVERED':
        return 'Delivered';
      default:
        return status;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '--/--/----';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getOrderNumber(String? fullNumber) {
    if (fullNumber == null) return '';
    try {
      final parts = fullNumber.split('-');
      if (parts.isNotEmpty) {
        return int.parse(parts.last).toString();
      }
    } catch (_) {}
    return fullNumber;
  }

  int _getStatusPriority(String status) {
    // Priority: ready (0) -> treatment (1) -> received (2) -> demande (3)
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'DELIVERED':
        return 0; // Ready (most completed)
      case 'IN_PROGRESS':
        return 1; // Treatment
      case 'AWAITING_PAYMENT_VALIDATION':
        return 2; // Received
      case 'PENDING':
      case 'PRICED':
        return 3; // Demande (least completed)
      case 'CANCELLED':
        return 4; // Cancelled orders at the end
      default:
        return 5;
    }
  }

  int _getStepFromStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 0; // Demande
      case 'PRICED':
        return 0; // Still Demande phase (validated)
      case 'AWAITING_PAYMENT_VALIDATION':
        return 1; // Received (Payment received)
      case 'IN_PROGRESS':
        return 2; // Traitement
      case 'COMPLETED':
      case 'DELIVERED':
        return 3; // Ready
      default:
        return 0;
    }
  }
}
