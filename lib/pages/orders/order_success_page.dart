import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/button.dart';
import '../../routes/route_names.dart';
import '../../utils/category_theme.dart';
import 'order_details_page.dart';

class OrderSuccessPage extends StatelessWidget {
  final String? categoryName;
  final int? orderId;

  const OrderSuccessPage({Key? key, this.categoryName, this.orderId})
    : super(key: key);

  CategoryTheme get _categoryTheme =>
      CategoryTheme.fromCategoryName(categoryName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _categoryTheme.color,
        elevation: 0,
        leading: const SizedBox(), // Remove back button
        title: Text(
          'Order Placed',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Category Logo (replaces check icon)
                    Image.asset(
                      _categoryTheme.logoPath,
                      width: 180,
                      height: 180,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if logo not found - show check icon
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _categoryTheme.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: 80,
                            color: _categoryTheme.color,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Success Message
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          Text(
                            'Procedure Completed',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Successfully',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your order has been placed successfully. We will contact you soon with further details.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Go to Homepage Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  PrimaryButton(
                    text: 'Go to Homepage',
                    onPressed: () {
                      // Navigate to home and remove all previous routes
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteNames.home,
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      if (orderId != null) {
                        // Navigate to order details page with minimal order data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailsPage(
                              order: {
                                'id': orderId,
                                // The page will fetch full details using orderId
                              },
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order details not available'),
                            backgroundColor: _categoryTheme.color,
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Order Details',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _categoryTheme.color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: _categoryTheme.color,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
