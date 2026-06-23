import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutModel {
  final String id;
  final String userId;
  final String type; // e.g. Running, Cycling, Gym, etc.
  final int durationMinutes;
  final int caloriesBurned;
  final int steps;
  final String notes;
  final DateTime date;

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.steps,
    required this.notes,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'steps': steps,
      'notes': notes,
      'date': Timestamp.fromDate(date),
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      caloriesBurned: map['caloriesBurned'] ?? 0,
      steps: map['steps'] ?? 0,
      notes: map['notes'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}

const List<Map<String, dynamic>> workoutTypes = [
  {'name': 'Running', 'icon': '🏃', 'color': 0xFF00C6AE},
  {'name': 'Cycling', 'icon': '🚴', 'color': 0xFF6C63FF},
  {'name': 'Gym', 'icon': '🏋️', 'color': 0xFFFF6B6B},
  {'name': 'Swimming', 'icon': '🏊', 'color': 0xFF4ECDC4},
  {'name': 'Yoga', 'icon': '🧘', 'color': 0xFFFFBE0B},
  {'name': 'Walking', 'icon': '🚶', 'color': 0xFFFF9F1C},
  {'name': 'HIIT', 'icon': '⚡', 'color': 0xFFE63946},
  {'name': 'Other', 'icon': '💪', 'color': 0xFF8338EC},
];
