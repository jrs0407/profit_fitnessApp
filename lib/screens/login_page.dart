import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:profit_app/screens/register/register_step1.dart';
import 'package:profit_app/screens/forgot_password_screen.dart';
import 'package:profit_app/screens/trainer/trainer_screen.dart';
import 'package:profit_app/screens/user/userMain_screen.dart';
import 'package:profit_app/screens/user/user_home_screen.dart';
import 'package:profit_app/screens/admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  ParticleOptions particleOptions = ParticleOptions(
    baseColor: const Color(0xFF007AFF),
    spawnOpacity: 0.2,
    opacityChangeRate: 0.1,
    minOpacity: 0.3,
    maxOpacity: 0.8,
    particleCount: 300,
    spawnMaxRadius: 12.0,
    spawnMinRadius: 3.0,
    spawnMaxSpeed: 40.0,
    spawnMinSpeed: 10.0,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Por favor, completa todos los campos.');
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;

      if (uid != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          final isTrainer = userDoc.data()?['trainer'] ?? false;
          final isAdmin = userDoc.data()?['admin'] ?? false;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                if (isAdmin) {
                  return const AdminDashboardScreen();
                } else if (isTrainer) {
                  return const TrainerDashboardScreen();
                } else {
                  return UserMainScreen(userId: uid);
                }
              },
            ),
            (route) => false,
          );
        } else {
          _showError('Usuario autenticado pero no encontrado en la base de datos.');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showError('No existe una cuenta con ese correo.');
      } else if (e.code == 'wrong-password') {
        _showError('Contraseña incorrecta.');
      } else if (e.code == 'invalid-email') {
        _showError('Correo inválido.');
      } else {
        _showError('Error: La contraseña o el correo son incorrectos.');
      }
    } catch (e) {
      _showError('Error al iniciar sesión: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _showError('Inicio de sesión cancelado.');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final uid = user.uid;
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final userDoc = await userDocRef.get();

        if (!userDoc.exists) {
          final nombreCompleto = user.displayName ?? '';
          final partesNombre = nombreCompleto.split(' ');
          final nombre = partesNombre.isNotEmpty ? partesNombre.first : 'Usuario';
          final apellidos = partesNombre.length > 1 ? partesNombre.sublist(1).join(' ') : '';

          await userDocRef.set({
            'nombre': nombre,
            'apellidos': apellidos,
            'email': user.email ?? '',
            'telefono': '',
            'fechaNacimiento': null,
            'nivel': 0,
            'xp': 0,
            'premium': false,
            'metodoPago': [],
            'ultimosDigitosTarjeta': '',
            'trainer': false,
            'admin': false,
          });
        }

        final freshUserDoc = await userDocRef.get();
        final isTrainer = freshUserDoc.data()?['trainer'] ?? false;
        final isAdmin = freshUserDoc.data()?['admin'] ?? false;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (isAdmin) {
                return const AdminDashboardScreen();
              } else if (isTrainer) {
                return const TrainerDashboardScreen();
              } else {
                return UserRoutineDashboardScreen(userId: uid);
              }
            },
          ),
          (route) => false,
        );
      }
    } catch (e) {
      _showError('Error al iniciar sesión con Google: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    ClipOval(
                      child: Image.asset('assets/logo.png', width: 200, height: 200, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'PROFIT',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 48,
                        letterSpacing: 2,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF5E5CE6)],
                          ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                    ),
                    const SizedBox(height: 30),                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: const TextStyle(color: Color(0xFF0DCAF0)),
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF0DCAF0)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF0DCAF0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF6A0DAD)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(color: Color(0xFF0DCAF0)),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF0DCAF0)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF0DCAF0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF6A0DAD)),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF0DCAF0),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A0DAD),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                        ),
                        child: const Text('Iniciar Sesión',
                            style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text('¿Olvidaste tu contraseña?',
                              style: TextStyle(color: Color(0xFF0DCAF0))),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterStep1()),
                            );
                          },
                          child: const Text('Registrarse',
                              style: TextStyle(color: Color(0xFF0DCAF0))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: Image.asset('assets/google_logo.png', height: 24, width: 24),
                      label: const Text('Continuar con Google',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF202124),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
