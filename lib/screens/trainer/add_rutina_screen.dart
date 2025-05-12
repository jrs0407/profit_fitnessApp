import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateRoutineScreen extends StatefulWidget {
  final String userId;

  const CreateRoutineScreen({super.key, required this.userId});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  int _nivel = 0;
  bool _isSaving = false;

  Future<void> _saveRoutine() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ponle un nombre a la rutina")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final routineRef = await FirebaseFirestore.instance.collection('rutinas').add({
        'nombre': name,
        'descripcion': desc,
        'entrenamientos': [],
        'creado': Timestamp.now(),
        'nivel': _nivel,
      });

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'rutinas': FieldValue.arrayUnion([routineRef.id]),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _incrementNivel() {
    setState(() {
      if (_nivel < 99) _nivel++;
    });
  }

  void _decrementNivel() {
    setState(() {
      if (_nivel > 0) _nivel--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Crear rutina', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A0DAD),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nombre de la rutina',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1C1C1C),
                hintText: 'Ej. Full Body Intermedio',
                hintStyle: const TextStyle(color: Colors.white38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Descripción',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1C1C1C),
                hintText: 'Breve descripción de la rutina...',
                hintStyle: const TextStyle(color: Colors.white38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        size: 30, color: Color(0xFF0DCAF0)),
                    onPressed: _decrementNivel,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Nivel: $_nivel',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        size: 30, color: Color(0xFF0DCAF0)),
                    onPressed: _incrementNivel,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: _isSaving
                  ? const CircularProgressIndicator(color: Color(0xFF0DCAF0))
                  : ElevatedButton.icon(
                      onPressed: _saveRoutine,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Guardar rutina', 
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A0DAD),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
