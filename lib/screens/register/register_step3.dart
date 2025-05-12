import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_background/animated_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_page.dart';
import '../../models/user_model.dart';
import '../../widgets/phone_field.dart';
import '../../widgets/date_picker_field.dart';

class RegisterStep3 extends StatefulWidget {
  final UserModel user;

  const RegisterStep3({super.key, required this.user});

  @override
  State<RegisterStep3> createState() => _RegisterStep3State();
}

class _RegisterStep3State extends State<RegisterStep3> with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  ParticleOptions particleOptions = ParticleOptions(
    baseColor: const Color(0xFF5E5CE6),
    spawnOpacity: 0.3,
    opacityChangeRate: 0.05,
    minOpacity: 0.3,
    maxOpacity: 0.8,
    particleCount: 250,
    spawnMaxRadius: 10.0,
    spawnMinRadius: 2.0,
    spawnMaxSpeed: 25.0,
    spawnMinSpeed: 10.0,
  );

  Future<void> _finishRegistration() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    widget.user.phone = phone;
    widget.user.birthdate = _selectedDate!;
    widget.user.nivel = 1;
    widget.user.xp = 0;
    widget.user.trainer = false;
    widget.user.admin = false;
    widget.user.metodoPago = ['Tarjeta de crédito'];
    widget.user.ultimosDigitosTarjeta = '';

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: widget.user.email!,
        password: widget.user.password!,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(widget.user.toJson());

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Registro exitoso!')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Este correo ya está registrado.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es demasiado débil.';
      } else {
        errorMessage = 'Error: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBackground(
            behaviour: RandomParticleBehaviour(options: particleOptions),
            vsync: this,
            child: Container(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Paso 3: Información final',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 38,
                      letterSpacing: 1.5,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFF6A0DAD), Color(0xFF007AFF)],
                        ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Imagen + mensaje añadido
                  Column(
                    children: [
                      Image.asset(
                        'assets/women.png',
                        height: 200,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ya falta poco para que formes parte de este nuevo Imperio',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  PhoneField(
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 20),
                  DatePickerField(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E5CE6),
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Atrás',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF0DCAF0))
                      : ElevatedButton(
                          onPressed: _finishRegistration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0DCAF0),
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Finalizar registro',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
