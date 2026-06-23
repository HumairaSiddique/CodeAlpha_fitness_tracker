import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/workout_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/workout_tile.dart';
import '../auth/login_screen.dart';
import 'add_workout_screen.dart';
import 'progress_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  int _currentIndex = 0;
  Map<String, int> _stats = {'calories': 0, 'steps': 0, 'minutes': 0, 'workouts': 0};
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _firestoreService.getTotalStats();
    if (mounted) setState(() { _stats = stats; _statsLoading = false; });
  }

  Future<void> _deleteWorkout(String id) async {
    await _firestoreService.deleteWorkout(id);
    _loadStats();
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHome(user, greeting),
          const ProgressScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
                );
                _loadStats();
              },
              backgroundColor: const Color(0xFF00C6AE),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHome(User? user, String greeting) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadStats,
        color: const Color(0xFF00C6AE),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: GoogleFonts.inter(
                              fontSize: 14, color: Colors.white38),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.displayName?.split(' ').first ?? 'Athlete',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _signOut,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white10),
                        ),
                        child: user?.photoURL != null
                            ? ClipOval(
                                child: Image.network(user!.photoURL!,
                                    fit: BoxFit.cover))
                            : const Icon(Icons.person_outline,
                                color: Colors.white54, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Today's Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C6AE), Color(0xFF6C63FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d').format(DateTime.now()),
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Stay consistent,\nkeep moving! 💪',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.local_fire_department,
                          color: Colors.white, size: 48),
                    ],
                  ),
                ),
              ),
            ),

            // Stats Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Time Stats',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _statsLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF00C6AE)))
                        : GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            children: [
                              StatCard(
                                label: 'Calories',
                                value: _stats['calories'].toString(),
                                unit: 'kcal',
                                icon: Icons.local_fire_department_outlined,
                                color: const Color(0xFFFF6B6B),
                              ),
                              StatCard(
                                label: 'Steps',
                                value: _stats['steps'].toString(),
                                unit: 'steps',
                                icon: Icons.directions_walk_outlined,
                                color: const Color(0xFF00C6AE),
                              ),
                              StatCard(
                                label: 'Time',
                                value: _stats['minutes'].toString(),
                                unit: 'min',
                                icon: Icons.timer_outlined,
                                color: const Color(0xFF6C63FF),
                              ),
                              StatCard(
                                label: 'Workouts',
                                value: _stats['workouts'].toString(),
                                unit: 'total',
                                icon: Icons.fitness_center_outlined,
                                color: const Color(0xFFFFBE0B),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),

            // Recent Workouts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Text(
                  'Recent Workouts',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            StreamBuilder<List<WorkoutModel>>(
              stream: _firestoreService.getWorkoutsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                          color: Color(0xFF00C6AE)),
                    )),
                  );
                }

                final workouts = snapshot.data ?? [];

                if (workouts.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.fitness_center,
                                color: Colors.white12, size: 60),
                            const SizedBox(height: 16),
                            Text(
                              'No workouts yet.\nTap + to log your first!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  color: Colors.white30, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => WorkoutTile(
                        workout: workouts[index],
                        onDelete: () => _deleteWorkout(workouts[index].id),
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddWorkoutScreen(
                                  existingWorkout: workouts[index]),
                            ),
                          );
                          _loadStats();
                        },
                      ),
                      childCount: workouts.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF00C6AE),
        unselectedItemColor: Colors.white30,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }
}
