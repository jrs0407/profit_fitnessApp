import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditLevelRoutineScreen extends StatefulWidget {
  final String rutinaId;
  final Map<String, dynamic> initialData;

  const EditLevelRoutineScreen({
    super.key,
    required this.rutinaId,
    required this.initialData,
  });

  @override
  State<EditLevelRoutineScreen> createState() => _EditLevelRoutineScreenState();
}

class _EditLevelRoutineScreenState extends State<EditLevelRoutineScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late int _nivel;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['nombre']);
    _descController = TextEditingController(text: widget.initialData['descripcion']);
    _nivel = widget.initialData['nivel'] ?? 0;
  }

  Future<void> _updateRoutine() async {
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
      await FirebaseFirestore.instance
          .collection('rutinaslvl')
          .doc(widget.rutinaId)
          .update({
        'nombre': name,
        'descripcion': desc,
        'nivel': _nivel,
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
        title: const Text('Editar rutina por nivel', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A0DAD),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre de la rutina', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Ej. Full Body Intermedio'),
            ),
            const SizedBox(height: 20),
            const Text('Descripción', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: _inputDecoration('Breve descripción de la rutina...'),
            ),
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF0DCAF0)),
                    onPressed: _decrementNivel,
                  ),
                  const SizedBox(width: 12),
                  Text('Nivel: $_nivel',
                      style: const TextStyle(fontSize: 22, color: Colors.white)),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0DCAF0)),
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
                      onPressed: _updateRoutine,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Actualizar rutina',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A0DAD),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1C1C1C),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
