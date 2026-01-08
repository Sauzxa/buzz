import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/service_model.dart';
import '../../Widgets/button.dart';
import '../../Widgets/skeleton_loader.dart';
import '../../theme/colors.dart';
import '../orders/service_order_form_page.dart';

class ServiceChoosingPage extends StatefulWidget {
  final ServiceModel service;

  const ServiceChoosingPage({Key? key, required this.service})
    : super(key: key);

  @override
  State<ServiceChoosingPage> createState() => _ServiceChoosingPageState();
}

class _ServiceChoosingPageState extends State<ServiceChoosingPage> {
  bool _imageLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.service.name,
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image with Skeleton Loader
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Stack(
                children: [
                  // Skeleton loader (shows while loading)
                  if (!_imageLoaded)
                    const Positioned.fill(
                      child: SkeletonLoader(
                        width: double.infinity,
                        height: 250,
                      ),
                    ),

                  // Actual image
                  if (widget.service.mainImage != null)
                    Positioned.fill(
                      child: Image.network(
                        widget.service.mainImage!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            // Image loaded
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() => _imageLoaded = true);
                              }
                            });
                            return child;
                          }
                          return const SizedBox.shrink();
                        },
                        errorBuilder: (_, __, ___) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() => _imageLoaded = true);
                            }
                          });
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    )
                  else if (widget.service.imageUrl != null)
                    Positioned.fill(
                      child: Image.network(
                        widget.service.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() => _imageLoaded = true);
                              }
                            });
                            return child;
                          }
                          return const SizedBox.shrink();
                        },
                        errorBuilder: (_, __, ___) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() => _imageLoaded = true);
                            }
                          });
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Positioned.fill(
                      child: Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Name
                  Text(
                    widget.service.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Price
                  if (widget.service.price != null)
                    Text(
                      'Starting at ${widget.service.price!.toStringAsFixed(0)} DZD',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.roseColor,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'About this service',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.service.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: PrimaryButton(
            text: 'Get Started',
            onPressed: () {
              if (widget.service.formFields == null ||
                  widget.service.formFields!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No order form available for this service yet',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServiceOrderFormPage(service: widget.service),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
