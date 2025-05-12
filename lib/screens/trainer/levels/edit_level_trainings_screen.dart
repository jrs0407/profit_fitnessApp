import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditLevelTrainingScreen extends StatefulWidget {
  final String entrenamientoId;
  final Map<String, dynamic> initialData;

  const EditLevelTrainingScreen({
    super.key,
    required this.entrenamientoId,
    required this.initialData,
  });

  @override
  State<EditLevelTrainingScreen> createState() => _EditLevelTrainingScreenState();
}

class _EditLevelTrainingScreenState extends State<EditLevelTrainingScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _objetivoController;
  late TextEditingController _duracionController;
  String _diaSemana = 'Lunes';
  int _nivel = 0;

  final List<String> _diasSemana = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.initialData['nombre']);
    _objetivoController = TextEditingController(text: widget.initialData['objetivo']);
    _duracionController = TextEditingController(text: widget.initialData['duracion'].toString());
    _diaSemana = widget.initialData['diaSemana'] ?? 'Lunes';
    _nivel = widget.initialData['nivel'] ?? 0;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _objetivoController.dispose();
    _duracionController.dispose();
    super.dispose();
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

  Future<void> _upgradeTraining() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('entrenamientoslvl')
          .doc(widget.entrenamientoId)
          .update({
        'nombre': _nombreController.text,
        'objetivo': _objetivoController.text,
        'duracion': int.tryParse(_duracionController.text) ?? 0,
        'diaSemana': _diaSemana,
        'nivel': _nivel,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrenamiento actualizado')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Editar Entrenamiento', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A0DAD),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Nombre', style: TextStyle(color: Color(0xFF0DCAF0))),
              const SizedBox(height: 4),
              TextFormField(
                controller: _nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              const Text('Objetivo', style: TextStyle(color: Color(0xFF0DCAF0))),
              const SizedBox(height: 4),
              TextFormField(
                controller: _objetivoController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              const Text('Duración (min)', style: TextStyle(color: Color(0xFF0DCAF0))),
              const SizedBox(height: 4),
              TextFormField(
                controller: _duracionController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (int.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text('Día de la semana', style: TextStyle(color: Color(0xFF0DCAF0))),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _diaSemana,
                dropdownColor: const Color(0xFF1C1C1C),
                decoration: _inputDecoration(),
                style: const TextStyle(color: Colors.white),
                items: _diasSemana
                    .map((dia) => DropdownMenuItem(
                          value: dia,
                          child: Text(dia),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _diaSemana = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              const Text('Nivel', style: TextStyle(color: Color(0xFF0DCAF0))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        size: 30, color: Color(0xFF0DCAF0)),
                    onPressed: _decrementNivel,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$_nivel',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        size: 30, color: Color(0xFF0DCAF0)),
                    onPressed: _incrementNivel,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A0DAD),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Actualizar', style: TextStyle(color: Colors.white)),
                onPressed: _upgradeTraining,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1C1C1C),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF0DCAF0)),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
