// Importaciones necesarias para la funcionalidad de la pantalla
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profit_app/widgets/user_exercise_chart.dart';

/// Pantalla que muestra el progreso individual de ejercicios para un usuario específico
/// Permite filtrar y visualizar el progreso de diferentes ejercicios en el tiempo
class ExerciseLogsScreen extends StatefulWidget {
  // ID del usuario cuyos registros se mostrarán
  final String userId;

  const ExerciseLogsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ExerciseLogsScreen> createState() => _ExerciseLogsScreenState();
}

class _ExerciseLogsScreenState extends State<ExerciseLogsScreen> with SingleTickerProviderStateMixin {
  // Lista completa de todos los registros de ejercicios
  List<Map<String, dynamic>> _allLogs = [];
  // Lista filtrada de registros según la búsqueda
  List<Map<String, dynamic>> _filteredLogs = [];
  // Controlador para el campo de búsqueda, inicializado con 'Press Banca'
  final TextEditingController _searchController = TextEditingController(text: 'Press Banca');
  // Controladores para las animaciones de entrada
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Configuración de la animación de entrada con duración de 1.5 segundos
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    // Carga inicial de datos y inicio de la animación
    _fetchLogs();
    _animationController.forward();
  }

  @override
  void dispose() {
    // Limpieza de recursos al destruir el widget
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Obtiene los registros de ejercicios del usuario desde Firestore
  Future<void> _fetchLogs() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('logs_ejercicios')
        .where('userId', isEqualTo: widget.userId)
        .get();

    // Procesa y mapea los datos de Firestore
    final logs = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'nombreEjercicio': data['nombreEjercicio'] ?? '',
        'peso': data['peso'] ?? 0,
        'fecha': (data['fecha'] as Timestamp).toDate(),
      };
    }).toList();

    // Ordena los registros por fecha
    logs.sort((a, b) => a['fecha'].compareTo(b['fecha']));

    setState(() {
      _allLogs = logs;
      _filterLogs(_searchController.text); // Aplica el filtro inicial
    });
  }

  /// Normaliza un string para hacer búsquedas insensibles a mayúsculas y espacios
  String _normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  /// Filtra los registros según el término de búsqueda
  void _filterLogs(String search) {
    final normalizedSearch = _normalize(search);
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        final normalizedLogName = _normalize(log['nombreEjercicio']);
        return normalizedLogName.contains(normalizedSearch);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo oscuro para el tema
      appBar: AppBar(
        title: const Text(
          "Progreso de Ejercicios",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de búsqueda personalizado con diseño moderno
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
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: _filterLogs,
              ),
            ),
            const SizedBox(height: 24),
            // Gráfico de progreso de ejercicios con animación
            Expanded(
              child: UserExerciseChart(
                logs: _filteredLogs,
                fadeAnimation: _fadeAnimation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
