import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/orders_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/invoice_service.dart';
import '../../Widgets/order_drawer.dart';
import '../../Widgets/order_card.dart';
import '../../routes/route_names.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, String?> _invoiceDeadlineCache = {};

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
    final invoiceService = InvoiceService();

    for (final order in ordersProvider.archivedOrders) {
      if (!mounted) return; // Check before each iteration

      final orderId = order['id']?.toString();
      if (orderId != null && !_invoiceDeadlineCache.containsKey(orderId)) {
        try {
          final invoice = await invoiceService.getInvoiceByOrderId(orderId);
          if (!mounted) return; // Check after async operation

          if (invoice != null) {
            _invoiceDeadlineCache[orderId] = invoice.paymentDeadline;
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
          'History',
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
                      Icon(
                        Icons.history,
                        size: 80,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall!.color?.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No completed orders yet',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your order history will appear here',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall!.color?.withOpacity(0.6),
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
                    final paymentDeadline = orderId != null
                        ? _invoiceDeadlineCache[orderId]
                        : null;
                    return OrderCard(
                      order: order,
                      paymentDeadline: paymentDeadline,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.orderDetails,
                          arguments: order,
                        );
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}
