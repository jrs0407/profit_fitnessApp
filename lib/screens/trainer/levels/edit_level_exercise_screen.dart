import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:profit_app/widgets/custom_text_input.dart';
import 'package:profit_app/widgets/custom_stepper.dart';
import 'package:profit_app/widgets/media_preview.dart';

class EditLevelExerciseScreen extends StatefulWidget {
  final String ejercicioId;

  const EditLevelExerciseScreen({super.key, required this.ejercicioId});

  @override
  State<EditLevelExerciseScreen> createState() => _EditLevelExerciseScreenState();
}

class _EditLevelExerciseScreenState extends State<EditLevelExerciseScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _mediaUrlController = TextEditingController();
  final _xpController = TextEditingController();
  final _pesoController = TextEditingController();
  final _tiempoController = TextEditingController();
  int _series = 0;
  int _reps = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  YoutubePlayerController? _youtubeController;

  Future<void> _loadExercise() async {
    final doc = await FirebaseFirestore.instance
        .collection('ejercicioslvl')
        .doc(widget.ejercicioId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['nombre'] ?? '';
      _descController.text = data['descripcion'] ?? '';
      _mediaUrlController.text = data['multimedia'] ?? '';
      _xpController.text = data['xp'].toString();
      _pesoController.text = data['peso'].toString();
      _tiempoController.text = data['tiempoEstimado'].toString();
      _series = data['series'] ?? 0;
      _reps = data['repeticiones'] ?? 0;
      _initMediaPreview(data['multimedia']);
    }
    setState(() => _isLoading = false);
  }

  void _initMediaPreview(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false),
      );
    } else {
      _youtubeController = null;
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('ejercicioslvl')
          .doc(widget.ejercicioId)
          .update({
        'nombre': _nameController.text.trim(),
        'descripcion': _descController.text.trim(),
        'multimedia': _mediaUrlController.text.trim(),
        'xp': int.tryParse(_xpController.text.trim()) ?? 0,
        'peso': double.tryParse(_pesoController.text.trim()) ?? 0,
        'tiempoEstimado': int.tryParse(_tiempoController.text.trim()) ?? 0,
        'series': _series,
        'repeticiones': _reps,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Ejercicio actualizado')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _mediaUrlController.addListener(() {
      setState(() {
        _initMediaPreview(_mediaUrlController.text.trim());
      });
    });
    _loadExercise();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Editar Ejercicio',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A0DAD),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0DCAF0)),
            )
          : SingleChildScrollView(
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
                    label: 'URL de multimedia',
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
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text("Guardar Cambios",
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
