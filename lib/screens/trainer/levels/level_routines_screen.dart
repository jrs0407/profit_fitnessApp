import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profit_app/screens/trainer/levels/add_level_routine_screen.dart';
import 'package:profit_app/screens/trainer/levels/edit_level_routine_screen.dart'; // Asegúrate de crear esta screen
import 'package:profit_app/screens/trainer/levels/level_trainings_screen.dart';

class LevelRoutinesScreen extends StatelessWidget {
  const LevelRoutinesScreen({super.key});

  Future<bool?> _confirmDelete(BuildContext context, String rutinaId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('¿Eliminar rutina?', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta rutina?',
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
      await FirebaseFirestore.instance.collection('rutinaslvl').doc(rutinaId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rutina eliminada')),
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
        title: const Text('Rutinas por nivel', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A0DAD),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rutinaslvl')
            .orderBy('nivel')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A0DAD)),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No hay rutinas disponibles.', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final rutina = docs[index];
              final rutinaData = rutina.data() as Map<String, dynamic>;
              final rutinaId = rutina.id;

              return Dismissible(
                key: Key(rutinaId),
                direction: DismissDirection.startToEnd,
                confirmDismiss: (_) => _confirmDelete(context, rutinaId),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  color: const Color(0xFF1C1C1C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF6A0DAD),
                      child: Icon(Icons.fitness_center, color: Colors.white),
                    ),
                    title: Text(
                      rutinaData['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nivel: ${rutinaData['nivel'] ?? 'No especificado'}',
                          style: const TextStyle(color: Color(0xFF0DCAF0), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rutinaData['descripcion'] ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings, color: Color(0xFF6A0DAD)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditLevelRoutineScreen(
                                  rutinaId: rutinaId,
                                  initialData: rutinaData,
                                ),
                              ),
                            );
                          },
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LevelTrainingsScreen(
                            rutinaId: rutinaId,
                            rutinaNombre: rutinaData['nombre'] ?? 'Rutina',
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateLevelRoutineScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF6A0DAD),
        child: const Icon(Icons.add, color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}