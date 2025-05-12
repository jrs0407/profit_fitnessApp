import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profit_app/screens/trainer/createTraining_screen.dart';
import 'package:profit_app/screens/trainer/edit_trainings_screen.dart';
import 'package:profit_app/screens/trainer/exercises_screen.dart';

class RoutineTrainingsScreen extends StatelessWidget {
  final String rutinaId;
  final String rutinaNombre;

  const RoutineTrainingsScreen({
    super.key,
    required this.rutinaId,
    required this.rutinaNombre,
  });

  Future<bool?> _confirmDelete(BuildContext context, String entrenamientoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('¿Eliminar entrenamiento?', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este entrenamiento?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF0DCAF0))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('entrenamientos')
          .doc(entrenamientoId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrenamiento eliminado')),
      );
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Entrenamientos de $rutinaNombre',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A0DAD),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('entrenamientos')
            .where('idRutina', isEqualTo: rutinaId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0DCAF0)));
          }

          final entrenamientos = snapshot.data!.docs;

          if (entrenamientos.isEmpty) {
            return const Center(
              child: Text(
                'No hay entrenamientos.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            itemCount: entrenamientos.length,
            itemBuilder: (context, index) {
              final entrenamiento = entrenamientos[index];
              final data = entrenamiento.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(entrenamiento.id),
                direction: DismissDirection.startToEnd,
                confirmDismiss: (_) => _confirmDelete(context, entrenamiento.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  color: const Color(0xFF1C1C1C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const Icon(Icons.calendar_today, color: Color(0xFF0DCAF0)),
                    title: Text(
                      data['nombre'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Objetivo: ${data['objetivo']}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings, color: Color(0xFF0DCAF0)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTrainingScreen(
                                  entrenamientoId: entrenamiento.id,
                                  initialData: data,
                                ),
                              ),
                            );
                          },
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white70),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrainingExercisesScreen(
                            entrenamientoId: entrenamiento.id,
                            entrenamientoNombre: data['nombre'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateTrainingScreen(rutinaId: rutinaId),
          ),
        ),
        backgroundColor: const Color(0xFF6A0DAD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
