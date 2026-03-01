import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/widgets/app_background.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../providers/booking_provider.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final admin = context.watch<AdminProvider>();
    final bookingProv = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: AppBackground(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── KPI Tiles ─────────
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: [
                _kpiTile('Total Revenue',
                    '\$${bookingProv.totalRevenue.toStringAsFixed(0)}',
                    Colors.green, isDark),
                _kpiTile('Avg Ticket Price', '\$72',
                    AppColors.primary, isDark),
                _kpiTile('Conversion Rate', '34%',
                    AppColors.secondary, isDark),
                _kpiTile('Repeat Customers', '62%',
                    const Color(0xFF9C27B0), isDark),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Monthly Revenue (Bar Chart) ─────
            const Text(
              'Monthly Revenue',
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
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const months = [
                            'Jan','Feb','Mar','Apr','May','Jun',
                            'Jul','Aug','Sep','Oct','Nov','Dec'
                          ];
                          final i = v.toInt();
                          if (i >= 0 && i < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(months[i],
                                  style: const TextStyle(fontSize: 9)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: admin.monthlyRevenue.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value,
                          color: AppColors.primary,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Top Events by Sales (Horizontal Bar) ────
            const Text(
              'Top Events by Sales',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: admin.topEventsBySales.map((item) {
                  final name = item['name'] as String;
                  final sales = (item['sales'] as num).toDouble();
                  final maxVal = admin.topEventsBySales.isEmpty
                      ? 1.0
                      : admin.topEventsBySales
                          .map((e) => (e['sales'] as num).toDouble())
                          .reduce((a, b) => a > b ? a : b);
                  final pct = sales / maxVal;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(name,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text('${sales.toInt()}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Category Revenue (Donut Chart) ────
            const Text(
              'Revenue by Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              height: 260,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sections: _donutSections(admin.categoryRevenue),
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: admin.categoryRevenue.entries.map((e) {
                        final idx = admin.categoryRevenue.keys
                            .toList()
                            .indexOf(e.key);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color:
                                      _donutColors[idx % _donutColors.length],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(e.key,
                                        style:
                                            const TextStyle(fontSize: 12)),
                                    Text(
                                      '\$${e.value.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      ),
    );
  }

  Widget _kpiTile(
      String title, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
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

  static const _donutColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    AppColors.error,
  ];

  List<PieChartSectionData> _donutSections(Map<String, double> data) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    int idx = 0;
    return data.entries.map((e) {
      final pct = (e.value / total * 100);
      final section = PieChartSectionData(
        color: _donutColors[idx % _donutColors.length],
        value: e.value,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
        radius: 45,
      );
      idx++;
      return section;
    }).toList();
  }
}
