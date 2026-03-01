import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/mock_data.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/event_card.dart';
import '../../providers/event_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventProv = context.watch<EventProvider>();
    final filtered = eventProv.filteredEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Events'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, eventProv),
          ),
        ],
      ),
      body: AppBackground(
        child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: eventProv.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search events, artists, venues...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: eventProv.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => eventProv.setSearchQuery(''),
                      )
                    : null,
              ),
            ),
          ),
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} events found',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                if (eventProv.selectedCategory != 'All' ||
                    eventProv.searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: eventProv.resetFilters,
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  )
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final event = filtered[index];
                          return EventCard(
                            event: event,
                            onTap: () => context.push('/event/${event.id}'),
                            isCompact: true,
                            isFavorite:
                                eventProv.favoriteIds.contains(event.id),
                            onFavorite: () =>
                                eventProv.toggleFavorite(event.id),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final event = filtered[index];
                          return EventCard(
                            event: event,
                            onTap: () => context.push('/event/${event.id}'),
                            isFavorite:
                                eventProv.favoriteIds.contains(event.id),
                            onFavorite: () =>
                                eventProv.toggleFavorite(event.id),
                          );
                        },
                      ),
          ),
        ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, EventProvider eventProv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              final isDark =
                  Theme.of(context).brightness == Brightness.dark;
              final unselectedChipColor =
                  isDark ? AppColors.card : AppColors.cardLight;
              final unselectedTextColor =
                  isDark ? Colors.white : Colors.black87;
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Filters',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),
                    // Category
                    const Text('Category',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MockData.categories.map((cat) {
                        final isSelected = eventProv.selectedCategory == cat;
                        return FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: unselectedChipColor,
                          side: BorderSide(
                            color: isDark
                                ? Colors.white24
                                : Colors.black26,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : unselectedTextColor,
                          ),
                          onSelected: (_) {
                            eventProv.setCategory(cat);
                            setModalState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // City
                    const Text('City',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: eventProv.selectedCity,
                      items: MockData.cities
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          eventProv.setCity(v);
                          setModalState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // Price Range
                    Text(
                      'Price Range: \$${eventProv.priceRange.start.toInt()} – \$${eventProv.priceRange.end.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    RangeSlider(
                      values: eventProv.priceRange,
                      min: 0,
                      max: 5000,
                      divisions: 100,
                      activeColor: AppColors.primary,
                      labels: RangeLabels(
                        '\$${eventProv.priceRange.start.toInt()}',
                        '\$${eventProv.priceRange.end.toInt()}',
                      ),
                      onChanged: (v) {
                        eventProv.setPriceRange(v);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                    // Sort
                    const Text('Sort By',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Date', 'Price', 'Popularity'].map((s) {
                        final isSelected = eventProv.sortBy == s;
                        return ChoiceChip(
                          label: Text(s),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: unselectedChipColor,
                          side: BorderSide(
                            color: isDark
                                ? Colors.white24
                                : Colors.black26,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : unselectedTextColor,
                          ),
                          onSelected: (_) {
                            eventProv.setSortBy(s);
                            setModalState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          eventProv.resetFilters();
                          setModalState(() {});
                        },
                        child: const Text('Reset All'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
