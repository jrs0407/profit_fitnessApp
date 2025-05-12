import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profit_app/screens/trainer/add_rutina_screen.dart';
import 'package:profit_app/screens/trainer/trainings_screen.dart';

class UserRoutinesScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const UserRoutinesScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  Future<bool?> _confirmDelete(BuildContext context, String rutinaId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('¿Eliminar rutina?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta rutina?',
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
          .collection('rutinas')
          .doc(rutinaId)
          .delete();
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'rutinas': FieldValue.arrayRemove([rutinaId]),
      });

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
        title: Text(
          'Rutinas de $userName',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A0DAD),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6A0DAD)));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> rutinaIds = userData['rutinas'] ?? [];

          if (rutinaIds.isEmpty) {
            return const Center(
              child: Text(
                'Este usuario no tiene rutinas asignadas.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: rutinaIds.length,
            itemBuilder: (context, index) {
              final rutinaId = rutinaIds[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('rutinas')
                    .doc(rutinaId)
                    .get(),
                builder: (context, rutinaSnapshot) {
                  if (!rutinaSnapshot.hasData || !rutinaSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final rutinaData =
                      rutinaSnapshot.data!.data() as Map<String, dynamic>;

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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF6A0DAD),
                          child:
                              Icon(Icons.fitness_center, color: Colors.white),
                        ),
                        title: Text(
                          rutinaData['nombre'] ?? 'Sin nombre',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          rutinaData['descripcion'] ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white54, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RoutineTrainingsScreen(
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateRoutineScreen(userId: userId),
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
