import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/orders_provider.dart';
import '../../providers/user_provider.dart';
import '../../Widgets/order_drawer.dart';
import '../../Widgets/order_tracking_stepper.dart';
import '../../routes/route_names.dart';
import '../../theme/colors.dart';
import '../../Widgets/button.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    ).fetchActiveOrders(userId);
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
          onPressed: () =>
              Navigator.pushReplacementNamed(context, RouteNames.home),
        ),
        title: Text(
          'Tracking',
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
      endDrawer: const OrderDrawer(currentRoute: RouteNames.orderTracking),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          if (ordersProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = ordersProvider.activeOrders;

          return Column(
            children: [
              Expanded(
                child: orders.isEmpty
                    ? Center(
                        child: Text(
                          'No orders to track',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return _buildTrackingCard(order);
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: PrimaryButton(
                  text: 'Start ordering',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, RouteNames.home);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrackingCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'PENDING';
    final currentStep = _getStepFromStatus(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
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
                Text(
                  order['title'] ?? order['category'] ?? 'Service',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${order['totalPrice'] ?? 0} DA',
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
                    'Commande ${order['id']}',
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
                    Text(
                      _getStatusDisplay(status),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'EST ${_formatDate(order['deadline'])}',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(order['createdAt']),
              style: GoogleFonts.dmSans(fontSize: 10, color: Colors.black54),
            ),

            const SizedBox(height: 20),
            OrderTrackingStepper(currentStep: currentStep),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.info_outline, size: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  int _getStepFromStatus(String status) {
    switch (status) {
      case 'PENDING':
        return 0; // Demande
      case 'PRICED':
        return 0; // Still Demande phase (validated)
      case 'AWAITING_PAYMENT_VALIDATION':
        return 1; // Received (Payment received)
      case 'IN_PROGRESS':
        return 2; // Traitement
      case 'COMPLETED':
        return 3; // Ready
      default:
        return 0;
    }
  }

  String _getStatusDisplay(String status) {
    if (status == 'AWAITING_PAYMENT_VALIDATION') {
      return 'Received waiting for payment';
    }
    return status.replaceAll('_', ' ').toLowerCase(); // basic clean up
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
}
