import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/orders_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../Widgets/order_drawer.dart';
import '../../routes/route_names.dart';
import '../../theme/colors.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, Map<String, dynamic>> _invoiceCache = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _fetchHistory();
      }
    });
  }

  Future<void> _fetchHistory() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user.id?.toString();

    if (userId == null || userId.isEmpty) {
      print('⚠️ [ORDER_HISTORY] User ID is null or empty, cannot fetch orders');
      return;
    }

    if (!mounted) return;
    await Provider.of<OrdersProvider>(
      context,
      listen: false,
    ).fetchArchivedOrders(userId);

    // Fetch invoices for all archived orders
    if (mounted) {
      await _fetchInvoicesForOrders();
    }
  }

  Future<void> _fetchInvoicesForOrders() async {
    if (!mounted) return;

    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    for (final order in ordersProvider.archivedOrders) {
      if (!mounted) return; // Check before each iteration

      final orderId = order['id']?.toString();
      if (orderId != null && !_invoiceCache.containsKey(orderId)) {
        try {
          await invoiceProvider.fetchInvoiceByOrderId(orderId);
          if (!mounted) return; // Check after async operation

          if (invoiceProvider.invoice != null) {
            _invoiceCache[orderId] = {
              'serviceName': invoiceProvider.invoice!.serviceName,
              'finalAmount': invoiceProvider.invoice!.finalAmount,
              'paymentValidatedAt':
                  invoiceProvider.invoice!.paymentValidatedAt?.isNotEmpty ==
                      true
                  ? invoiceProvider.invoice!.paymentValidatedAt!.last
                  : null,
            };
          }
        } catch (e) {
          print('⚠️ Failed to fetch invoice for order $orderId: $e');
        }
      }
    }

    if (mounted) {
      setState(() {}); // Refresh UI with invoice data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
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
          'History',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: const OrderDrawer(currentRoute: RouteNames.orderHistory),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          if (ordersProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allOrders = ordersProvider.archivedOrders;

          // Filter to only show COMPLETED and CANCELLED orders
          final orders = allOrders.where((order) {
            final status = order['status']?.toString().toUpperCase();
            return status == 'COMPLETED' || status == 'CANCELLED';
          }).toList();

          return orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No completed orders yet',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your order history will appear here',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderId = order['id']?.toString();
                    final invoiceData = orderId != null
                        ? _invoiceCache[orderId]
                        : null;
                    return _buildHistoryCard(order, invoiceData);
                  },
                );
        },
      ),
    );
  }

  Widget _buildHistoryCard(
    Map<String, dynamic> order,
    Map<String, dynamic>? invoiceData,
  ) {
    final serviceName =
        invoiceData?['serviceName'] ?? order['category'] ?? 'Service';
    final finalAmount = invoiceData?['finalAmount'] ?? order['totalPrice'] ?? 0;
    final paymentValidatedAt = invoiceData?['paymentValidatedAt'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    serviceName,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${finalAmount.toStringAsFixed(2)} DA',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.roseColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.roseColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Commande ${order['id']}', // or orderNumber
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order['status']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusDisplay(order['status'] ?? ''),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paymentValidatedAt != null
                          ? 'EST ${_formatDate(paymentValidatedAt)}'
                          : 'EST ${_formatDate(order['deadline'])}',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      _formatDate(order['updatedAt']),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Details Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.orderDetails,
                    arguments: order,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roseColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'View Details',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      case 'REFUSED':
        return 'Refused';
      default:
        return status;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'COMPLETED':
        return AppColors.greenColor;
      case 'CANCELLED':
        return Colors.grey;
      case 'REFUSED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
