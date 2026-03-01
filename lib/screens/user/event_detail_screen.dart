import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/widgets/powered_by_footer.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/event_card.dart';
import '../../providers/event_provider.dart';
import '../../providers/cart_provider.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTierIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventProv = context.watch<EventProvider>();
    final event = eventProv.getEventById(widget.eventId);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: AppBackground(child: const Center(child: Text('Event not found'))),
      );
    }

    final isFav = eventProv.favoriteIds.contains(event.id);
    final relatedEvents = eventProv.getRelatedEvents(event);

    return Scaffold(
      body: AppBackground(
        child: CustomScrollView(
        slivers: [
          // ─── Parallax Header ──────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    imageUrl: event.imageUrl,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
                              .withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.error : Colors.white,
                ),
                onPressed: () => eventProv.toggleFavorite(event.id),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share link copied! (Mock)')),
                  );
                },
              ),
            ],
          ),

          // ─── Event Info ───────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 12),
                  _infoRow(Icons.calendar_today, AppColors.primary,
                      '${_monthName(event.date.month)} ${event.date.day}, ${event.date.year} · ${event.time}'),
                  const SizedBox(height: 8),
                  _infoRow(Icons.location_on, AppColors.secondary,
                      '${event.venueName}, ${event.city}'),
                  const SizedBox(height: 8),
                  _infoRow(Icons.star, AppColors.seatVip,
                      '${event.rating} (${event.reviewCount} reviews)'),
                  const SizedBox(height: 16),
                  // Artist chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: event.artists.map((artist) {
                      return Chip(
                        backgroundColor: isDark
                            ? AppColors.card
                            : AppColors.cardLight,
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.1),
                        ),
                        avatar: Icon(Icons.person,
                            size: 16,
                            color: isDark ? Colors.white70 : Colors.black54),
                        label: Text(
                          artist,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // ─── Tabs ─────────────────────
          SliverToBoxAdapter(
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'About'),
                Tab(text: 'Lineup'),
                Tab(text: 'Venue'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: IndexedStack(
              index: _tabController.index,
              children: [
                // ── About ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                // ── Lineup ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: event.artists.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // ── Venue ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.venueName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            event.city,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Google Maps-style tile map
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            // 3×2 OSM tile grid (CartoDB Positron – Google Maps look-alike)
                            SizedBox(
                              height: 180,
                              child: OverflowBox(
                                maxWidth: double.infinity,
                                maxHeight: double.infinity,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.network(
                                          'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/12/1204/1536.png',
                                          width: 256,
                                          height: 256,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox(width: 256, height: 256),
                                        ),
                                        Image.network(
                                          'https://cartodb-basemaps-b.global.ssl.fastly.net/light_all/12/1205/1536.png',
                                          width: 256,
                                          height: 256,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox(width: 256, height: 256),
                                        ),
                                        Image.network(
                                          'https://cartodb-basemaps-c.global.ssl.fastly.net/light_all/12/1206/1536.png',
                                          width: 256,
                                          height: 256,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox(width: 256, height: 256),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.network(
                                          'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/12/1204/1537.png',
                                          width: 256,
                                          height: 256,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox(width: 256, height: 256),
                                        ),
                                        Image.network(
                                          'https://cartodb-basemaps-b.global.ssl.fastly.net/light_all/12/1205/1537.png',
                                          width: 256,
                                          height: 256,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox(width: 256, height: 256),
                                        ),
                                        Image.network(
                                          'https://cartodb-basemaps-c.global.ssl.fastly.net/light_all/12/1206/1537.png',
                                          width: 256,
                                          height: 256,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox(width: 256, height: 256),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Location pin overlay
                            Positioned.fill(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: Text(
                                        event.venueName,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 36,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Google Maps attribution badge
                            Positioned(
                              bottom: 6,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '© OpenStreetMap',
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.black54),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final query =
                              Uri.encodeComponent('${event.venueName}, ${event.city}');
                          // Try Google Maps app first, fall back to browser
                          final googleMapsApp =
                              Uri.parse('comgooglemaps://?q=$query');
                          final googleMapsBrowser = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=$query');
                          if (await canLaunchUrl(googleMapsApp)) {
                            await launchUrl(googleMapsApp);
                          } else {
                            await launchUrl(
                              googleMapsBrowser,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: const Icon(Icons.directions, size: 16),
                        label: const Text('Get Directions'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Reviews ────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(3, (i) {
                      final reviewTexts = [
                        'Absolutely incredible! The energy was unreal from start to finish.',
                        'One of the best shows I\'ve ever attended. Highly recommend!',
                        'Amazing production quality and crowd atmosphere. Will be back.',
                      ];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary,
                              child: Text('U${i + 1}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('User ${i + 1}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                      const Spacer(),
                                      ...List.generate(
                                          5,
                                          (s) => Icon(Icons.star,
                                              size: 13,
                                              color: s < 4 + (i % 2)
                                                  ? AppColors.secondary
                                                  : Colors.grey.shade400)),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    reviewTexts[i],
                                    style: TextStyle(
                                        fontSize: 13,
                                        height: 1.4,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // ─── Ticket Tiers ─────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Tickets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...event.ticketTiers.asMap().entries.map((entry) {
                    final tier = entry.value;
                    final isSelected = _selectedTierIndex == entry.key;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedTierIndex = entry.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : (isDark ? AppColors.card : AppColors.cardLight),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tier.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${tier.availableQuantity} available',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: tier.availableQuantity > 0
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${tier.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ─── Related Events ───────────
          if (relatedEvents.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Related Events',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: relatedEvents.length,
                      itemBuilder: (context, index) {
                        return EventCard(
                          event: relatedEvents[index],
                          onTap: () => context
                              .push('/event/${relatedEvents[index].id}'),
                          isCompact: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      ),
      // ─── Sticky Bottom CTA ────────
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  '\$${event.ticketTiers[_selectedTierIndex].price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final tier = event.ticketTiers[_selectedTierIndex];
                  context.read<CartProvider>().setEvent(
                        event.id,
                        tier.name,
                        tier.price,
                      );
                  context.push('/seats/${event.id}');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Select Seats'),
              ),
            ),
          ],
        ),
          ),
          const PoweredByFooter(),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
