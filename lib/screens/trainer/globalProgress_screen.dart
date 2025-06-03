// Importaciones necesarias para la funcionalidad de la pantalla
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profit_app/widgets/custom_chart.dart';

/// Pantalla que muestra el progreso global de los ejercicios de todos los usuarios premium
/// Permite buscar ejercicios específicos y visualizar su progreso en el tiempo
class GlobalExerciseProgressScreen extends StatefulWidget {
  const GlobalExerciseProgressScreen({Key? key}) : super(key: key);

  @override
  State<GlobalExerciseProgressScreen> createState() => _GlobalExerciseProgressScreenState();
}

class _GlobalExerciseProgressScreenState extends State<GlobalExerciseProgressScreen> with SingleTickerProviderStateMixin {
  // Controlador para el campo de búsqueda, inicializado con 'Press Banca' como valor por defecto
  final TextEditingController _searchController = TextEditingController(text: 'Press Banca');
  
  // Almacena los registros de ejercicios agrupados por usuario
  Map<String, List<Map<String, dynamic>>> _userLogs = {};
  
  // Mapeo de IDs de usuario a nombres completos
  Map<String, String> _userNames = {};
  
  // Controladores de animación para efectos visuales
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Configuración de la animación de entrada
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    // Carga inicial de datos
    _fetchAllLogs();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Obtiene todos los registros de ejercicios de usuarios premium desde Firestore
  /// Filtra los resultados según el término de búsqueda actual
  Future<void> _fetchAllLogs() async {
    final snapshot = await FirebaseFirestore.instance.collection('logs_ejercicios').get();
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    
    // Obtiene solo los IDs de usuarios premium
    Set<String> premiumUserIds = {};
    for (var userDoc in usersSnapshot.docs) {
      final data = userDoc.data();
      if (data['premium'] == true) {
        premiumUserIds.add(userDoc.id);
      }
    }

    Map<String, List<Map<String, dynamic>>> groupedLogs = {};
    Map<String, String> userNames = {};

    // Normaliza el término de búsqueda eliminando espacios
    final searchTerm = _searchController.text.toLowerCase().replaceAll(' ', '').trim();

    // Procesa cada registro de ejercicio
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final userId = data['userId'];
      
      // Filtra usuarios no premium
      if (!premiumUserIds.contains(userId)) continue;

      final exerciseName = data['nombreEjercicio']?.toString().toLowerCase().replaceAll(' ', '').trim() ?? '';

      // Filtra ejercicios que no coinciden con la búsqueda
      if (!exerciseName.contains(searchTerm)) continue;

      final log = {
        'peso': data['peso'] ?? 0,
        'fecha': (data['fecha'] as Timestamp).toDate(),
      };

      groupedLogs.putIfAbsent(userId, () => []).add(log);
    }

    // Obtiene los nombres completos de los usuarios premium
    for (var userDoc in usersSnapshot.docs) {
      if (premiumUserIds.contains(userDoc.id)) {
        final data = userDoc.data();
        userNames[userDoc.id] = '${data['nombre']} ${data['apellidos']}';
      }
    }

    // Ordena los registros por fecha
    for (var logs in groupedLogs.values) {
      logs.sort((a, b) => a['fecha'].compareTo(b['fecha']));
    }

    setState(() {
      _userLogs = groupedLogs;
      _userNames = userNames;
    });
  }

  /// Maneja los cambios en el campo de búsqueda
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
              // Título de la pantalla
              const Text(
                'Progreso Global',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Campo de búsqueda personalizado
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
              
              // Lista de gráficos de progreso o mensaje de no datos
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
                        physics: const BouncingScrollPhysics(), // Efecto de rebote al hacer scroll
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
