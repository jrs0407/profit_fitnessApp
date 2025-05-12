import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTrainingScreen extends StatefulWidget {
  final String entrenamientoId;
  final Map<String, dynamic> initialData;

  const EditTrainingScreen({
    super.key,
    required this.entrenamientoId,
    required this.initialData,
  });

  @override
  State<EditTrainingScreen> createState() => _EditTrainingScreenState();
}

class _EditTrainingScreenState extends State<EditTrainingScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _objetivoController;
  late TextEditingController _duracionController;
  String _diaSemana = 'Lunes';

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
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _objetivoController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  Future<void> _upgradeTraining() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('entrenamientos')
          .doc(widget.entrenamientoId)
          .update({
        'nombre': _nombreController.text,
        'objetivo': _objetivoController.text,
        'duracion': int.tryParse(_duracionController.text) ?? 0,
        'diaSemana': _diaSemana,
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
