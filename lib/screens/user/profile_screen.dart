import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:profit_app/constants.dart';
import 'package:profit_app/utils/level_system.dart';
import 'package:profit_app/widgets/profile_header.dart';
import 'package:profit_app/widgets/premium_status.dart';
import 'package:profit_app/widgets/level_card.dart';
import 'package:profit_app/widgets/profile_text_field.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> paymentIntent;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isPremium = false;

  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          _userData = data;
          _isPremium = data['premium'] ?? false;
          _nombreController = TextEditingController(text: data['nombre'] ?? '');
          _apellidosController =
              TextEditingController(text: data['apellidos'] ?? '');
          _emailController = TextEditingController(text: data['email'] ?? '');
          _telefonoController =
              TextEditingController(text: data['telefono'] ?? '');
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  Future<bool?> _reauthenticateUser() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        final TextEditingController passwordController = TextEditingController();
        
        return Dialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF2A2A2A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.pinkAccent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: Colors.pinkAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Verificación requerida',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Por favor, ingresa tu contraseña para continuar',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.grey[850]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      hintText: 'Contraseña',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      suffixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final User? currentUser = FirebaseAuth.instance.currentUser;
                          final AuthCredential credential = EmailAuthProvider.credential(
                            email: currentUser?.email ?? '',
                            password: passwordController.text,
                          );
                          await currentUser?.reauthenticateWithCredential(credential);
                          Navigator.pop(context, true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Contraseña incorrecta'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Verificar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final User? currentUser = FirebaseAuth.instance.currentUser;
        
        if (currentUser != null && currentUser.email != _emailController.text.trim()) {
          final bool? reauthResult = await _reauthenticateUser();
          if (reauthResult != true) {
            return;
          }

          try {
            await currentUser.verifyBeforeUpdateEmail(_emailController.text.trim());
            
            showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.black87,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: const Color(0xFF1C1C1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E1E1E),
                          Color(0xFF2A2A2A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.pinkAccent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            color: Colors.pinkAccent,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '¡Correo de verificación enviado!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hemos enviado un correo de verificación a ${_emailController.text.trim()}. Por favor, verifica tu nuevo email antes de continuar.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Entendido',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al actualizar el email: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({
          'nombre': _nombreController.text.trim(),
          'apellidos': _apellidosController.text.trim(),
          'email': _emailController.text.trim(),
          'telefono': _telefonoController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error saving profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el perfil: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : _userData == null
              ? const Center(
                  child: Text(
                    'No se pudo cargar la información del usuario.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeader(
                          name: _nombreController.text,
                          surname: _apellidosController.text,
                        ),
                        const SizedBox(height: 10),
                        _buildLevelCardWidget(),
                        const SizedBox(height: 20),
                        PremiumStatus(
                          isPremium: _isPremium,
                          onUpgrade: makePayment,
                        ),
                        const SizedBox(height: 30),
                        ProfileTextField(
                          label: 'Nombre',
                          controller: _nombreController,
                        ),
                        const SizedBox(height: 16),
                        ProfileTextField(
                          label: 'Apellidos',
                          controller: _apellidosController,
                        ),
                        const SizedBox(height: 16),
                        ProfileTextField(
                          label: 'Email',
                          controller: _emailController,
                          isEmail: true,
                        ),
                        const SizedBox(height: 16),
                        ProfileTextField(
                          label: 'Teléfono',
                          controller: _telefonoController,
                          isPhone: true,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _saveProfile,
                            child: const Text('Guardar Cambios',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildLevelCardWidget() {
    final int currentXp = _userData!['xp'] ?? 0;
    final int currentLevel = _userData!['nivel'] ?? 1;

    final bool shouldLvlUp = shouldLevelUp(currentXp, currentLevel);
    final int calculatedLevel = calculateNewLevel(currentXp, currentLevel);

    if (shouldLvlUp) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'nivel': calculatedLevel});
    }

    final int currentLevelTotalXp = totalRequiredForLevel(calculatedLevel);
    final int nextLevelTotalXp = totalRequiredForLevel(calculatedLevel + 1);
    final int xpToNext = xpToNextLevel(currentXp, calculatedLevel);

    final int xpIntoCurrentLevel = currentXp - currentLevelTotalXp;
    final int xpNeededThisLevel = nextLevelTotalXp - currentLevelTotalXp;
    final double progress =
        xpNeededThisLevel > 0 ? xpIntoCurrentLevel / xpNeededThisLevel : 1.0;

    return LevelCard(
      currentXp: currentXp,
      currentLevel: calculatedLevel,
      nextLevelTotalXp: nextLevelTotalXp,
      xpToNext: xpToNext,
      progress: progress,
    );
  }

  calculateAmount(String amount) {
    final caclculateAmount = (int.parse(amount)) * 100;
    return caclculateAmount.toString();
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Error creating payment intent: $e');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({'premium': true});

        setState(() {
          _isPremium = true;
        });

        paymentIntent = {};
      }).onError(
        (error, stackTrace) {
          throw Exception('Error displaying payment sheet: $error');
        },
      );
    } on StripeException catch (e) {
      print('Error displaying payment sheet: $e');
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Payment failed!'),
            const SizedBox(height: 20),
          ],
        ),
      );
    }
  }

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('25', 'EUR');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Profit App',
        ),
      );
      displayPaymentSheet();
    } catch (e) {
      print('Error making payment: $e');
    }
  }
}
