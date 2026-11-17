import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context).colorScheme.primary
        .withValues(alpha: 0.08);
    final iconColor = Theme.of(context).colorScheme.primary
        .withValues(alpha: 0.45);

    Widget buildFallback() {
      return Container(
        width: width,
        height: height,
        color: placeholderColor,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: iconColor,
          size: 28,
        ),
      );
    }

    if (imageUrl.trim().isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: buildFallback(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: placeholderColor,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => buildFallback(),
      ),
    );
  }
}
