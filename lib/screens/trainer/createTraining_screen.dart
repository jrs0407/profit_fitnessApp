import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTrainingScreen extends StatefulWidget {
  final String rutinaId;

  const CreateTrainingScreen({super.key, required this.rutinaId});

  @override
  State<CreateTrainingScreen> createState() => _CreateTrainingScreenState();
}

class _CreateTrainingScreenState extends State<CreateTrainingScreen> {
  final _nameController = TextEditingController();
  final _objetivoController = TextEditingController();
  int _duracion = 0;
  DateTime _fecha = DateTime.now();
  bool _isSaving = false;

  String? _diaSemana;
  final List<String> _diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  Future<void> _saveTraining() async {
    final nombre = _nameController.text.trim();
    final objetivo = _objetivoController.text.trim();

    if (nombre.isEmpty || objetivo.isEmpty || _diaSemana == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('entrenamientos').add({
        'nombre': nombre,
        'objetivo': objetivo,
        'duracion': _duracion,
        'fecha': _fecha,
        'diaSemana': _diaSemana,
        'idRutina': widget.rutinaId,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Nuevo Entrenamiento',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A0DAD),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre',
                style: TextStyle(color: Color(0xFF0DCAF0), fontSize: 16)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1C1C1C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Ej: Pierna y glúteos',
                hintStyle: const TextStyle(color: Colors.white30),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Objetivo',
                style: TextStyle(color: Color(0xFF0DCAF0), fontSize: 16)),
            const SizedBox(height: 6),
            TextField(
              controller: _objetivoController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1C1C1C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Ej: Tonificar piernas',
                hintStyle: const TextStyle(color: Colors.white30),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Duración (min)',
                style: TextStyle(color: Color(0xFF0DCAF0), fontSize: 16)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<int>(
                dropdownColor: const Color(0xFF1C1C1C),
                value: _duracion,
                isExpanded: true,
                iconEnabledColor: const Color(0xFF0DCAF0),
                underline: const SizedBox(),
                items: List.generate(
                  121,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(
                      '$i minutos',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                onChanged: (val) => setState(() => _duracion = val!),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Día de la semana',
                style: TextStyle(color: Color(0xFF0DCAF0), fontSize: 16)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                dropdownColor: const Color(0xFF1C1C1C),
                value: _diaSemana,
                isExpanded: true,
                hint: const Text('Selecciona un día',
                    style: TextStyle(color: Colors.white30)),
                iconEnabledColor: const Color(0xFF0DCAF0),
                underline: const SizedBox(),
                items: _diasSemana.map((dia) {
                  return DropdownMenuItem(
                    value: dia,
                    child: Text(dia, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _diaSemana = val),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: _isSaving
                  ? const CircularProgressIndicator(color: Color(0xFF0DCAF0))
                  : ElevatedButton.icon(
                      onPressed: _saveTraining,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Guardar Entrenamiento',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A0DAD),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
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
