import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/workout_model.dart';
import '../../services/firestore_service.dart';

class AddWorkoutScreen extends StatefulWidget {
  final WorkoutModel? existingWorkout;

  const AddWorkoutScreen({super.key, this.existingWorkout});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _firestoreService = FirestoreService();
  final _caloriesController = TextEditingController();
  final _stepsController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'Running';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  bool get _isEditing => widget.existingWorkout != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final w = widget.existingWorkout!;
      _selectedType = w.type;
      _selectedDate = w.date;
      _caloriesController.text = w.caloriesBurned.toString();
      _stepsController.text = w.steps.toString();
      _durationController.text = w.durationMinutes.toString();
      _notesController.text = w.notes;
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00C6AE),
            surface: Color(0xFF1A1A2E),
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _save() async {
    if (_durationController.text.isEmpty || _caloriesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill duration and calories',
              style: GoogleFonts.inter()),
          backgroundColor: const Color(0xFFE63946),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final workout = WorkoutModel(
      id: _isEditing ? widget.existingWorkout!.id : '',
      userId: '',
      type: _selectedType,
      durationMinutes: int.tryParse(_durationController.text) ?? 0,
      caloriesBurned: int.tryParse(_caloriesController.text) ?? 0,
      steps: int.tryParse(_stepsController.text) ?? 0,
      notes: _notesController.text,
      date: _selectedDate,
    );

    try {
      if (_isEditing) {
        await _firestoreService.updateWorkout(workout);
      } else {
        await _firestoreService.addWorkout(workout);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save workout', style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFFE63946),
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _stepsController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white70, size: 16),
          ),
        ),
        title: Text(
          _isEditing ? 'Edit Workout' : 'Log Workout',
          style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Type
            Text('Workout Type',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: workoutTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final type = workoutTypes[index];
                  final isSelected = _selectedType == type['name'];
                  final color = Color(type['color'] as int);
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedType = type['name'] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 78,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.2)
                            : const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? color : Colors.white10,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(type['icon'] as String,
                              style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 6),
                          Text(
                            type['name'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isSelected ? color : Colors.white54,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Date Picker
            Text('Date',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Color(0xFF00C6AE), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                      style: GoogleFonts.inter(
                          fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Stats Input
            Text('Workout Stats',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildNumberField(
                        _durationController, 'Duration (min)', '⏱')),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildNumberField(
                        _caloriesController, 'Calories', '🔥')),
              ],
            ),
            const SizedBox(height: 12),
            _buildNumberField(_stepsController, 'Steps (optional)', '👟'),
            const SizedBox(height: 28),

            // Notes
            Text('Notes (optional)',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'How did the workout feel?',
                  hintStyle: GoogleFonts.inter(color: Colors.white30),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Save Button
            GestureDetector(
              onTap: _isLoading ? null : _save,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C6AE), Color(0xFF6C63FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C6AE).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          _isEditing ? 'Update Workout' : 'Save Workout',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(
      TextEditingController controller, String hint, String emoji) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
          prefixText: '$emoji  ',
          prefixStyle: const TextStyle(fontSize: 16),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}
