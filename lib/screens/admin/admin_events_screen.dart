import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_background.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../models/event_model.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    var events = admin.events;
    if (_searchQuery.isNotEmpty) {
      events = events
          .where((e) =>
              e.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Events')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/events/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
      body: AppBackground(
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? const Center(child: Text('No events found'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(label: Text('Event')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Sales')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: events.map((event) {
                          return DataRow(cells: [
                            DataCell(
                              SizedBox(
                                width: 160,
                                child: Text(
                                  event.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            DataCell(Text(_formatDate(event.date))),
                            DataCell(
                              Chip(
                                label: Text(event.category,
                                    style: const TextStyle(fontSize: 11)),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            DataCell(
                              GestureDetector(
                                onTap: () {
                                  admin.toggleEventStatus(event.id, event.status.toLowerCase() == 'active' ? 'Cancelled' : 'Active');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: event.status.toLowerCase() == 'active'
                                        ? AppColors.success.withValues(alpha: 0.15)
                                        : AppColors.error.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    event.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: event.status.toLowerCase() == 'active'
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(
                                '${event.totalTicketsSold}/${event.ticketTiers.fold<int>(0, (s, t) => s + t.totalQuantity)}')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 18, color: AppColors.primary),
                                    onPressed: () => context
                                        .push('/admin/events/edit/${event.id}'),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 18, color: AppColors.error),
                                    onPressed: () =>
                                        _confirmDelete(context, admin, event),
                                    tooltip: 'Delete',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.bar_chart,
                                        size: 18),
                                    onPressed: () =>
                                        _showEventStats(context, event),
                                    tooltip: 'Stats',
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      ),
    );
  }

  void _showEventStats(BuildContext context, EventModel event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalCap = event.ticketTiers.fold<int>(0, (s, t) => s + t.totalQuantity);
    final totalSold = event.totalTicketsSold;
    final totalRevenue = event.ticketTiers.fold<double>(
        0, (s, t) => s + t.soldQuantity * t.price);
    final soldPct = totalCap > 0 ? totalSold / totalCap : 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // header
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text('${event.category} · ${_formatDate(event.date)}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondaryDark)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: event.status.toLowerCase() == 'active'
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(event.status.toUpperCase(),
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: event.status.toLowerCase() == 'active'
                              ? AppColors.success : AppColors.error)),
                ),
              ]),
              const SizedBox(height: 20),

              // KPI row
              Row(children: [
                _statKpi('Total Revenue', '\$${totalRevenue.toStringAsFixed(0)}',
                    Icons.attach_money_rounded, AppColors.success, isDark),
                const SizedBox(width: 10),
                _statKpi('Tickets Sold', '$totalSold / $totalCap',
                    Icons.confirmation_number_rounded, AppColors.primary, isDark),
                const SizedBox(width: 10),
                _statKpi('Rating', event.rating > 0 ? '${event.rating}★' : 'N/A',
                    Icons.star_rounded, AppColors.secondary, isDark),
              ]),
              const SizedBox(height: 20),

              // overall sell-through bar
              Text('Sell-Through Rate',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: soldPct.clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: isDark ? AppColors.card : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          soldPct >= 0.8 ? AppColors.success
                              : soldPct >= 0.4 ? AppColors.secondary
                              : AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${(soldPct * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight)),
              ]),
              const SizedBox(height: 20),

              // per-tier breakdown
              Text('Ticket Tier Breakdown',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight)),
              const SizedBox(height: 10),
              ...event.ticketTiers.map((tier) {
                final pct = tier.totalQuantity > 0
                    ? tier.soldQuantity / tier.totalQuantity
                    : 0.0;
                final revenue = tier.soldQuantity * tier.price;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(children: [
                        Icon(Icons.local_activity_rounded,
                            size: 15, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(tier.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight)),
                        const Spacer(),
                        Text('\$${tier.price.toStringAsFixed(0)} / ticket',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondaryDark)),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: pct.clamp(0.0, 1.0),
                              minHeight: 7,
                              backgroundColor:
                                  isDark ? AppColors.surface : Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('${tier.soldQuantity}/${tier.totalQuantity}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondaryDark)),
                      ]),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(pct * 100).toStringAsFixed(0)}% sold',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondaryDark)),
                          Text('Revenue: \$${revenue.toStringAsFixed(0)}',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600,
                                  color: AppColors.success)),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              // venue & date detail row
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.location_on_rounded, 'Venue',
                        '${event.venueName}, ${event.city}', isDark),
                    const SizedBox(height: 8),
                    _infoRow(Icons.calendar_today_rounded, 'Date & Time',
                        '${_formatDate(event.date)} ${event.date.year} · ${event.time}', isDark),
                    const SizedBox(height: 8),
                    _infoRow(Icons.people_outline_rounded, 'Reviews',
                        '${event.reviewCount} reviews', isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statKpi(String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColors.primary),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
      Expanded(
        child: Text(value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimaryLight),
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }

  void _confirmDelete(
      BuildContext context, AdminProvider admin, EventModel event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              admin.deleteEvent(event.id);
              Navigator.pop(ctx);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
