import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/colors.dart';
import '../../Widgets/button.dart';
import '../../l10n/app_localizations.dart';
import '../chat/chat_screen.dart';

class InvoiceUploadedSuccess extends StatelessWidget {
  final Map<String, dynamic>? order;

  const InvoiceUploadedSuccess({Key? key, this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                    AppLocalizations.of(
                          context,
                        )?.translate('confirmation_title') ??
                        'Confirmation',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48), // Placeholder for balance
                ],
              ),
            ),

            const SizedBox(height: 20),

            // White Container Body
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Success Icon/Image
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.pink.shade50,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/others/invoiceSucces.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Title
                        Text(
                          AppLocalizations.of(
                                context,
                              )?.translate('invoice_uploaded_title') ??
                              'Invoice Uploaded',
                          style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge!.color,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Success Message
                        Text(
                          AppLocalizations.of(
                                context,
                              )?.translate('invoice_uploaded_msg') ??
                              'Your invoice has been successfully uploaded.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: const Color(0xFF8D8D8D),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Contact Info
                        Text(
                          AppLocalizations.of(
                                context,
                              )?.translate('call_info_msg') ??
                              'For any info call (+1) 999 999 999',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: const Color(0xFF8D8D8D),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Divider
                        Divider(
                          color: Theme.of(context).dividerColor,
                          thickness: 1,
                        ),

                        const SizedBox(height: 20),

                        // Working Hours
                        Text(
                          AppLocalizations.of(
                                context,
                              )?.translate('working_hours') ??
                              'Working Hour: 7PM - 8AM',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge!.color,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Buzz Logo and Contact Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              // Buzz Logo
                              Image.asset(
                                'assets/Logos/PinkLogo.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),

                              const SizedBox(height: 20),

                              // Action Buttons Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Call Button
                                  _buildActionButton(
                                    icon: Icons.call,
                                    color: const Color(0xFFFFE4E4),
                                    iconColor: AppColors.roseColor,
                                    onTap: () async {
                                      final Uri launchUri = Uri(
                                        scheme: 'tel',
                                        path: '0555496574',
                                      );
                                      try {
                                        if (await canLaunchUrl(launchUri)) {
                                          await launchUrl(launchUri);
                                        }
                                      } catch (e) {
                                        debugPrint(e.toString());
                                      }
                                    },
                                  ),

                                  const SizedBox(width: 16),

                                  // Chat Button
                                  _buildActionButton(
                                    icon: Icons.chat_bubble_rounded,
                                    color: const Color(0xFFE0F2FE),
                                    iconColor: const Color(0xFF0EA5E9),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ChatScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Go to Homepage Button
                        PrimaryButton(
                          text:
                              AppLocalizations.of(
                                context,
                              )?.translate('go_home_btn') ??
                              'Go to Homepage',
                          onPressed: () {
                            // Navigate to home and remove all previous routes
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}
