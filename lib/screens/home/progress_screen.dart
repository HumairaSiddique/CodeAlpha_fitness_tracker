import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/workout_model.dart';
import '../../services/firestore_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _firestoreService = FirestoreService();
  List<WorkoutModel> _weekWorkouts = [];
  bool _isLoading = true;
  String _selectedMetric = 'Calories'; // Calories, Steps, Duration

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final workouts = await _firestoreService.getLast7DaysWorkouts();
    if (mounted) setState(() { _weekWorkouts = workouts; _isLoading = false; });
  }

  List<FlSpot> _getSpots() {
    final Map<int, double> dayData = {};
    for (var w in _weekWorkouts) {
      final daysAgo = DateTime.now().difference(w.date).inDays;
      final dayIndex = 6 - daysAgo;
      if (dayIndex < 0 || dayIndex > 6) continue;
      double value = 0;
      if (_selectedMetric == 'Calories') value = w.caloriesBurned.toDouble();
      if (_selectedMetric == 'Steps') value = w.steps.toDouble();
      if (_selectedMetric == 'Duration') value = w.durationMinutes.toDouble();
      dayData[dayIndex] = (dayData[dayIndex] ?? 0) + value;
    }
    return List.generate(7, (i) => FlSpot(i.toDouble(), dayData[i] ?? 0));
  }

  Map<String, int> _getWorkoutTypeCount() {
    final Map<String, int> counts = {};
    for (var w in _weekWorkouts) {
      counts[w.type] = (counts[w.type] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C6AE)))
            : RefreshIndicator(
                onRefresh: _loadData,
                color: const Color(0xFF00C6AE),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last 7 days overview',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.white38),
                      ),
                      const SizedBox(height: 28),

                      // Metric Selector
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: ['Calories', 'Steps', 'Duration'].map((m) {
                            final isSelected = _selectedMetric == m;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedMetric = m),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF00C6AE)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    m,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white38,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Line Chart
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_selectedMetric This Week',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 180,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (_) => FlLine(
                                      color: Colors.white10,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, _) {
                                          final date = DateTime.now().subtract(
                                              Duration(
                                                  days: 6 - value.toInt()));
                                          return Text(
                                            DateFormat('E').format(date),
                                            style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: Colors.white38),
                                          );
                                        },
                                        reservedSize: 28,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, _) => Text(
                                          value.toInt().toString(),
                                          style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: Colors.white30),
                                        ),
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _getSpots(),
                                      isCurved: true,
                                      color: const Color(0xFF00C6AE),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF00C6AE)
                                                .withOpacity(0.3),
                                            const Color(0xFF00C6AE)
                                                .withOpacity(0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (_, __, ___, ____) =>
                                            FlDotCirclePainter(
                                          radius: 4,
                                          color: const Color(0xFF00C6AE),
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Workout Type Breakdown
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workout Breakdown',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_weekWorkouts.isEmpty)
                              Center(
                                child: Text(
                                  'No workouts this week yet',
                                  style: GoogleFonts.inter(
                                      color: Colors.white30, fontSize: 14),
                                ),
                              )
                            else
                              ..._getWorkoutTypeCount().entries.map((entry) {
                                final typeData = workoutTypes.firstWhere(
                                  (t) => t['name'] == entry.key,
                                  orElse: () => workoutTypes.last,
                                );
                                final color =
                                    Color(typeData['color'] as int);
                                final total = _weekWorkouts.length;
                                final pct = entry.value / total;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(typeData['icon'] as String,
                                              style: const TextStyle(
                                                  fontSize: 18)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              entry.key,
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: Colors.white70),
                                            ),
                                          ),
                                          Text(
                                            '${entry.value}x',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: pct,
                                          backgroundColor:
                                              Colors.white.withOpacity(0.05),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  color),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
