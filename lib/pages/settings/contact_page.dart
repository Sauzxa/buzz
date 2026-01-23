import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:buzz/pages/chat/support_chat_page.dart'; // Adjust import if needed based on actual location

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Contact Us'),
        centerTitle: true,
        backgroundColor: const Color(0xFFE91E63), // Pink color from design
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(
          color: Colors.white,
        ), // Or remove if not needed, but standard navigation usually has it
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {}, // Notification action
          ),
        ],
      ),
      body: Column(
        children: [
          // Header curve extension if needed, or just plain background.
          // The design shows a curved container. Let's try to mimic a simple version or just standard background.
          // For now, standard white background as per requested "respect the design 100%" implies looking at the image functionality mostly.
          // Actually, looking at the image, there is a big pink header area and the white card overlaps it.
          // To achieve that exactly might require a Stack or custom shape.
          // Let's stick to a clean implementation first. If strict 100% visual match is needed, I'll use a Stack.
          // Let's use a Stack to get the pink background top.
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE91E63),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              // box shadow if needed
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                const Text(
                                  'Contact Us',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Please choose what types of support do you\nneed and let us know.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Expanded(
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20,
                                    childAspectRatio: 0.85,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    children: [
                                      _buildContactCard(
                                        icon: Icons.chat_bubble,
                                        iconColor: Colors.white,
                                        bgColor: const Color(
                                          0xFFE8F5E9,
                                        ), // Light green
                                        iconBgColor: const Color(0xFF4CAF50),
                                        title: 'Support Chat',
                                        subtitle: '24x7 Online Support',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SupportChatPage(),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildContactCard(
                                        icon: Icons.call,
                                        iconColor: Colors.white,
                                        bgColor: const Color(
                                          0xFFFFF3E0,
                                        ), // Light orange
                                        iconBgColor: const Color(0xFFFF5722),
                                        title: 'Call Center',
                                        subtitle: '24x7 Customer Service',
                                        onTap: () async {
                                          final Uri launchUri = Uri(
                                            scheme: 'tel',
                                            path: '0555496574',
                                          );
                                          if (await canLaunchUrl(launchUri)) {
                                            await launchUrl(launchUri);
                                          }
                                        },
                                      ),
                                      _buildContactCard(
                                        icon: Icons.email,
                                        iconColor: Colors.white,
                                        bgColor: const Color(
                                          0xFFF3E5F5,
                                        ), // Light purple
                                        iconBgColor: const Color(0xFF9C27B0),
                                        title: 'Email',
                                        subtitle:
                                            'admin@shifty.com', // Using design text or requested? Request said "send email to feraouf91@gmail.com"
                                        onTap: () async {
                                          final Uri launchUri = Uri(
                                            scheme: 'mailto',
                                            path: 'feraouf91@gmail.com',
                                          );
                                          if (await canLaunchUrl(launchUri)) {
                                            await launchUrl(launchUri);
                                          }
                                        },
                                      ),
                                      _buildContactCard(
                                        icon: Icons.help_outline,
                                        iconColor: Colors.white,
                                        bgColor: const Color(
                                          0xFFFFFDE7,
                                        ), // Light yellow
                                        iconBgColor: const Color(0xFFFFC107),
                                        title: 'FAQ',
                                        subtitle: '+50 Answers',
                                        onTap: () {
                                          // Placeholder as requested
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // Navigate to home logic.
                                      // Usually removing all routes until home or pushing home.
                                      // Assuming '/' is home or pop until first.
                                      Navigator.of(
                                        context,
                                      ).popUntil((route) => route.isFirst);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      side: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 20,
                                      ),
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Go to Homepage',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Colors.black,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
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
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(
                icon,
                color:
                    iconBgColor, // Based on image, icon has color, bg is light
                size: 28,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
