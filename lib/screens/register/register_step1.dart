import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_step2.dart';
import '../login_page.dart'; 
import '../../models/user_model.dart'; 
import '../../widgets/custom_text_field.dart';

class RegisterStep1 extends StatefulWidget {
  const RegisterStep1({super.key});

  @override
  State<RegisterStep1> createState() => _RegisterStep1State();
}

class _RegisterStep1State extends State<RegisterStep1> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  late AnimationController _controller;

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
    _nameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    final name = _nameController.text.trim();
    final surname = _lastnameController.text.trim();

    if (name.isEmpty || surname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa ambos campos')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterStep2(
          user: UserModel(name: name, surname: surname),
        ),
      ),
    );
  }

  void _goToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(), 
      ),
    );
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
                    'Bienvenido a Profit',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 48,
                      letterSpacing: 2,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFF007AFF), Color(0xFF5E5CE6)],
                        ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/gym.png', 
                        height: 300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aquí comienza tu camino GUERRERO',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _nameController,
                    label: 'Nombre',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _lastnameController,
                    label: 'Apellidos',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      // Botón de "Login" a la izquierda
                      TextButton(
                        onPressed: _goToLoginPage,
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      // Botón "Siguiente"
                      ElevatedButton(
                        onPressed: _goToNextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A0DAD),
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Siguiente',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
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
