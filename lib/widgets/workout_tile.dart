import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/workout_model.dart';

class WorkoutTile extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const WorkoutTile({
    super.key,
    required this.workout,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final typeData = workoutTypes.firstWhere(
      (t) => t['name'] == workout.type,
      orElse: () => workoutTypes.last,
    );
    final color = Color(typeData['color'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                typeData['icon'] as String,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.type,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy · h:mm a').format(workout.date),
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.white38),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _chip('🔥 ${workout.caloriesBurned} cal', const Color(0xFFFF6B6B)),
                    const SizedBox(width: 8),
                    _chip('⏱ ${workout.durationMinutes} min', const Color(0xFF6C63FF)),
                    if (workout.steps > 0) ...[
                      const SizedBox(width: 8),
                      _chip('👟 ${workout.steps}', const Color(0xFF00C6AE)),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: Colors.white54, size: 16),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE63946).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Color(0xFFE63946), size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
