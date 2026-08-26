import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../models/food_item.dart';
import '../models/exercise.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class CalendarScreen extends StatefulWidget {
  final VoidCallback? onDataUpdated;

  const CalendarScreen({super.key, this.onDataUpdated});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  List<TaskItem> _tasks = [];
  List<HabitItem> _habits = [];
  List<FoodLogItem> _foods = [];
  List<ExerciseLogItem> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    StorageService.changes.addListener(_refreshFromStorage);
    _loadAllData();
  }

  @override
  void dispose() {
    StorageService.changes.removeListener(_refreshFromStorage);
    super.dispose();
  }

  void _refreshFromStorage() { if (mounted) _loadAllData(); }

  Future<void> _loadAllData() async {
    final tasks = await StorageService.loadTasks();
    final habits = await StorageService.loadHabits();
    final foods = await StorageService.loadFoodLogs();
    final exercises = await StorageService.loadExerciseLogs();

    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _habits = habits;
      _foods = foods;
      _exercises = exercises;
      _isLoading = false;
    });
  }

  String _dateStr(DateTime dt) {
    final local = dt.toLocal();
    return DateFormat('yyyy-MM-dd').format(local);
  }

  /// Supplies calendar markers for every saved activity, not just scheduled tasks.
  List<Object> _eventsForDay(DateTime day) {
    final date = _dateStr(day);
    return [
      ..._tasks.where((task) =>
          (task.dueTime != null && _dateStr(task.dueTime!) == date) ||
          (task.completedAt != null && _dateStr(task.completedAt!) == date)),
      ..._habits.where((habit) => habit.completedDates.contains(date)),
      ..._foods.where((food) => _dateStr(food.timestamp) == date),
      ..._exercises.where((exercise) => _dateStr(exercise.timestamp) == date),
    ];
  }

  void _toggleTask(TaskItem task) async {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        final current = _tasks[index];
        _tasks[index] = current.copyWith(
          isCompleted: !current.isCompleted,
          completedAt: !current.isCompleted ? DateTime.now() : null,
        );
      }
    });
    await StorageService.saveTasks(_tasks);
    if (widget.onDataUpdated != null) {
      widget.onDataUpdated!();
    }
  }

  void _showScheduleFutureEventModal(DateTime targetDate) {
    final titleController = TextEditingController();
    String category = 'Exam';
    String priority = 'High';
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final dateFmtStr = DateFormat('EEE, MMM d, yyyy').format(targetDate);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20, left: 20, right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule Task / Event for $dateFmtStr',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Color(0xFF172033)),
                    decoration: InputDecoration(
                      hintText: 'e.g. End Sem Exam / Capstone Presentation',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          dropdownColor: const Color(0xFFF8FAFC),
                          style: const TextStyle(color: Color(0xFF172033)),
                          decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Colors.grey)),
                          items: ['Exam', 'Project', 'Assignment', 'Study', 'Personal']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => category = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: priority,
                          dropdownColor: const Color(0xFFF8FAFC),
                          style: const TextStyle(color: Color(0xFF172033)),
                          decoration: const InputDecoration(labelText: 'Priority', labelStyle: TextStyle(color: Colors.grey)),
                          items: ['High', 'Medium', 'Low']
                              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => priority = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Due Time: ${selectedTime.format(context)}', style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () async {
                          final t = await showTimePicker(context: context, initialTime: selectedTime);
                          if (t != null) setModalState(() => selectedTime = t);
                        },
                        icon: const Icon(Icons.access_time, color: Color(0xFF4F46E5)),
                        label: const Text('Change Time', style: TextStyle(color: Color(0xFF4F46E5))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        final due = DateTime(
                          targetDate.year, targetDate.month, targetDate.day,
                          selectedTime.hour, selectedTime.minute,
                        );

                        final timeFormatted = selectedTime.format(context);

                        final newTask = TaskItem(
                          id: 't_${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          category: category,
                          priority: priority,
                          dueTime: due,
                        );

                        setState(() {
                          _tasks.add(newTask);
                        });
                        await StorageService.saveTasks(_tasks);

                        NotificationService.showTaskNotification(
                          id: newTask.id.hashCode,
                          title: 'Upcoming Event/Task: ${newTask.title}',
                          body: 'Date: $dateFmtStr at $timeFormatted',
                        );

                        if (widget.onDataUpdated != null) {
                          widget.onDataUpdated!();
                        }

                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Scheduled "$title" for $dateFmtStr')),
                        );
                      },
                      child: const Text('Save Event & Schedule Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeDate = _selectedDay ?? DateTime.now();
    final activeDateStr = _dateStr(activeDate);
    final todayStr = _dateStr(DateTime.now());

    final isFuture = activeDateStr.compareTo(todayStr) > 0;

    // Filter tasks for active date (match by due date OR completion date)
    final dateTasks = _tasks.where((t) {
      if (t.dueTime != null && _dateStr(t.dueTime!) == activeDateStr) {
        return true;
      }
      if (t.completedAt != null && _dateStr(t.completedAt!) == activeDateStr) {
        return true;
      }
      return false;
    }).toList();

    final completedTasksCount = dateTasks.where((t) => t.isCompleted).length;

    // Filter habits for active date
    final dateHabits = _habits.where((h) => h.completedDates.contains(activeDateStr)).toList();

    // Filter foods for active date
    final dateFoods = _foods.where((f) => _dateStr(f.timestamp) == activeDateStr).toList();
    final totalCaloriesFood = dateFoods.fold(0, (sum, f) => sum + f.calories);
    final totalProteinFood = dateFoods.fold(0.0, (sum, f) => sum + f.proteinGrams);

    // Filter exercises for active date
    final dateEx = _exercises.where((e) => _dateStr(e.timestamp) == activeDateStr).toList();
    final totalCaloriesBurned = dateEx.fold(0, (sum, e) => sum + e.caloriesBurned);
    final totalSteps = dateEx.fold(0, (sum, e) => sum + e.steps);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Calendar & History Hub', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF172033))),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4F46E5)),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Table Calendar Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2025, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _eventsForDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    calendarStyle: const CalendarStyle(
                      defaultTextStyle: TextStyle(color: Color(0xFF172033)),
                      weekendTextStyle: TextStyle(color: Color(0xFFFFB86B)),
                      outsideTextStyle: TextStyle(color: Colors.grey),
                      selectedDecoration: BoxDecoration(color: Color(0xFF4F46E5), shape: BoxShape.circle),
                      selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      todayDecoration: BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
                      todayTextStyle: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: true,
                      titleTextStyle: const TextStyle(color: Color(0xFF172033), fontSize: 16, fontWeight: FontWeight.bold),
                      formatButtonTextStyle: const TextStyle(color: Color(0xFF4F46E5), fontSize: 12),
                      formatButtonDecoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.4)),
                      ),
                      leftChevronIcon: const Icon(Icons.chevron_left, color: Color(0xFF172033)),
                      rightChevronIcon: const Icon(Icons.chevron_right, color: Color(0xFF172033)),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Selected Date Header & Schedule Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM d, yyyy').format(activeDate),
                      style: const TextStyle(color: Color(0xFF172033), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showScheduleFutureEventModal(activeDate),
                      icon: const Icon(Icons.event, size: 18),
                      label: const Text('Schedule Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // DAILY HISTORY REPORT CARD FOR SELECTED DATE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Daily History Report', style: TextStyle(color: Color(0xFF5FE0A0), fontWeight: FontWeight.bold, fontSize: 15)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFE9FBF2), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              isFuture ? 'FUTURE SCHEDULE' : 'DAILY REPORT',
                              style: const TextStyle(color: Color(0xFF5FE0A0), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Metrics Summary 2x2 Grid
                      Row(
                        children: [
                          Expanded(child: _reportStat('Tasks Done', '$completedTasksCount / ${dateTasks.length}', const Color(0xFF4F46E5))),
                          const SizedBox(width: 10),
                          Expanded(child: _reportStat('Habits Hit', '${dateHabits.length} checked', const Color(0xFF4F46E5))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _reportStat('Food Intake', '$totalCaloriesFood kcal (${totalProteinFood.toStringAsFixed(1)}g P)', const Color(0xFFFFD166))),
                          const SizedBox(width: 10),
                          Expanded(child: _reportStat('Workouts / Steps', '$totalCaloriesBurned kcal ($totalSteps steps)', const Color(0xFFFF8A65))),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 8),

                      // Tasks & Events list for this date
                      const Text('Tasks & Deadlines Scheduled for Date:', style: TextStyle(color: Color(0xFF172033), fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      if (dateTasks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text('No tasks or events scheduled on this date.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        )
                      else
                        ...dateTasks.map((t) => Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => _toggleTask(t),
                                    child: Icon(
                                      t.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: t.isCompleted ? const Color(0xFF5FE0A0) : Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      t.title,
                                      style: TextStyle(
                                        color: t.isCompleted ? Colors.grey : const Color(0xFF172033),
                                        decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  if (t.dueTime != null)
                                    Text(
                                      DateFormat('hh:mm a').format(t.dueTime!),
                                      style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 11),
                                    ),
                                ],
                              ),
                            )),

                      const SizedBox(height: 12),
                      // Food Logged Breakdown for this date
                      const Text('Food Logged on Selected Date:', style: TextStyle(color: Color(0xFF172033), fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      if (dateFoods.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text('No food logged on this date.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        )
                      else
                        ...dateFoods.map((f) => Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF172033), fontWeight: FontWeight.bold, fontSize: 13))),
                                  const SizedBox(width: 8),
                                  Text('${f.calories} kcal • ${f.proteinGrams}g P', style: const TextStyle(color: Color(0xFFFFD166), fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _reportStat(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(color: Color(0xFF172033), fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
