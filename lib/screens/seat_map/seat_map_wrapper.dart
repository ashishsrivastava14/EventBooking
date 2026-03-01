import 'package:flutter/material.dart';
import 'layouts/base_layout.dart';

/// Wraps a [BaseLayout] in an [InteractiveViewer] with zoom/pan support,
/// a zoom indicator pill, and a reset button.
class SeatMapWrapper extends StatefulWidget {
  final BaseLayout layout;

  const SeatMapWrapper({super.key, required this.layout});

  @override
  State<SeatMapWrapper> createState() => _SeatMapWrapperState();
}

class _SeatMapWrapperState extends State<SeatMapWrapper> {
  final TransformationController _controller = TransformationController();
  double _currentScale = 1.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetView() {
    _controller.value = Matrix4.identity();
    setState(() => _currentScale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InteractiveViewer(
          transformationController: _controller,
          boundaryMargin: const EdgeInsets.all(60),
          minScale: 0.5,
          maxScale: 3.0,
          constrained: false,
          onInteractionUpdate: (details) {
            setState(() => _currentScale = _controller.value.getMaxScaleOnAxis());
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: widget.layout,
          ),
        ),
        // Zoom indicator pill
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentScale.toStringAsFixed(1)}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // Reset button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _resetView,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restart_alt, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Reset',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
