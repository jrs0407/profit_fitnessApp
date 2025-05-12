import 'package:flutter/material.dart';
import 'achievement_badge.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String surname;

  const ProfileHeader({
    Key? key,
    required this.name,
    required this.surname,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.pinkAccent.withOpacity(0.7),
                  Colors.deepPurpleAccent.withOpacity(0.7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.pinkAccent.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name $surname',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AchievementBadge(
                        icon: Icons.local_fire_department,
                        color: Colors.orangeAccent,
                        label: '7 días racha',
                      ),
                      const SizedBox(width: 8),
                      AchievementBadge(
                        icon: Icons.fitness_center,
                        color: Colors.greenAccent,
                        label: '10 rutinas',
                      ),
                      const SizedBox(width: 8),
                      AchievementBadge(
                        icon: Icons.star,
                        color: Colors.amberAccent,
                        label: '5.0 rating',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}