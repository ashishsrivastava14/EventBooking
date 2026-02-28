import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/mock_data.dart';
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
  final List<String> _zones = ['Floor', 'A-Block', 'B-Block', 'Balcony'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final eventProv = context.watch<EventProvider>();
    final event = eventProv.getEventById(widget.eventId);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Seats')),
        body: const Center(child: Text('Event not found')),
      );
    }

    const rows = 8;
    const cols = 10;
    final rowLabels = List.generate(rows, (i) => String.fromCharCode(65 + i));

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Seats'),
      ),
      body: Column(
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
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontSize: 12,
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
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.4),
              ),
            ),
            child: const Center(
              child: Text(
                'STAGE',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Seat Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: List.generate(rows, (row) {
                  final rowLabel = rowLabels[row];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        child: Text(
                          rowLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      ...List.generate(cols, (col) {
                        final seatId = '$rowLabel${col + 1}';
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
                        width: 20,
                        child: Text(
                          rowLabel,
                          style: TextStyle(
                            fontSize: 10,
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
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
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
                Text(
                  '\$${cart.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
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
