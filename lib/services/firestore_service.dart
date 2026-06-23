import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _workoutsRef =>
      _firestore.collection('users').doc(_uid).collection('workouts');

  // Add Workout
  Future<void> addWorkout(WorkoutModel workout) async {
    final id = _uuid.v4();
    final w = WorkoutModel(
      id: id,
      userId: _uid,
      type: workout.type,
      durationMinutes: workout.durationMinutes,
      caloriesBurned: workout.caloriesBurned,
      steps: workout.steps,
      notes: workout.notes,
      date: workout.date,
    );
    await _workoutsRef.doc(id).set(w.toMap());
  }

  // Update Workout
  Future<void> updateWorkout(WorkoutModel workout) async {
    await _workoutsRef.doc(workout.id).update(workout.toMap());
  }

  // Delete Workout
  Future<void> deleteWorkout(String workoutId) async {
    await _workoutsRef.doc(workoutId).delete();
  }

  // Get all workouts stream
  Stream<List<WorkoutModel>> getWorkoutsStream() {
    return _workoutsRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => WorkoutModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get workouts for last 7 days
  Future<List<WorkoutModel>> getLast7DaysWorkouts() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final snap = await _workoutsRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .orderBy('date', descending: false)
        .get();
    return snap.docs
        .map((doc) => WorkoutModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Get today's workouts
  Future<List<WorkoutModel>> getTodayWorkouts() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await _workoutsRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return snap.docs
        .map((doc) => WorkoutModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Get total stats
  Future<Map<String, int>> getTotalStats() async {
    final snap = await _workoutsRef.get();
    int totalCalories = 0;
    int totalSteps = 0;
    int totalMinutes = 0;
    int totalWorkouts = snap.docs.length;

    for (var doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalCalories += (data['caloriesBurned'] as int? ?? 0);
      totalSteps += (data['steps'] as int? ?? 0);
      totalMinutes += (data['durationMinutes'] as int? ?? 0);
    }

    return {
      'calories': totalCalories,
      'steps': totalSteps,
      'minutes': totalMinutes,
      'workouts': totalWorkouts,
    };
  }
}
