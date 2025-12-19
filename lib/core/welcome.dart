import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import 'homePage.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startSwipeAnimation() {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
    });

    _controller.forward().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            'assets/icons/4Cadr.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.grid_view, color: Colors.grey);
            },
          ),
        ),
        title: Image.asset(
          'assets/Logos/PinkLogo.png',
          height: 35,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              'BUZZ',
              style: GoogleFonts.dmSans(
                color: AppColors.roseColor,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/icons/Notification.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey,
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              // Detect upward swipe (negative delta)
              if (details.delta.dy < -5 && !_isAnimating) {
                _startSwipeAnimation();
              }
            },
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value.dy * screenHeight),
                  child: child,
                );
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: Image.asset(
                    'assets/home/welcome.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.roseColor,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.pan_tool_outlined,
                                color: Colors.white,
                                size: 80,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'SWIPE UP',
                                style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
