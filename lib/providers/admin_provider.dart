import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../models/venue_model.dart';
import '../core/constants/mock_data.dart';

class AdminProvider extends ChangeNotifier {
  List<EventModel> _events = [];
  List<UserModel> _users = [];
  List<VenueModel> _venues = [];

  List<EventModel> get events => _events;
  List<UserModel> get users => _users;
  List<VenueModel> get venues => _venues;

  AdminProvider() {
    _events = List.from(MockData.events);
    _users = List.from(MockData.users);
    _venues = List.from(MockData.venues);
  }

  // ─── EVENTS CRUD ───────────────────────────────────────
  void addEvent(EventModel event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(String id, EventModel updated) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index] = updated;
      notifyListeners();
    }
  }

  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void toggleEventStatus(String id, String status) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index].status = status;
      notifyListeners();
    }
  }

  // ─── USERS MANAGEMENT ─────────────────────────────────
  void toggleUserBan(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].isBanned = !_users[index].isBanned;
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  // ─── VENUES ────────────────────────────────────────────
  void addVenue(VenueModel venue) {
    _venues.add(venue);
    notifyListeners();
  }

  void updateVenue(String id, VenueModel updated) {
    final index = _venues.indexWhere((v) => v.id == id);
    if (index != -1) {
      _venues[index] = updated;
      notifyListeners();
    }
  }

  void deleteVenue(String id) {
    _venues.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // ─── ANALYTICS DATA ───────────────────────────────────
  List<double> get bookingsLast7Days => [12, 19, 8, 25, 15, 30, 22];

  List<Map<String, dynamic>> get topEventsBySales => [
    {'name': 'Taylor Swift', 'sales': 5200},
    {'name': 'Coldplay', 'sales': 4800},
    {'name': 'Coachella', 'sales': 4200},
    {'name': 'NBA Finals', 'sales': 3800},
    {'name': 'Hamilton', 'sales': 3000},
  ];

  Map<String, double> get categoryRevenue => {
    'Concerts': 45000,
    'Sports': 32000,
    'Theatre': 18000,
    'Comedy': 12000,
    'Festivals': 38000,
    'Family': 8000,
  };

  List<double> get monthlyRevenue => [
    15000, 22000, 18000, 35000, 28000, 42000,
    38000, 45000, 32000, 50000, 40000, 55000,
  ];

  double get avgTicketPrice => 185.50;
  double get cancellationRate => 8.5;
  String get peakBookingHour => '7:00 PM';
  int get activeUsers => _users.where((u) => !u.isBanned).length;
}
