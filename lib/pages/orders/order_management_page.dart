import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/orders_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../Widgets/order_drawer.dart';
import '../../Widgets/order_card.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../routes/route_names.dart';
import '../../theme/colors.dart';
import '../settings/profile/edit_profile_settings.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({Key? key}) : super(key: key);

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2; // Orders tab is index 2
  final Map<String, String?> _invoiceDeadlineCache = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _fetchOrders();
      }
    });
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user.id?.toString();

    if (userId == null || userId.isEmpty) {
      print(
        '⚠️ [ORDER_MANAGEMENT] User ID is null or empty, cannot fetch orders',
      );
      return;
    }

    if (!mounted) return;
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
      if (!mounted) return; // Check before each iteration

      final orderId = order['id']?.toString();
      if (orderId != null && !_invoiceDeadlineCache.containsKey(orderId)) {
        try {
          await invoiceProvider.fetchInvoiceByOrderId(orderId);
          if (!mounted) return; // Check after async operation

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
      setState(() {}); // Refresh UI with invoice data
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else if (index == 1) {
      // Search - Navigate to home
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else if (index == 2) {
      // Already on orders page
    } else if (index == 3) {
      // Profile
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditProfileSettings()),
      );
    } else if (index == 4) {
      Navigator.pushNamed(context, RouteNames.chat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user.id?.toString();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50], // Light background
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
      ),
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
          'My orders',
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
      endDrawer: const OrderDrawer(currentRoute: RouteNames.orderManagement),
      body: userId == null || userId.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User not logged in',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please log in to view your orders',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : Consumer<OrdersProvider>(
              builder: (context, ordersProvider, child) {
                if (ordersProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (ordersProvider.error != null) {
                  return Center(child: Text('Error: ${ordersProvider.error}'));
                }

                final orders = ordersProvider.allOrders;

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Swipe hint
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swipe, size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Text(
                            'swipe on an item to delete',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Orders List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              // Navigate to details
                              Navigator.pushNamed(
                                context,
                                RouteNames.orderDetails,
                                arguments: order,
                              );
                            },
                            onUploadReceipt: () {
                              // Only navigate if upload is allowed (status check in Card, but logic here too)
                              Navigator.pushNamed(
                                context,
                                RouteNames.paymentUpload,
                                arguments: order,
                              );
                            },
                            confirmDismiss: (direction) async {
                              // Show confirmation dialog
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                        contentPadding: const EdgeInsets.all(
                                          24,
                                        ),
                                        title: Text(
                                          'Cancel Order',
                                          style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                        content: Text(
                                          'Are you sure you want to cancel this order?',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        actionsPadding:
                                            const EdgeInsets.fromLTRB(
                                              24,
                                              0,
                                              24,
                                              24,
                                            ),
                                        actions: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                      dialogContext,
                                                    ).pop(false);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    foregroundColor:
                                                        Colors.grey[800],
                                                    elevation: 0,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'No',
                                                    style: GoogleFonts.dmSans(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                      dialogContext,
                                                    ).pop(true);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.roseColor,
                                                    foregroundColor:
                                                        Colors.white,
                                                    elevation: 0,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Yes, Cancel',
                                                    style: GoogleFonts.dmSans(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ) ??
                                  false;
                            },
                            onDismissed: (direction) async {
                              // Capture ScaffoldMessenger before async operations
                              final messenger = ScaffoldMessenger.of(context);
                              final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false,
                              );
                              final userId = userProvider.user.id?.toString();

                              if (userId != null && userId.isNotEmpty) {
                                final success = await ordersProvider
                                    .cancelOrder(
                                      order['id'].toString(),
                                      userId,
                                    );

                                if (success) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Order cancelled successfully',
                                      ),
                                      backgroundColor: AppColors.greenColor,
                                    ),
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to cancel order'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('User not logged in'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
