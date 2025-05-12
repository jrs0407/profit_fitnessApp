import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profit_app/widgets/custom_chart.dart';

class GlobalExerciseProgressScreen extends StatefulWidget {
  const GlobalExerciseProgressScreen({Key? key}) : super(key: key);

  @override
  State<GlobalExerciseProgressScreen> createState() => _GlobalExerciseProgressScreenState();
}

class _GlobalExerciseProgressScreenState extends State<GlobalExerciseProgressScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController(text: 'Press Banca');
  Map<String, List<Map<String, dynamic>>> _userLogs = {};
  Map<String, String> _userNames = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _fetchAllLogs();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllLogs() async {
    final snapshot = await FirebaseFirestore.instance.collection('logs_ejercicios').get();
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    
    // Primero, obtener solo los IDs de usuarios premium
    Set<String> premiumUserIds = {};
    for (var userDoc in usersSnapshot.docs) {
      final data = userDoc.data();
      if (data['premium'] == true) {
        premiumUserIds.add(userDoc.id);
      }
    }

    Map<String, List<Map<String, dynamic>>> groupedLogs = {};
    Map<String, String> userNames = {};

    // Eliminamos espacios del término de búsqueda
    final searchTerm = _searchController.text.toLowerCase().replaceAll(' ', '').trim();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final userId = data['userId'];
      
      // No vemos usuarios que no son premium
      if (!premiumUserIds.contains(userId)) continue;

      final exerciseName = data['nombreEjercicio']?.toString().toLowerCase().replaceAll(' ', '').trim() ?? '';

      // Compara los nombres de los ejercicios sin espacios
      if (!exerciseName.contains(searchTerm)) continue;

      final log = {
        'peso': data['peso'] ?? 0,
        'fecha': (data['fecha'] as Timestamp).toDate(),
      };

      groupedLogs.putIfAbsent(userId, () => []).add(log);
    }

    // Obtener los nombres de los usuarios premium
    for (var userDoc in usersSnapshot.docs) {
      if (premiumUserIds.contains(userDoc.id)) {
        final data = userDoc.data();
        userNames[userDoc.id] = '${data['nombre']} ${data['apellidos']}';
      }
    }

    // Ordenar los logs por fecha
    for (var logs in groupedLogs.values) {
      logs.sort((a, b) => a['fecha'].compareTo(b['fecha']));
    }

    setState(() {
      _userLogs = groupedLogs;
      _userNames = userNames;
    });
  }

  void _onSearchChanged() {
    _fetchAllLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progreso Global',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Buscar ejercicio...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.pinkAccent),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white38),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged();
                      },
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _onSearchChanged(),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _userLogs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 64,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No hay datos disponibles",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        children: _userLogs.entries.map((entry) {
                          return CustomChart(
                            userName: _userNames[entry.key] ?? 'Usuario Desconocido',
                            logs: entry.value,
                            fadeAnimation: _fadeAnimation,
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
