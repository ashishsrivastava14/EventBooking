import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/widgets/app_background.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../providers/booking_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final admin = context.watch<AdminProvider>();
    final bookingProv = context.watch<BookingProvider>();

    final totalRevenue = bookingProv.totalRevenue;
    final totalBookings = bookingProv.bookings.length;
    final totalEvents = admin.events.length;
    final totalUsers = admin.users.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: AppBackground(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── KPI Cards ───────────
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _kpiCard('Total Revenue',
                    '\$${totalRevenue.toStringAsFixed(0)}', Icons.attach_money,
                    AppColors.success, isDark),
                _kpiCard('Bookings', '$totalBookings',
                    Icons.confirmation_number, AppColors.primary, isDark),
                _kpiCard('Events', '$totalEvents', Icons.event,
                    AppColors.secondary, isDark),
                _kpiCard('Users', '$totalUsers', Icons.people,
                    const Color(0xFF9C27B0), isDark),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Bookings Last 7 Days (Line Chart) ───
            const Text(
              'Bookings (Last 7 Days)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const days = [
                            'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
                          ];
                          final idx = v.toInt();
                          if (idx >= 0 && idx < days.length) {
                            return Text(days[idx],
                                style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: admin.bookingsLast7Days
                          .asMap()
                          .entries
                          .map((e) =>
                              FlSpot(e.key.toDouble(), e.value.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Revenue by Category (Pie Chart) ───
            const Text(
              'Revenue by Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: _pieSections(admin.categoryRevenue),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: admin.categoryRevenue.entries.map((e) {
                      final idx =
                          admin.categoryRevenue.keys.toList().indexOf(e.key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _pieColors[idx % _pieColors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(e.key, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Recent Bookings ────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Bookings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => context.go('/admin/bookings'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: bookingProv.bookings.take(5).map((b) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(b.eventTitle,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(b.userName,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(
                          '\$${b.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Quick Actions ──────────
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _quickAction(Icons.add, 'Add Event', () {
                  context.push('/admin/events/add');
                }, isDark),
                const SizedBox(width: 12),
                _quickAction(Icons.bar_chart, 'Analytics', () {
                  context.go('/admin/analytics');
                }, isDark),
                const SizedBox(width: 12),
                _quickAction(Icons.location_on, 'Venues', () {
                  context.go('/admin/venues');
                }, isDark),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      ),
    );
  }

  Widget _kpiCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '↑ 12%',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
      IconData icon, String label, VoidCallback onTap, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : AppColors.cardLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  static const _pieColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    AppColors.error,
  ];

  List<PieChartSectionData> _pieSections(Map<String, double> data) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    int idx = 0;
    return data.entries.map((e) {
      final pct = (e.value / total * 100);
      final section = PieChartSectionData(
        color: _pieColors[idx % _pieColors.length],
        value: e.value,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
        radius: 50,
      );
      idx++;
      return section;
    }).toList();
  }
}
