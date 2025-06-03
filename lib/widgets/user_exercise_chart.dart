import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Widget que muestra una gráfica de línea para visualizar el progreso
/// del peso del usuario a lo largo del tiempo.
class UserExerciseChart extends StatelessWidget {
  /// Lista de registros que contienen la fecha y el peso del usuario
  final List<Map<String, dynamic>> logs;
  
  /// Animación para controlar la opacidad al mostrar la gráfica
  final Animation<double> fadeAnimation;

  const UserExerciseChart({
    Key? key,
    required this.logs,
    required this.fadeAnimation,
  }) : super(key: key);

  /// Convierte los datos de peso en puntos para la gráfica
  /// Retorna una lista de [FlSpot] donde x es el índice y y es el peso
  List<FlSpot> _getChartSpots() {
    return List.generate(logs.length, (index) {
      final peso = logs[index]['peso'] as num;
      return FlSpot(index.toDouble(), peso.toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay datos, muestra un mensaje centrado con un ícono
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

    // Contenedor principal con animación de fade
    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        // Decoración del contenedor con gradiente y sombra
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
        // Configuración de la gráfica de línea
        child: LineChart(
          LineChartData(
            backgroundColor: Colors.transparent,
            // Configuración de los títulos de los ejes
            titlesData: FlTitlesData(
              // Configuración del eje Y (valores de peso)
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
              // Configuración del eje X (fechas)
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
              // Ocultar títulos superiores y derechos
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            // Configuración de la cuadrícula
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white12,
                strokeWidth: 1,
                dashArray: [5, 5], // Líneas punteadas
              ),
            ),
            // Borde de la gráfica
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.white24),
            ),
            // Configuración de la línea de datos
            lineBarsData: [
              LineChartBarData(
                spots: _getChartSpots(),
                isCurved: true, // Hace que la línea sea curva
                curveSmoothness: 0.35, // Nivel de suavizado de la curva
                barWidth: 4,
                color: Colors.pinkAccent,
                isStrokeCapRound: true,
                preventCurveOverShooting: true,
                // Área sombreada debajo de la línea
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
                // Configuración de los puntos en la línea
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 6,
                    color: Colors.pinkAccent,
                    strokeWidth: 2.5,
                    strokeColor: Colors.white,
                  ),
                ),
                // Efecto de sombra en la línea
                shadow: const Shadow(
                  color: Colors.pinkAccent,
                  blurRadius: 8,
                ),
              ),
            ],
            // Configuración de la interactividad y tooltips
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.black87,
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                // Personalización del contenido del tooltip
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