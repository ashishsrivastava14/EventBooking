import 'package:flutter/material.dart';

class SeatingZone {
  final String zoneId;
  final String zoneName;
  final Color color;
  final String priceTier;
  final double priceAmount;
  final int totalSeats;
  final int availableSeats;
  final int rows;
  final int seatsPerRow;
  final bool isAccessible;
  final bool isVIP;

  const SeatingZone({
    required this.zoneId,
    required this.zoneName,
    required this.color,
    required this.priceTier,
    required this.priceAmount,
    required this.totalSeats,
    required this.availableSeats,
    required this.rows,
    required this.seatsPerRow,
    this.isAccessible = false,
    this.isVIP = false,
  });

  double get availabilityPercent =>
      totalSeats > 0 ? (availableSeats / totalSeats) * 100 : 0;

  int get takenSeats => totalSeats - availableSeats;
}
