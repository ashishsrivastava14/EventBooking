import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/mock_data.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/powered_by_footer.dart';
import '../../models/seating_zone.dart';
import '../../providers/cart_provider.dart';
import '../../providers/event_provider.dart';
import '../seat_map/seat_map_controller.dart';
import '../seat_map/seat_map_wrapper.dart';
import '../seat_map/layouts/base_layout.dart';
import '../seat_map/widgets/seat_legend_widget.dart';

class SeatSelectionScreen extends StatefulWidget {
  final String eventId;
  const SeatSelectionScreen({super.key, required this.eventId});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  String? _activeZoneId;
  late Set<String> _takenSeats;
  bool _initialized = false;

  void _initTakenSeats(List<SeatingZone> zones) {
    if (!_initialized) {
      _takenSeats = BaseLayout.generateTakenSeats(zones);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final eventProv = context.watch<EventProvider>();
    final event = eventProv.getEventById(widget.eventId);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Seats')),
        body: AppBackground(
            child: const Center(child: Text('Event not found'))),
      );
    }

    // Resolve venue & seat map config from mock data
    final venue = MockData.getVenueForEvent(event);
    final layoutType = event.effectiveEventCategory;
    final zones = event.seatMapConfig?.zones ?? MockData.getZonesForCategory(layoutType);

    _initTakenSeats(zones);

    // Build the dynamic layout
    final layout = SeatMapController.resolveLayout(
      eventCategory: layoutType,
      venue: venue,
      zones: zones,
      selectedSeats: cart.selectedSeats.toSet(),
      takenSeats: _takenSeats,
      onSeatTapped: (seatId, zoneName, price) {
        final success = cart.toggleSeatWithPrice(seatId, price, zoneName);
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 6 seats per booking!'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      onZoneTapped: (zoneId) {
        setState(() => _activeZoneId = zoneId);
      },
      activeZoneId: _activeZoneId,
    );

    return Scaffold(
      bottomNavigationBar: const PoweredByFooter(),
      appBar: AppBar(
        title: Text(event.title, overflow: TextOverflow.ellipsis),
        actions: [
          if (_activeZoneId != null)
            TextButton.icon(
              onPressed: () => setState(() => _activeZoneId = null),
              icon: const Icon(Icons.zoom_out_map, size: 18),
              label: const Text('Overview',
                  style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
      body: AppBackground(
        child: Column(
          children: [
            // ── Event info + tier info ──────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.venueName,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _activeZoneId == null
                              ? 'Tap a zone to select seats'
                              : 'Zone: ${_activeZoneName(zones)}  •  Tap seats to select',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Layout type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      layoutType.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Zone filter chips ──────────────────────────
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: zones.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // "All Zones" chip
                    final isSelected = _activeZoneId == null;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: const Text('All Zones'),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark
                            ? AppColors.card
                            : AppColors.cardLight,
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.black.withValues(alpha: 0.12),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        onSelected: (_) =>
                            setState(() => _activeZoneId = null),
                      ),
                    );
                  }
                  final zone = zones[index - 1];
                  final isSelected = _activeZoneId == zone.zoneId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(zone.zoneName),
                      selected: isSelected,
                      selectedColor: zone.color,
                      backgroundColor:
                          isDark ? AppColors.card : AppColors.cardLight,
                      side: BorderSide(
                        color: isSelected
                            ? zone.color
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.black.withValues(alpha: 0.12)),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      onSelected: (_) =>
                          setState(() => _activeZoneId = zone.zoneId),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 6),

            // ── Dynamic seat map ───────────────────────────
            Expanded(
              child: SeatMapWrapper(layout: layout),
            ),

            // ── Legend ─────────────────────────────────────
            const SeatLegendWidget(),

            // ── Bottom summary panel ───────────────────────
            _buildBottomPanel(context, cart, isDark),
          ],
        ),
      ),
    );
  }

  String _activeZoneName(List<SeatingZone> zones) {
    final zone = zones.firstWhere(
      (z) => z.zoneId == _activeZoneId,
      orElse: () => zones.first,
    );
    return zone.zoneName;
  }

  Widget _buildBottomPanel(
      BuildContext context, CartProvider cart, bool isDark) {
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cart.seatCount > 0) ...[
            // Seat details row
            Row(
              children: [
                Icon(Icons.event_seat,
                    size: 16, color: AppColors.seatSelected),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cart.selectedSeats.join(', '),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Display zone info if available
                if (cart.seatZones.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          AppColors.seatSelected.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cart.seatZones.values.toSet().join(', '),
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.seatSelected),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
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
                  ],
                ),
              ),
              if (cart.seatCount > 0)
                TextButton(
                  onPressed: () {
                    cart.clearCart();
                    setState(() => _activeZoneId = null);
                  },
                  child: const Text('Clear All',
                      style: TextStyle(fontSize: 12)),
                ),
              const SizedBox(width: 8),
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
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: cart.seatCount > 0
                    ? () => context.push('/checkout')
                    : null,
                child: const Text('Checkout'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
