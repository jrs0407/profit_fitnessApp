import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profit_app/screens/trainer/add_exercise_screen.dart';
import 'package:profit_app/screens/trainer/edit_exercise_screen.dart';

class TrainingExercisesScreen extends StatelessWidget {
  final String entrenamientoId;
  final String entrenamientoNombre;

  const TrainingExercisesScreen({
    super.key,
    required this.entrenamientoId,
    required this.entrenamientoNombre,
  });

  Future<bool?> _confirmDelete(BuildContext context, String ejercicioId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('¿Eliminar ejercicio?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este ejercicio?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF0DCAF0))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('ejercicios')
          .doc(ejercicioId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ejercicio eliminado')),
      );
      return true;
    }

    return false;
  }

  void _showOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('¿Qué quieres hacer?',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CreateExerciseScreen(entrenamientoId: entrenamientoId),
                ),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.add, color: Color(0xFF0DCAF0)),
                SizedBox(width: 10),
                Text('Crear ejercicio nuevo',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _showSelectExistingExercise(context);
            },
            child: const Row(
              children: [
                Icon(Icons.fitness_center, color: Color(0xFF0DCAF0)),
                SizedBox(width: 10),
                Text('Añadir ejercicio existente',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectExistingExercise(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedExerciseId;
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Seleccionar ejercicio existente',
              style: TextStyle(color: Colors.white)),
          content: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('ejercicios').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF0DCAF0)));
              }

              final ejercicios = snapshot.data!.docs;

              if (ejercicios.isEmpty) {
                return const Text('No hay ejercicios disponibles.',
                    style: TextStyle(color: Colors.white70));
              }

              // Filtrar duplicados por nombre normalizado
              final Map<String, QueryDocumentSnapshot> ejerciciosUnicos = {};
              for (var doc in ejercicios) {
                final data = doc.data() as Map<String, dynamic>;
                final nombre = (data['nombre'] ?? '').toString();
                final normalizado = nombre.toLowerCase().replaceAll(RegExp(r'\s+'), '');

                if (!ejerciciosUnicos.containsKey(normalizado)) {
                  ejerciciosUnicos[normalizado] = doc;
                }
              }

              return DropdownButtonFormField<String>(
                dropdownColor: Colors.grey[850],
                value: selectedExerciseId,
                items: ejerciciosUnicos.entries.map((entry) {
                  final doc = entry.value;
                  final data = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(
                      data['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedExerciseId = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Ejercicio',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0DCAF0)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: Color(0xFF0DCAF0))),
            ),
            TextButton(
              onPressed: () async {
                if (selectedExerciseId != null) {
                  final selectedDoc = await FirebaseFirestore.instance
                      .collection('ejercicios')
                      .doc(selectedExerciseId)
                      .get();

                  final data = selectedDoc.data() as Map<String, dynamic>;

                  await FirebaseFirestore.instance.collection('ejercicios').add({
                    ...data,
                    'idEntrenamiento': entrenamientoId,
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ejercicio añadido al entrenamiento')),
                  );
                }
              },
              child: const Text('Añadir',
                  style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Ejercicios de $entrenamientoNombre',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A0DAD),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ejercicios')
            .where('idEntrenamiento', isEqualTo: entrenamientoId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0DCAF0)));
          }

          final ejercicios = snapshot.data!.docs;

          if (ejercicios.isEmpty) {
            return const Center(
              child: Text('No hay ejercicios.',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            );
          }

          return ListView.builder(
            itemCount: ejercicios.length,
            itemBuilder: (context, index) {
              final doc = ejercicios[index];
              final ejercicio = doc.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.startToEnd,
                confirmDismiss: (_) => _confirmDelete(context, doc.id),
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  color: const Color(0xFF1C1C1C),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    leading: const Icon(Icons.fitness_center,
                        color: Color(0xFF0DCAF0), size: 30),
                    title: Text(
                      ejercicio['nombre'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                    subtitle: Text(
                      '${ejercicio['series']}x${ejercicio['repeticiones']} - ${ejercicio['peso']} kg',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    trailing: Text(
                      '+${ejercicio['xp']} XP',
                      style: const TextStyle(
                          color: Color(0xFF0DCAF0),
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditExerciseScreen(ejercicioId: doc.id),
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
        onPressed: () => _showOptions(context),
        backgroundColor: const Color(0xFF6A0DAD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
