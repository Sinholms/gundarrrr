import 'package:flutter/material.dart';

/// A widget that displays a food item image from assets with
/// consistent sizing, rounded clipping, and a subtle background.
class FoodImage extends StatelessWidget {
  final String assetPath;
  final double size;

  const FoodImage({
    super.key,
    required this.assetPath,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Icon(
            Icons.restaurant_rounded,
            size: size * 0.5,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
