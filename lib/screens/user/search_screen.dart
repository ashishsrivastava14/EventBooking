import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/powered_by_footer.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_image.dart';
import '../../providers/event_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventProv = context.watch<EventProvider>();

    return Scaffold(
      bottomNavigationBar: const PoweredByFooter(),
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: eventProv.setSearchQuery,
          decoration: const InputDecoration(
            hintText: 'Search events, artists...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                eventProv.setSearchQuery('');
              },
            ),
        ],
      ),
      body: AppBackground(
        child: eventProv.searchQuery.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(height: 16),
                  Text(
                    'Search for events',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: eventProv.filteredEvents.length,
              itemBuilder: (context, index) {
                final event = eventProv.filteredEvents[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppImage(
                      imageUrl: event.imageUrl,
                      width: 56,
                      height: 56,
                    ),
                  ),
                  title: Text(event.title),
                  subtitle: Text('${event.venueName} · ${event.city}'),
                  trailing: Text(
                    '\$${event.minPrice.toStringAsFixed(0)}+',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => context.push('/event/${event.id}'),
                );
              },
            ),
      ),
    );
  }
}
