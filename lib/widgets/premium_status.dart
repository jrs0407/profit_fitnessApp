import 'package:flutter/material.dart';

class PremiumFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const PremiumFeature({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 22),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class PremiumStatus extends StatelessWidget {
  final bool isPremium;
  final VoidCallback? onUpgrade;

  const PremiumStatus({
    Key? key,
    required this.isPremium,
    this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [
                  const Color(0xFFFFD700).withOpacity(0.2),
                  const Color(0xFFFFA500).withOpacity(0.2)
                ]
              : [Colors.grey[900]!, const Color(0xFF1E1E1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPremium ? Colors.amber.withOpacity(0.5) : Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? 'MIEMBRO PREMIUM' : 'CUENTA ESTÁNDAR',
                    style: TextStyle(
                      color: isPremium ? Colors.amber : Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPremium
                        ? '¡Disfruta de todos los beneficios!'
                        : 'Mejora tu experiencia',
                    style: TextStyle(
                      color: isPremium
                          ? Colors.amber.withOpacity(0.7)
                          : Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Icon(
                isPremium ? Icons.star : Icons.star_border,
                color: isPremium ? Colors.amber : Colors.grey,
                size: 30,
              ),
            ],
          ),
          if (!isPremium) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.workspace_premium, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'ACTUALIZAR A PREMIUM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                PremiumFeature(
                  icon: Icons.fitness_center,
                  text: 'Rutinas exclusivas',
                ),
                SizedBox(width: 20),
                PremiumFeature(
                  icon: Icons.person_outline,
                  text: 'Entrenador personal',
                ),
                SizedBox(width: 20),
                PremiumFeature(
                  icon: Icons.play_circle_outline,
                  text: 'Videos HD',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}