import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';
import 'dart:math';
import '../models/service_model.dart';
import '../utils/image_decoder.dart';

class ServiceCard extends StatefulWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  late Future<Uint8List?> _imageFuture;
  final Color _randomColor =
      Colors.primaries[Random().nextInt(Colors.primaries.length)];

  @override
  void initState() {
    super.initState();
    _imageFuture = ImageDecoder.decodeBase64Image(
      widget.service.imageUrl,
      cacheKey: widget.service.id,
    );
  }

  @override
  void didUpdateWidget(covariant ServiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service.imageUrl != widget.service.imageUrl) {
      _imageFuture = ImageDecoder.decodeBase64Image(
        widget.service.imageUrl,
        cacheKey: widget.service.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a default color if no specific color logic exists for services
    // Using a consistent color or random one for fallback
    final cardColor = _randomColor;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 200,
        height: 120, // Same dimensions as CategoryCard
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            if (widget.service.imageUrl != null &&
                widget.service.imageUrl!.startsWith('http'))
              Image.network(
                widget.service.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: cardColor);
                },
              )
            else
              FutureBuilder<Uint8List?>(
                future: _imageFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData &&
                      snapshot.data != null) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: cardColor);
                      },
                    );
                  }
                  return Container(color: cardColor);
                },
              ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Text Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  widget.service.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize:
                        20, // Slightly smaller than Category 24px as service names might be longer
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                    shadows: [
                      const Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4.0,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
