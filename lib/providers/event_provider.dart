import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import '../core/constants/mock_data.dart';

class EventProvider extends ChangeNotifier {
  List<EventModel> _events = [];
  List<String> _favoriteIds = [];
  String _selectedCategory = 'All';
  String _selectedCity = 'All Cities';
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 5000);
  String _sortBy = 'Date';

  List<EventModel> get events => _events;
  List<String> get favoriteIds => _favoriteIds;
  String get selectedCategory => _selectedCategory;
  String get selectedCity => _selectedCity;
  String get searchQuery => _searchQuery;
  RangeValues get priceRange => _priceRange;
  String get sortBy => _sortBy;

  List<EventModel> get featuredEvents =>
      _events.where((e) => e.isFeatured).toList();

  List<EventModel> get trendingEvents =>
      _events.where((e) => e.isTrending).toList();

  List<EventModel> get weekendEvents {
    final now = DateTime.now();
    final nextSaturday = now.add(Duration(days: (6 - now.weekday) % 7));
    final nextSunday = nextSaturday.add(const Duration(days: 1));
    return _events
        .where((e) =>
            e.date.isAfter(now) &&
            e.date.isBefore(nextSunday.add(const Duration(days: 7))))
        .toList();
  }

  List<EventModel> get favoriteEvents =>
      _events.where((e) => _favoriteIds.contains(e.id)).toList();

  List<EventModel> get filteredEvents {
    var result = List<EventModel>.from(_events);

    if (_selectedCategory != 'All') {
      result = result.where((e) => e.category == _selectedCategory).toList();
    }

    if (_selectedCity != 'All Cities') {
      result = result.where((e) => e.city == _selectedCity).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              e.category.toLowerCase().contains(q) ||
              e.venueName.toLowerCase().contains(q) ||
              e.city.toLowerCase().contains(q) ||
              e.artists.any((a) => a.toLowerCase().contains(q)))
          .toList();
    }

    result = result
        .where((e) =>
            e.minPrice >= _priceRange.start && e.minPrice <= _priceRange.end)
        .toList();

    switch (_sortBy) {
      case 'Date':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Price':
        result.sort((a, b) => a.minPrice.compareTo(b.minPrice));
        break;
      case 'Popularity':
        result.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }

    return result;
  }

  EventProvider() {
    _events = List.from(MockData.events);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = prefs.getStringList('favorites') ?? [];
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteIds);
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void toggleFavorite(String eventId) {
    if (_favoriteIds.contains(eventId)) {
      _favoriteIds.remove(eventId);
    } else {
      _favoriteIds.add(eventId);
    }
    _saveFavorites();
    notifyListeners();
  }

  EventModel? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<EventModel> getRelatedEvents(EventModel event) {
    return _events
        .where((e) => e.id != event.id && e.category == event.category)
        .take(5)
        .toList();
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _selectedCity = 'All Cities';
    _searchQuery = '';
    _priceRange = const RangeValues(0, 5000);
    _sortBy = 'Date';
    notifyListeners();
  }
}
