import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:profit_app/screens/execution/countdowns_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';
import 'package:async/async.dart';
import 'package:profit_app/widgets/exercise_detail.dart';

class EntrenamientoDetalleScreen extends StatelessWidget {
  final String entrenamientoId;
  final String userId;

  static const Color primaryPink = Colors.pinkAccent;
  static const Color primaryPurple = Colors.deepPurpleAccent;
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color textLight = Colors.white;
  static const Color textSecondary = Colors.white70;

  const EntrenamientoDetalleScreen({
    required this.entrenamientoId,
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ejerciciosStream = FirebaseFirestore.instance
        .collection('ejercicios')
        .where('idEntrenamiento', isEqualTo: entrenamientoId)
        .snapshots();

    final ejerciciosLvlStream = FirebaseFirestore.instance
        .collection('ejercicioslvl')
        .where('idEntrenamiento', isEqualTo: entrenamientoId)
        .snapshots();

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: textLight),
        title: const Text(
          "Detalle del Entrenamiento",
          style: TextStyle(
            color: textLight,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: primaryPink),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Información', style: TextStyle(color: textLight)),
                  content: const Text(
                    'Presiona el botón de play para comenzar cada ejercicio. Sigue las instrucciones del video y mantén el ritmo.',
                    style: TextStyle(color: textSecondary),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Entendido', style: TextStyle(color: primaryPink)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: StreamZip([ejerciciosStream, ejerciciosLvlStream]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: primaryPink),
            );
          }

          final allDocs = [
            ...snapshot.data![0].docs,
            ...snapshot.data![1].docs,
          ];

          if (allDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.fitness_center, size: 80, color: textSecondary),
                  SizedBox(height: 16),
                  Text(
                    "No hay ejercicios asignados",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: allDocs.length,
            itemBuilder: (context, index) {
              final ejercicio = allDocs[index];
              String? url = ejercicio['multimedia'];
              String? videoId = YoutubePlayer.convertUrlToId(url ?? '');

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cardBackground,
                      Color(0xFF2A2A2A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPink.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              ejercicio['nombre'] ?? '',
                              style: const TextStyle(
                                color: textLight,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryPink.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: primaryPink, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  "${ejercicio['xp']} XP",
                                  style: const TextStyle(
                                    color: primaryPink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (videoId != null)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryPink.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: YoutubePlayer(
                            controller: YoutubePlayerController(
                              initialVideoId: videoId,
                              flags: const YoutubePlayerFlags(
                                autoPlay: false,
                                mute: false,
                              ),
                            ),
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: primaryPink,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryPink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Detalles del ejercicio",
                              style: TextStyle(
                                color: primaryPink,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ejercicio['descripcion'],
                            style: const TextStyle(color: textSecondary, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primaryPink.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                ExerciseDetail(icon: Icons.repeat, label: "Series", value: "${ejercicio['series']}"),
                                ExerciseDetail(icon: Icons.fitness_center, label: "Peso", value: "${ejercicio['peso']} kg"),
                                ExerciseDetail(icon: Icons.refresh, label: "Repeticiones", value: "${ejercicio['repeticiones']}"),
                                ExerciseDetail(icon: Icons.timer, label: "Tiempo estimado", value: "${ejercicio['tiempoEstimado']} min"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.play_circle_filled, size: 28),
                              label: const Text(
                                "COMENZAR EJERCICIO",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: textLight,
                                backgroundColor: primaryPink,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CountdownScreen(
                                      minutos: ejercicio['tiempoEstimado'],
                                      nombreEjercicio: ejercicio['nombre'],
                                      multimediaUrl: ejercicio['multimedia'],
                                      xpGanado: ejercicio['xp'],
                                      userId: userId,
                                      peso: ejercicio['peso'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
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
