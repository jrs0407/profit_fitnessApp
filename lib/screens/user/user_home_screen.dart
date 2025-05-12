import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:profit_app/screens/execution/doExercises_creen.dart';
import 'package:profit_app/widgets/day_selector.dart';

class UserRoutineDashboardScreen extends StatefulWidget {
  final String userId;

  const UserRoutineDashboardScreen({super.key, required this.userId});

  @override
  State<UserRoutineDashboardScreen> createState() =>
      _UserRoutineDashboardScreenState();
}

class _UserRoutineDashboardScreenState
    extends State<UserRoutineDashboardScreen> {
  String _selectedDay = DateFormat('EEEE', 'es_ES').format(DateTime.now());
  Future<List<Map<String, dynamic>>>? _entrenamientosFuture;
  String? _userName;
  String? _userLevel;

  final List<String> daysOfWeek = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _entrenamientosFuture = _loadData();
  }

  Future<void> _fetchUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        _userName = data['nombre'] ?? 'Usuario';
        _userLevel = data['nivel']?.toString() ?? '0';
      });
    }
  }

  String normalizeDay(String day) {
    return day[0].toUpperCase() + day.substring(1).toLowerCase();
  }

  Future<void> _refreshData() async {
    setState(() {
      _entrenamientosFuture = _loadData();
    });
  }

  Future<List<Map<String, dynamic>>> _loadData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (!userDoc.exists) return [];

    final userData = userDoc.data()!;
    final rutinaIds = userData['rutinas'] ?? [];

    return _loadEntrenamientosDelDia(rutinaIds, normalizeDay(_selectedDay));
  }

  Future<List<Map<String, dynamic>>> _loadEntrenamientosDelDia(
    List<dynamic> rutinaIds,
    String diaSeleccionado,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final int userLevel = int.tryParse(_userLevel ?? '0') ?? 0;

    List<Map<String, dynamic>> resultado = [];

    // Cargar entrenamientos estándar
    final rutinas = await Future.wait(rutinaIds.map((id) async {
      final doc = await firestore.collection('rutinas').doc(id).get();
      return {
        'id': id,
        'data': doc.data() ?? {},
      };
    }));

    final entrenamientosQuery = await firestore
        .collection('entrenamientos')
        .where('diaSemana', isEqualTo: diaSeleccionado)
        .get();

    final entrenamientosFiltrados = entrenamientosQuery.docs
        .where((doc) => rutinaIds.contains(doc['idRutina']))
        .toList();

    for (final doc in entrenamientosFiltrados) {
      final entrenamientoId = doc.id;
      final entrenamiento = doc.data();
      entrenamiento['id'] = entrenamientoId;

      final rutina = rutinas.firstWhere(
        (r) => r['id'] == entrenamiento['idRutina'],
        orElse: () => {'data': {}},
      )['data'];

      final ejerciciosQuery = await firestore
          .collection('ejercicios')
          .where('idEntrenamiento', isEqualTo: entrenamientoId)
          .get();

      final ejercicios = ejerciciosQuery.docs.map((e) => e.data()).toList();

      resultado.add({
        'rutina': rutina,
        'entrenamiento': entrenamiento,
        'ejercicios': ejercicios,
      });
    }

    // Cargar entrenamientos por nivel
    final rutinasLvlQuery = await firestore.collection('rutinaslvl').get();
    final rutinasLvl = rutinasLvlQuery.docs
        .where((doc) => (doc['nivel'] ?? 0) <= userLevel)
        .toList();

    for (final rutinaDoc in rutinasLvl) {
      final rutinaId = rutinaDoc.id;
      final rutina = rutinaDoc.data();

      final entrenamientosLvlQuery = await firestore
          .collection('entrenamientoslvl')
          .where('diaSemana', isEqualTo: diaSeleccionado)
          .where('idRutina', isEqualTo: rutinaId)
          .get();

      final entrenamientosLvl = entrenamientosLvlQuery.docs
          .where((doc) => (doc['nivel'] ?? 0) <= userLevel)
          .toList();

      for (final entrenamientoDoc in entrenamientosLvl) {
        final entrenamientoId = entrenamientoDoc.id;
        final entrenamiento = entrenamientoDoc.data();
        entrenamiento['id'] = entrenamientoId;

        final ejerciciosLvlQuery = await firestore
            .collection('ejercicioslvl')
            .where('idEntrenamiento', isEqualTo: entrenamientoId)
            .get();

        final ejercicios =
            ejerciciosLvlQuery.docs.map((e) => e.data()).toList();

        resultado.add({
          'rutina': rutina,
          'entrenamiento': entrenamiento,
          'ejercicios': ejercicios,
        });
      }
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/mujer.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Hola, ${_userName ?? 'Atleta'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 3.0,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Nivel $_userLevel',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent.withOpacity(0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/espartano.png',
                              width: 35,
                              height: 35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                DaySelector(
                  daysOfWeek: daysOfWeek,
                  selectedDay: _selectedDay,
                  onDaySelected: (day) {
                    setState(() {
                      _selectedDay = day;
                      _entrenamientosFuture = _loadData();
                    });
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center,
                          color: Colors.pinkAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Tus entrenamientos del ${_selectedDay.toLowerCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.pinkAccent,
              backgroundColor: const Color(0xFF1E1E1E),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _entrenamientosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Colors.pinkAccent),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center,
                              size: 64, color: Colors.grey[700]),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay entrenamientos para hoy',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '¡Es un buen día para descansar!',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      final entrenamiento = item['entrenamiento'];
                      final rutina = item['rutina'];
                      final ejercicios = item['ejercicios'] ?? [];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EntrenamientoDetalleScreen(
                                entrenamientoId: entrenamiento['id'],
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
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
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            entrenamiento['nombre'] ??
                                                'Sin nombre',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.pinkAccent
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.timer,
                                                color: Colors.pinkAccent,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${entrenamiento['duracion']} min',
                                                style: const TextStyle(
                                                  color: Colors.pinkAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${rutina['nombre']} • ${entrenamiento['objetivo']}',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Ejercicios',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...ejercicios.map<Widget>((ejercicio) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.pinkAccent
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.fitness_center,
                                                size: 16,
                                                color: Colors.pinkAccent,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              ejercicio['nombre'] ?? '',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.pinkAccent.withOpacity(0.2),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Toca para comenzar →',
                                    style: TextStyle(
                                      color: Colors.pinkAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
