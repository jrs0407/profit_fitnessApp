import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_app/main.dart';
import 'package:profit_app/screens/user/userMain_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:profit_app/utils/level_system.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:profit_app/widgets/control_button.dart';

class CountdownScreen extends StatefulWidget {
  final int minutos;
  final String nombreEjercicio;
  final String? multimediaUrl;
  final int xpGanado;
  final String userId;
  final double peso;

  const CountdownScreen({
    required this.minutos,
    required this.nombreEjercicio,
    this.multimediaUrl,
    required this.xpGanado,
    required this.userId,
    required this.peso,
    Key? key,
  }) : super(key: key);

  @override
  _CountdownScreenState createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with SingleTickerProviderStateMixin {
  late int _counter;
  late int _initialCounter;
  late AnimationController _controller;
  YoutubePlayerController? _youtubeController;
  Timer? _timer;
  bool _isRunning = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initialCounter = widget.minutos * 60;
    _counter = _initialCounter;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _counter),
    )..forward();
    _startTimer();

    if (widget.multimediaUrl != null &&
        YoutubePlayer.convertUrlToId(widget.multimediaUrl!) != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(widget.multimediaUrl!)!,
        flags: YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_counter == 0) {
        timer.cancel();
        HapticFeedback.heavyImpact();
        await Future.delayed(Duration(milliseconds: 200));
        HapticFeedback.heavyImpact();
        await _sumarXp();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UserMainScreen(userId: widget.userId),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          _counter--;
          _controller.value = 1 - (_counter / _initialCounter);
        });
      }
    });
  }

  Future<void> _sumarXp() async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(widget.userId);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        int xpActual = snapshot.data()?['xp'] ?? 0;
        int nivelActual = snapshot.data()?['nivel'] ?? 1;

        int nuevoXp = xpActual + widget.xpGanado;
        int nuevoNivel = calculateNewLevel(nuevoXp, nivelActual);
        
        // Si hay cambio de nivel, actualizamos ambos valores
        await userRef.update({
          'xp': nuevoXp,
          'nivel': nuevoNivel,
        });

        // Guardar log del ejercicio realizado
        await FirebaseFirestore.instance.collection('logs_ejercicios').add({
          'userId': widget.userId,
          'nombreEjercicio': widget.nombreEjercicio,
          'peso': widget.peso,
          'fecha': FieldValue.serverTimestamp(),
          'xpGanado': widget.xpGanado,
          'nivelAnterior': nivelActual,
          'nivelNuevo': nuevoNivel,
        });

        // Si subió de nivel, mostrar solo la animación del nivel más alto alcanzado
        if (nuevoNivel > nivelActual) {
          await _showLevelUpAnimation(nuevoNivel);
          // Enviar notificación de subida de nivel
          await _sendLevelUpNotification(nivelActual, nuevoNivel);
        } else {
          // Si no subió de nivel, enviar la notificación motivacional normal
          await _sendMotivationalNotification();
        }
      }
    } catch (e) {
      print('Error actualizando XP o guardando log: $e');
    }
  }

  Future<void> _sendLevelUpNotification(int nivelAnterior, int nuevoNivel) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'level_up_channel',
      'Level Up Notifications',
      channelDescription: 'Notificaciones de subida de nivel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'level_up_ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    String message = nuevoNivel - nivelAnterior > 1
        ? '¡Impresionante! Has subido ${nuevoNivel - nivelAnterior} niveles'
        : '¡Felicidades! Has subido de nivel';

    await flutterLocalNotificationsPlugin.show(
      3,
      '¡Has alcanzado el nivel $nuevoNivel!',
      '$message\n¡Sigue así, campeón!',
      notificationDetails,
    );

    print('Notificación de subida de nivel enviada.');
  }

  Future<void> _sendMotivationalNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'motivational_channel',
      'Motivational Notifications',
      channelDescription: 'Notificaciones motivacionales después de un ejercicio',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'motivational_ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      2,
      '¡Excelente trabajo!',
      '¡Has completado tu ejercicio y ganado ${widget.xpGanado} XP! Sigue así.',
      notificationDetails,
    );

    print('Notificación motivacional enviada.');
  }

  Future<void> _showLevelUpAnimation(int nuevoNivel) async {
    await _audioPlayer.play(AssetSource('sounds/level_up.wav'));
    
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: ScaleTransition(
              scale:
                  CurvedAnimation(parent: animation, curve: Curves.elasticOut),
              child: FadeTransition(
                opacity: animation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurpleAccent.withOpacity(0.7),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/animations/level_up.json',
                        repeat: false,
                        width: 200,
                        onLoaded: (composition) {
                          Future.delayed(
                              composition.duration + Duration(seconds: 1), () {
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '¡Subiste de nivel!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nivel $nuevoNivel',
                        style: TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  void _pauseTimer() {
    _timer?.cancel();
    _controller.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _resumeTimer() {
    _startTimer();
    _controller.forward();
    setState(() {
      _isRunning = true;
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    _counter = _initialCounter;
    _controller.reset();
    _controller.forward();
    _startTimer();
    setState(() {
      _isRunning = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _youtubeController?.dispose();
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenSize.height - MediaQuery.of(context).padding.top,
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurpleAccent.withOpacity(0.2), Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserMainScreen(userId: widget.userId),
                                ),
                                (Route<dynamic> route) => false,
                              ),
                            ),
                            Text(
                              '+${widget.xpGanado} XP',
                              style: const TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            Text(
                              widget.nombreEjercicio,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.peso > 0 ? '${widget.peso} kg' : 'Sin peso adicional',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_youtubeController != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Container(
                      width: screenSize.width * 0.85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: YoutubePlayer(
                        controller: _youtubeController!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.deepPurpleAccent,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.05,
                    horizontal: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: screenSize.width * 0.7,
                            height: screenSize.width * 0.7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurpleAccent.withOpacity(0.1),
                                  Colors.pinkAccent.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: screenSize.width * 0.6,
                            height: screenSize.width * 0.6,
                            child: CircularProgressIndicator(
                              value: 1.0 - _controller.value,
                              strokeWidth: 15,
                              backgroundColor: Colors.white10,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _counter < 10 ? Colors.redAccent : Colors.deepPurpleAccent,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${_counter ~/ 60}:${(_counter % 60).toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenSize.width * 0.15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tiempo restante",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ControlButton(
                              icon: _isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill,
                              color: _isRunning ? Colors.amber : Colors.green,
                              onPressed: () {
                                if (_isRunning) {
                                  _pauseTimer();
                                } else {
                                  _resumeTimer();
                                }
                              },
                            ),
                            ControlButton(
                              icon: Icons.restart_alt,
                              color: Colors.blue,
                              onPressed: _restartTimer,
                            ),
                            ControlButton(
                              icon: Icons.stop_circle,
                              color: Colors.red,
                              onPressed: () async {
                                await _sumarXp();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserMainScreen(userId: widget.userId),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
