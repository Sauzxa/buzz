import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../pages/chat/chat_screen.dart';
import '../../Widgets/notification_popup.dart';
import 'faq_page.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  void _showNotificationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFE91E63,
      ), // Pink background mainly for the top
      body: Stack(
        children: [
          // 1. Header (Custom AppBar)
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
                    'Contact Us',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Notification Icon with Badge
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.orange, // Orange dot
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: _showNotificationBottomSheet,
                  ),
                ],
              ),
            ),
          ),

          // 2. White Container Body
          Column(
            children: [
              const SizedBox(height: 100), // Spacing for header
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
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // Title
                      Text(
                        'Contact Us',
                        style: GoogleFonts.dmSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge!.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      Text(
                        'Please choose what types of support do you\nneed and let us know.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          color: Theme.of(context).textTheme.bodySmall!.color,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Grid
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate aspect ratio to make cards look like the design (taller)
                            // Width is (screen width - padding - spacing) / 2
                            // Height needs to fit content comfortable.
                            // 0.8 looks good.
                            return GridView.count(
                              crossAxisCount: 2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.8,
                              children: [
                                _buildContactCard(
                                  icon: Icons
                                      .chat_bubble_rounded, // Chat icon from design is roundish
                                  iconColor: const Color(0xFF4CAF50),
                                  bgColor: const Color(
                                    0xFFEBFAEB,
                                  ), // Very light green
                                  title: 'Support Chat',
                                  subtitle: '24x7 Online Support',
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
                                _buildContactCard(
                                  icon: Icons.call_rounded,
                                  iconColor: const Color(0xFFFF7043),
                                  bgColor: const Color(
                                    0xFFFFF5F2,
                                  ), // Very light orange/peach
                                  title: 'Call Center',
                                  subtitle: '24x7 Customer Service',
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
                                _buildContactCard(
                                  icon: Icons.email_rounded,
                                  iconColor: const Color(0xFFAB47BC),
                                  bgColor: const Color(
                                    0xFFF9F0FC,
                                  ), // Very light purple
                                  title: 'Email',
                                  subtitle: 'buzz@gmail.com',
                                  onTap: () async {
                                    final Uri launchUri = Uri(
                                      scheme: 'mailto',
                                      path: 'buzz@gmail.com',
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
                                _buildContactCard(
                                  icon: Icons.help_outline_rounded,
                                  iconColor: const Color(0xFFFFB300),
                                  bgColor: const Color(
                                    0xFFFFFDE7,
                                  ), // Very light yellow
                                  title: 'FAQ',
                                  subtitle: '+50 Answers',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const FaqPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Bottom Button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Theme.of(context).cardColor,
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            minimumSize: const Size(double.infinity, 56),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Go to Homepage',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleLarge!.color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                                color: Theme.of(context).iconTheme.color,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          // No shadow in the flat modern look or very subtle
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                color: Theme.of(context).textTheme.bodySmall!.color,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
