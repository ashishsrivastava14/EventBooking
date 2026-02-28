import 'package:flutter/foundation.dart';
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

/// An [ImageProvider] that works with both local assets and network URLs.
/// Use this where [ImageProvider] is required (e.g., [CircleAvatar.backgroundImage]).
class AppImageProvider extends ImageProvider<AppImageProvider> {
  final String imageUrl;
  const AppImageProvider(this.imageUrl);

  ImageProvider get _delegate => imageUrl.startsWith('assets/')
      ? AssetImage(imageUrl)
      : CachedNetworkImageProvider(imageUrl) as ImageProvider;

  /// Delegate resolution entirely to the underlying provider so that
  /// [loadImage] (which requires provider-specific key types) is never
  /// called on this class directly.
  @override
  ImageStream resolve(ImageConfiguration configuration) =>
      _delegate.resolve(configuration);

  // obtainKey and loadImage are required by the abstract class but are
  // never invoked because resolve() is fully overridden above.
  @override
  Future<AppImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<AppImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
      AppImageProvider key, ImageDecoderCallback decode) =>
      throw UnimplementedError('loadImage is not used; resolve() delegates directly.');

  @override
  bool operator ==(Object other) =>
      other is AppImageProvider && other.imageUrl == imageUrl;

  @override
  int get hashCode => imageUrl.hashCode;
}
