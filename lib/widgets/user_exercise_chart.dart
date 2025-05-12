import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class UserExerciseChart extends StatelessWidget {
  final List<Map<String, dynamic>> logs;
  final Animation<double> fadeAnimation;

  const UserExerciseChart({
    Key? key,
    required this.logs,
    required this.fadeAnimation,
  }) : super(key: key);

  List<FlSpot> _getChartSpots() {
    return List.generate(logs.length, (index) {
      final peso = logs[index]['peso'] as num;
      return FlSpot(index.toDouble(), peso.toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            const Text(
              "No hay registros para mostrar",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "¡Comienza a registrar tus ejercicios!",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E1E1E),
              Colors.grey[900]!,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: LineChart(
          LineChartData(
            backgroundColor: Colors.transparent,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < logs.length) {
                      final date = logs[value.toInt()]['fecha'] as DateTime;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Transform.rotate(
                          angle: -0.5,
                          child: Text(
                            DateFormat('dd/MM').format(date),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white12,
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.white24),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: _getChartSpots(),
                isCurved: true,
                curveSmoothness: 0.35,
                barWidth: 4,
                color: Colors.pinkAccent,
                isStrokeCapRound: true,
                preventCurveOverShooting: true,
                belowBarData: BarAreaData(
                  show: true,
                  spotsLine: BarAreaSpotsLine(show: false),
                  gradient: LinearGradient(
                    colors: [
                      Colors.pinkAccent.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 6,
                    color: Colors.pinkAccent,
                    strokeWidth: 2.5,
                    strokeColor: Colors.white,
                  ),
                ),
                shadow: const Shadow(
                  color: Colors.pinkAccent,
                  blurRadius: 8,
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.black87,
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final date = logs[spot.x.toInt()]['fecha'] as DateTime;
                    final peso = logs[spot.x.toInt()]['peso'];
                    return LineTooltipItem(
                      '${DateFormat('dd/MM').format(date)}\n',
                      const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: '$peso kg',
                          style: const TextStyle(
                            color: Colors.pinkAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}