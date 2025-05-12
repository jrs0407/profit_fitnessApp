import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:profit_app/widgets/custom_text_input.dart';
import 'package:profit_app/widgets/custom_stepper.dart';
import 'package:profit_app/widgets/media_preview.dart';

class CreateLevelExerciseScreen extends StatefulWidget {
  final String entrenamientoId;

  const CreateLevelExerciseScreen({super.key, required this.entrenamientoId});

  @override
  State<CreateLevelExerciseScreen> createState() => _CreateLevelExerciseScreenState();
}

class _CreateLevelExerciseScreenState extends State<CreateLevelExerciseScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _xpController = TextEditingController();
  final _pesoController = TextEditingController();
  final _tiempoController = TextEditingController();
  final _mediaUrlController = TextEditingController();
  YoutubePlayerController? _youtubeController;

  int _series = 0;
  int _reps = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mediaUrlController.addListener(() {
      final videoId = YoutubePlayer.convertUrlToId(_mediaUrlController.text.trim());
      if (videoId != null) {
        setState(() {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(autoPlay: false),
          );
        });
      } else {
        setState(() {
          _youtubeController = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    final nombre = _nameController.text.trim();
    final desc = _descController.text.trim();
    final mediaUrl = _mediaUrlController.text.trim();
    final xp = int.tryParse(_xpController.text.trim()) ?? 0;
    final peso = double.tryParse(_pesoController.text.trim()) ?? 0;
    final tiempo = int.tryParse(_tiempoController.text.trim()) ?? 0;

    if (nombre.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('ejercicioslvl').add({
        'nombre': nombre,
        'descripcion': desc,
        'series': _series,
        'repeticiones': _reps,
        'peso': peso,
        'xp': xp,
        'tiempoEstimado': tiempo,
        'multimedia': mediaUrl,
        'idEntrenamiento': widget.entrenamientoId,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Nuevo Ejercicio',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A0DAD),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextInput(
              label: 'Nombre',
              controller: _nameController,
            ),
            CustomTextInput(
              label: 'Descripción',
              controller: _descController,
            ),
            CustomTextInput(
              label: 'URL de video o imagen',
              controller: _mediaUrlController,
            ),
            MediaPreview(
              url: _mediaUrlController.text.trim(),
              youtubeController: _youtubeController,
            ),
            CustomStepper(
              label: 'Series',
              value: _series,
              onChanged: (val) => setState(() => _series = val),
            ),
            CustomStepper(
              label: 'Repeticiones',
              value: _reps,
              onChanged: (val) => setState(() => _reps = val),
            ),
            CustomTextInput(
              label: 'Peso (kg)',
              controller: _pesoController,
              isNumber: true,
            ),
            CustomTextInput(
              label: 'XP',
              controller: _xpController,
              isNumber: true,
            ),
            CustomTextInput(
              label: 'Tiempo Estimado (min)',
              controller: _tiempoController,
              isNumber: true,
            ),
            const SizedBox(height: 30),
            Center(
              child: _isSaving
                  ? const CircularProgressIndicator(color: Color(0xFF0DCAF0))
                  : ElevatedButton.icon(
                      onPressed: _saveExercise,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text("Guardar Ejercicio",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A0DAD),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
