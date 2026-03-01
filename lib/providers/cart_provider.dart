import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  String? _eventId;
  String? _tierName;
  double _tierPrice = 0;
  final List<String> _selectedSeats = [];
  String _promoCode = '';
  double _discountPercent = 0;
  String _paymentMethod = 'Credit Card';

  // ── Zone-based pricing maps ────────────────────────────
  final Map<String, double> _seatPrices = {};
  final Map<String, String> _seatZones = {};

  String? get eventId => _eventId;
  String? get tierName => _tierName;
  double get tierPrice => _tierPrice;
  List<String> get selectedSeats => List.unmodifiable(_selectedSeats);
  String get promoCode => _promoCode;
  double get discountPercent => _discountPercent;
  String get paymentMethod => _paymentMethod;
  Map<String, String> get seatZones => Map.unmodifiable(_seatZones);
  Map<String, double> get seatPrices => Map.unmodifiable(_seatPrices);

  /// Subtotal: uses per-seat prices when available, else uniform tier price.
  double get subtotal {
    if (_seatPrices.isNotEmpty) {
      return _seatPrices.values.fold(0.0, (sum, p) => sum + p);
    }
    return _selectedSeats.length * _tierPrice;
  }

  double get serviceFee => subtotal * 0.10;
  double get discount => subtotal * _discountPercent;
  double get total => subtotal + serviceFee - discount;

  int get seatCount => _selectedSeats.length;

  void setEvent(String eventId, String tierName, double tierPrice) {
    _eventId = eventId;
    _tierName = tierName;
    _tierPrice = tierPrice;
    _selectedSeats.clear();
    _seatPrices.clear();
    _seatZones.clear();
    _promoCode = '';
    _discountPercent = 0;
    notifyListeners();
  }

  void setTier(String tierName, double tierPrice) {
    _tierName = tierName;
    _tierPrice = tierPrice;
    notifyListeners();
  }

  /// Legacy toggle (uniform pricing). Kept for backward compatibility.
  bool toggleSeat(String seatId) {
    if (_selectedSeats.contains(seatId)) {
      _selectedSeats.remove(seatId);
      _seatPrices.remove(seatId);
      _seatZones.remove(seatId);
      notifyListeners();
      return true;
    } else {
      if (_selectedSeats.length >= 6) {
        return false; // Max 6 seats
      }
      _selectedSeats.add(seatId);
      notifyListeners();
      return true;
    }
  }

  /// Toggle a seat with its zone-specific price. Returns false if max reached.
  bool toggleSeatWithPrice(String seatId, double price, String zoneName) {
    if (_selectedSeats.contains(seatId)) {
      _selectedSeats.remove(seatId);
      _seatPrices.remove(seatId);
      _seatZones.remove(seatId);
      notifyListeners();
      return true;
    } else {
      if (_selectedSeats.length >= 6) {
        return false;
      }
      _selectedSeats.add(seatId);
      _seatPrices[seatId] = price;
      _seatZones[seatId] = zoneName;
      // Update tier summary for checkout display
      _tierName = zoneName;
      _tierPrice = price;
      notifyListeners();
      return true;
    }
  }

  bool applyPromoCode(String code) {
    if (code.toUpperCase() == 'SAVE10') {
      _promoCode = code.toUpperCase();
      _discountPercent = 0.10;
      notifyListeners();
      return true;
    }
    _promoCode = '';
    _discountPercent = 0;
    notifyListeners();
    return false;
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void clearCart() {
    _eventId = null;
    _tierName = null;
    _tierPrice = 0;
    _selectedSeats.clear();
    _seatPrices.clear();
    _seatZones.clear();
    _promoCode = '';
    _discountPercent = 0;
    _paymentMethod = 'Credit Card';
    notifyListeners();
  }
}
