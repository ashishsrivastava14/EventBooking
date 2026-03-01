import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/powered_by_footer.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/mock_data.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/seat_widget.dart';
import '../../providers/cart_provider.dart';
import '../../providers/event_provider.dart';

class SeatSelectionScreen extends StatefulWidget {
  final String eventId;
  const SeatSelectionScreen({super.key, required this.eventId});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  String _selectedZone = 'Floor';

  // Each zone: {rows, cols, rowOffset, colOffset}
  static const Map<String, Map<String, int>> _zoneConfig = {
    'Floor':   {'rows': 6,  'cols': 8,  'rowOffset': 0,  'colOffset': 0},
    'A-Block': {'rows': 5,  'cols': 10, 'rowOffset': 6,  'colOffset': 0},
    'B-Block': {'rows': 6,  'cols': 10, 'rowOffset': 11, 'colOffset': 0},
    'Balcony': {'rows': 8,  'cols': 12, 'rowOffset': 17, 'colOffset': 0},
  };

  List<String> get _zones => _zoneConfig.keys.toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final eventProv = context.watch<EventProvider>();
    final event = eventProv.getEventById(widget.eventId);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Seats')),
        body: AppBackground(child: const Center(child: Text('Event not found'))),
      );
    }

    final zoneConf  = _zoneConfig[_selectedZone]!;
    final rows      = zoneConf['rows']!;
    final cols      = zoneConf['cols']!;
    final rowOffset = zoneConf['rowOffset']!;
    final rowLabels = List.generate(rows, (i) => String.fromCharCode(65 + i));

    return Scaffold(
      bottomNavigationBar: const PoweredByFooter(),
      appBar: AppBar(
        title: Text('Select Seats'),
      ),
      body: AppBackground(
        child: Column(
        children: [
          // Event info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cart.tierName ?? "General"} · \$${cart.tierPrice.toStringAsFixed(2)} each',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Zone selector
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _zones.length,
              itemBuilder: (context, index) {
                final zone = _zones[index];
                final isSelected = _selectedZone == zone;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(zone),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark
                        ? AppColors.card
                        : AppColors.cardLight,
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.15),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (_) =>
                        setState(() => _selectedZone = zone),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Stage
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x330266DF), Color(0x550148A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(40),
              ),
              border: Border(
                top: BorderSide(color: Color(0x66026CDF)),
                left: BorderSide(color: Color(0x66026CDF)),
                right: BorderSide(color: Color(0x66026CDF)),
              ),
            ),
            child: const Center(
              child: Text(
                'STAGE',
                style: TextStyle(
                  color: Color(0xFF5BABF5),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Seat Grid — wrapped in InteractiveViewer to allow pinch/pan
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(40),
              minScale: 0.5,
              maxScale: 2.5,
              constrained: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                    children: List.generate(rows, (row) {
                      final rowLabel = rowLabels[row];
                      // seat IDs incorporate row offset so they're unique per zone
                      final seatRowLabel =
                          String.fromCharCode(65 + row + rowOffset);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 22,
                            child: Text(
                              rowLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          ...List.generate(cols, (col) {
                            final seatId = '$seatRowLabel${col + 1}';
                            final isTaken =
                                MockData.takenSeats.contains(seatId);
                            final isVip = MockData.vipSeats.contains(seatId);
                            final isSelected =
                                cart.selectedSeats.contains(seatId);

                            SeatState state;
                            if (isTaken) {
                              state = SeatState.taken;
                            } else if (isSelected) {
                              state = SeatState.selected;
                            } else if (isVip) {
                              state = SeatState.vip;
                            } else {
                              state = SeatState.available;
                            }

                            return SeatWidget(
                              label: seatId,
                              state: state,
                              onTap: () {
                                if (isTaken) return;
                                final success = cart.toggleSeat(seatId);
                                if (!success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Maximum 6 seats per booking!'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              },
                            );
                          }),
                          SizedBox(
                            width: 22,
                            child: Text(
                              rowLabel,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legendItem('Available', AppColors.seatAvailable),
                _legendItem('Selected', AppColors.seatSelected),
                _legendItem('Taken', AppColors.seatTaken),
                _legendItem('VIP', AppColors.seatVip),
              ],
            ),
          ),

          // Bottom summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${cart.seatCount} seat${cart.seatCount != 1 ? 's' : ''} selected',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (cart.seatCount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          cart.selectedSeats.join(', '),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.primaryGradient.createShader(b),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    '\$${cart.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: cart.seatCount > 0
                      ? () => context.push('/checkout')
                      : null,
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
