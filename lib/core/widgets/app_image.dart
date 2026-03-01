import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A unified image widget that loads from local assets when the path starts
/// with 'assets/', otherwise falls back to a cached network image.
class AppImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  Widget _errorFallback(BuildContext context) {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
          child: const Center(
            child: Icon(Icons.image, color: Colors.grey, size: 40),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _errorFallback(context),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
      ),
      errorWidget: (_, __, ___) => _errorFallback(context),
    );
  }
}

/// Returns an [ImageProvider] that works with both local assets and network URLs.
/// Use this wherever an [ImageProvider] is required (e.g., [CircleAvatar.backgroundImage]).
ImageProvider<Object> appImageProvider(String imageUrl) {
  if (imageUrl.startsWith('assets/')) {
    return AssetImage(imageUrl);
  }
  return CachedNetworkImageProvider(imageUrl);
}
