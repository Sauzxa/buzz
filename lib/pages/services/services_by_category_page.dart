import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/services_provider.dart';
import '../../models/service_model.dart';
import '../../Widgets/service_card.dart';
import '../../Widgets/button.dart';
import '../../theme/colors.dart';
import 'service_choosing_page.dart';

class ServicesByCategoryPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ServicesByCategoryPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<ServicesByCategoryPage> createState() => _ServicesByCategoryPageState();
}

class _ServicesByCategoryPageState extends State<ServicesByCategoryPage> {
  ServiceModel? _selectedService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ServicesProvider>();
      if (provider.services.isEmpty) {
        provider.fetchServices();
      }
    });
  }

  void _onServiceSelected(ServiceModel service) {
    setState(() {
      _selectedService = service;
    });
  }

  void _proceedToServiceDetails() {
    if (_selectedService != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceChoosingPage(service: _selectedService!),
        ),
      );
    }
  }

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
          widget.categoryName,
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ServicesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'Failed to load services',
                    style: GoogleFonts.dmSans(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchServices(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final services = provider.services
              .where((s) => s.categoryId == widget.categoryId)
              .toList();

          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No services available',
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
              // Category Description Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.categoryName,
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your demands with the most qualified designers at around algeries',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Services Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    final isSelected = _selectedService?.id == service.id;

                    return GestureDetector(
                      onTap: () => _onServiceSelected(service),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.greenColor
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: ServiceCard(
                          service: service,
                          onTap: () => _onServiceSelected(service),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Proceed Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: PrimaryButton(
                    text: 'Proceed',
                    onPressed: _selectedService != null
                        ? _proceedToServiceDetails
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a service first'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
