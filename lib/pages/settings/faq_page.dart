import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  // Track which FAQ items are expanded
  final Set<int> _expandedItems = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE91E63), // Pink background
      body: Column(
        children: [
          // Header with back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Arrow Button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'FAQs',
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  // Empty container to balance the row
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Main content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'FAQ',
                      style: GoogleFonts.dmSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find important information and update about\nany recent changes and fees here.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // General Section
                    _buildSectionTitle('General'),
                    const SizedBox(height: 16),
                    _buildFaqItem(
                      index: 0,
                      question: 'How to contact with designers ?',
                      answer:
                          'You can contact designers directly through the chat feature in the app. Simply navigate to the service you\'re interested in, view the designer\'s profile, and click on the "Message" button to start a conversation.',
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(
                      index: 1,
                      question: 'How to change my selected order ?',
                      answer:
                          'To modify your order, go to the "Orders" section in your profile. Select the order you want to change and click on "Edit Order" if it\'s still in pending status. Please note that orders cannot be modified once they\'re in progress.',
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(
                      index: 2,
                      question: 'What is cost of each item ?',
                      answer:
                          'The cost of each item varies depending on the service type, designer experience, and project complexity. You can view detailed pricing on each service page before placing an order. All prices are displayed in your local currency.',
                    ),
                    const SizedBox(height: 32),

                    // Contact Section
                    _buildSectionTitle('Contact'),
                    const SizedBox(height: 16),
                    _buildFaqItem(
                      index: 3,
                      question: 'What is the customer care number?',
                      answer:
                          'Our customer care team is available at +1 (555) 123-4567 from Monday to Friday, 9 AM to 6 PM EST. You can also reach us through email at support@buzz.com or use the in-app chat support feature.',
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(
                      index: 4,
                      question: 'Can I Cancel the order after one week?',
                      answer:
                          'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.',
                      isExpanded:
                          true, // This one is shown expanded in the mockup
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(
                      index: 5,
                      question: 'How to call any service now?',
                      answer:
                          'To quickly request a service, tap on the "Services" tab from the home screen, browse or search for the service you need, select your preferred designer, and click "Order Now" to place your request immediately.',
                    ),
                    const SizedBox(height: 32),

                    // Go to Homepage Button
                    Center(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Go to Homepage',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFE91E63),
      ),
    );
  }

  Widget _buildFaqItem({
    required int index,
    required String question,
    required String answer,
    bool isExpanded = false,
  }) {
    final bool expanded = _expandedItems.contains(index) || isExpanded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.black54,
          ),
          onExpansionChanged: (isExpanding) {
            setState(() {
              if (isExpanding) {
                _expandedItems.add(index);
              } else {
                _expandedItems.remove(index);
              }
            });
          },
          children: [
            Text(
              answer,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
