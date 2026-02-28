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
                                  admin.toggleEventStatus(event.id, event.status == 'active' ? 'cancelled' : 'active');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: event.status == 'active'
                                        ? AppColors.success.withOpacity(0.15)
                                        : AppColors.error.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    event.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: event.status == 'active'
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
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Event stats (UI only)')),
                                      );
                                    },
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
