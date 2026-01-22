import 'package:flutter/material.dart';

/// Creates a fade + scale transition route for smooth, noticeable page transitions
/// The old page fades out and scales down slightly
/// The new page fades in and scales up with a subtle bounce effect
class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadeRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 600),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // Fade in animation for new page
           final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
             CurvedAnimation(parent: animation, curve: Curves.easeInOut),
           );

           // Scale up animation for new page (with bounce)
           final scaleIn = Tween<double>(begin: 0.95, end: 1.0).animate(
             CurvedAnimation(
               parent: animation,
               curve: Curves.easeOutBack, // Subtle bounce effect
             ),
           );

           // Fade out animation for old page
           final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
             CurvedAnimation(
               parent: secondaryAnimation,
               curve: Curves.easeInOut,
             ),
           );

           // Scale down animation for old page
           final scaleOut = Tween<double>(begin: 1.0, end: 0.95).animate(
             CurvedAnimation(
               parent: secondaryAnimation,
               curve: Curves.easeInOut,
             ),
           );

           return FadeTransition(
             opacity: fadeOut,
             child: ScaleTransition(
               scale: scaleOut,
               child: FadeTransition(
                 opacity: fadeIn,
                 child: ScaleTransition(scale: scaleIn, child: child),
               ),
             ),
           );
         },
         transitionDuration: duration,
         reverseTransitionDuration: duration,
       );
}
