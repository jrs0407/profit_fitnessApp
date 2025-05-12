import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profit_app/screens/trainer/trainer_screen.dart';
import 'package:profit_app/widgets/stats_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Panel de Administración', 
          style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A0DAD),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6A0DAD),
                        ),
                      );
                    }

                    final users = snapshot.data!.docs;
                    final totalUsers = users.length;
                    final totalTrainers = users.where((doc) => 
                      doc['trainer'] == true).length;
                    final totalPremium = users.where((doc) => 
                      doc['premium'] == true).length;

                    return Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Total Usuarios',
                            value: totalUsers.toString(),
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatsCard(
                            title: 'Entrenadores',
                            value: totalTrainers.toString(),
                            color: const Color(0xFF6A0DAD),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatsCard(
                            title: 'Premium',
                            value: totalPremium.toString(),
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar usuarios...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6A0DAD)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white)),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6A0DAD)),
                  );
                }

                var users = snapshot.data!.docs;

                if (_searchQuery.isNotEmpty) {
                  users = users.where((doc) {
                    final userData = doc.data() as Map<String, dynamic>;
                    final fullName = '${userData['nombre']} ${userData['apellidos']}'
                        .toLowerCase();
                    final email = userData['email'].toString().toLowerCase();
                    final searchLower = _searchQuery.toLowerCase();
                    return fullName.contains(searchLower) || 
                           email.contains(searchLower);
                  }).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userData = user.data() as Map<String, dynamic>;
                    final bool isTrainer = userData['trainer'] ?? false;
                    final bool isPremium = userData['premium'] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1C1C1C),
                            const Color(0xFF2A2A2A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF6A0DAD),
                                const Color(0xFFEC407A),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          '${userData['nombre']} ${userData['apellidos']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['email'] ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isTrainer
                                        ? const Color(0xFF6A0DAD).withOpacity(0.2)
                                        : const Color(0xFFEC407A).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isTrainer ? 'Entrenador' : 'Usuario',
                                    style: TextStyle(
                                      color: isTrainer
                                          ? const Color(0xFF6A0DAD)
                                          : const Color(0xFFEC407A),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isPremium)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Premium',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: isTrainer,
                              onChanged: (value) async {
                                if (value && isPremium) {
                                  // Si activamos trainer y premium está activo, desactivamos premium
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.id)
                                      .update({
                                    'trainer': value,
                                    'premium': false
                                  });
                                } else {
                                  // Solo actualizamos trainer
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.id)
                                      .update({'trainer': value});
                                }
                              },
                              activeColor: const Color(0xFF6A0DAD),
                            ),
                            Switch(
                              value: isPremium,
                              onChanged: (value) async {
                                if (value && isTrainer) {
                                  // Si activamos premium y trainer está activo, desactivamos trainer
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.id)
                                      .update({
                                    'premium': value,
                                    'trainer': false
                                  });
                                } else {
                                  // Solo actualizamos premium
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.id)
                                      .update({'premium': value});
                                }
                              },
                              activeColor: Colors.amber,
                            ),
                            if (isTrainer)
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Color(0xFF6A0DAD),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TrainerDashboardScreen(),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}