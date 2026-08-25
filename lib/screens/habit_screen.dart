import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';

class HabitScreen extends StatefulWidget {
  final VoidCallback? onHabitUpdated;

  const HabitScreen({super.key, this.onHabitUpdated});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  List<HabitItem> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final loaded = await StorageService.loadHabits();
    if (!mounted) return;
    setState(() {
      _habits = loaded;
      _isLoading = false;
    });
  }

  Future<void> _saveHabits() async {
    await StorageService.saveHabits(_habits);
    if (widget.onHabitUpdated != null) {
      widget.onHabitUpdated!();
    }
  }

  String _todayStr() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  int _calculateStreak(List<String> dates) {
    if (dates.isEmpty) return 0;

    final sorted = dates.map((d) => DateFormat('yyyy-MM-dd').parse(d)).toList()..sort((a, b) => b.compareTo(a));
    final today = DateFormat('yyyy-MM-dd').parse(_todayStr());
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if streak is active (completed today or yesterday)
    bool isActive = sorted.any((d) => d == today || d == yesterday);
    if (!isActive) return 0;

    int streak = 0;
    DateTime checkDate = sorted.contains(today) ? today : yesterday;

    while (sorted.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  void _toggleHabitToday(HabitItem habit) {
    final today = _todayStr();
    final dates = List<String>.from(habit.completedDates);

    if (dates.contains(today)) {
      dates.remove(today);
    } else {
      dates.add(today);
    }

    final newStreak = _calculateStreak(dates);
    final longest = newStreak > habit.longestStreak ? newStreak : habit.longestStreak;

    setState(() {
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit.copyWith(
          completedDates: dates,
          streakCount: newStreak,
          longestStreak: longest,
        );
      }
    });
    _saveHabits();
  }

  void _showAddOrEditHabitModal({HabitItem? habitToEdit}) {
    final isEditing = habitToEdit != null;
    final titleController = TextEditingController(text: isEditing ? habitToEdit.title : '');
    String icon = isEditing ? habitToEdit.icon : '🔥';
    String category = isEditing ? habitToEdit.category : 'Study';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    isEditing ? 'Edit Daily Habit' : 'Create Custom Daily Habit',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF172033)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: const Color(0xFF172033)),
                    decoration: InputDecoration(
                      hintText: 'e.g. Read 15 pages of Tech / Self Dev',
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
                          value: icon,
                          dropdownColor: const Color(0xFFF8FAFC),
                          style: const TextStyle(color: const Color(0xFF172033), fontSize: 18),
                          decoration: const InputDecoration(labelText: 'Emoji Icon', labelStyle: TextStyle(color: Colors.grey)),
                          items: ['🔥', '📚', '🏋️', '💧', '🧩', '💻', '🧘', '🍳', '🥗', '☕', '🌙', '👟']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => icon = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          dropdownColor: const Color(0xFFF8FAFC),
                          style: const TextStyle(color: const Color(0xFF172033)),
                          decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Colors.grey)),
                          items: ['Study', 'Project', 'Coursework', 'Placement prep', 'Fitness', 'Hydration', 'Protein', 'Mindfulness', 'General']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => category = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        if (isEditing) {
                          final index = _habits.indexWhere((h) => h.id == habitToEdit.id);
                          if (index != -1) {
                            setState(() {
                              _habits[index] = habitToEdit.copyWith(
                                title: title,
                                icon: icon,
                                category: category,
                              );
                            });
                          }
                        } else {
                          final newHabit = HabitItem(
                            id: 'h_${DateTime.now().millisecondsSinceEpoch}',
                            title: title,
                            icon: icon,
                            category: category,
                          );
                          setState(() => _habits.add(newHabit));
                        }

                        _saveHabits();
                        Navigator.pop(context);
                      },
                      child: Text(
                        isEditing ? 'Save Changes' : 'Add Habit',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
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

  void _showHabitOptionsSheet(HabitItem habit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36, height: 4,
                decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
              ),
              ListTile(
                leading: Text(habit.icon, style: const TextStyle(fontSize: 24)),
                title: Text(habit.title, style: const TextStyle(color: const Color(0xFF172033), fontWeight: FontWeight.bold)),
                subtitle: Text('Category: ${habit.category} | Streak: ${habit.streakCount}d', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const Divider(color: Color(0xFFE2E8F0)),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Color(0xFF6EE7F0)),
                title: const Text('Edit Habit', style: TextStyle(color: const Color(0xFF172033))),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddOrEditHabitModal(habitToEdit: habit);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh_outlined, color: Color(0xFFFFB86B)),
                title: const Text('Reset Active Streak to 0', style: TextStyle(color: const Color(0xFF172033))),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    final index = _habits.indexWhere((h) => h.id == habit.id);
                    if (index != -1) {
                      _habits[index] = habit.copyWith(streakCount: 0);
                    }
                  });
                  _saveHabits();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reset streak for "${habit.title}"')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_outlined, color: Color(0xFFFF6B6B)),
                title: const Text('Delete Habit', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteHabit(habit);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteHabit(HabitItem habit) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Delete Habit?', style: TextStyle(color: const Color(0xFF172033))),
          content: Text('Are you sure you want to delete "${habit.title}"? Your streak history for this habit will be removed.', style: const TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
              onPressed: () {
                setState(() {
                  _habits.removeWhere((h) => h.id == habit.id);
                });
                _saveHabits();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "${habit.title}"')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: const Color(0xFF172033), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayStr();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Habits & Consistency Streaks', style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF172033))),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF4F46E5)),
            onPressed: () => _showAddOrEditHabitModal(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEDE9FE), Color(0xFFFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Everyday Consistency', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF172033), fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Tap to check-in • Hold to edit / delete', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 132),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥 ', style: TextStyle(fontSize: 18)),
                            Flexible(child: Text(
                              '${_habits.fold(0, (sum, h) => sum + h.streakCount)} Days Total',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 14),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daily Habits', style: TextStyle(color: const Color(0xFF172033), fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${_habits.length} habits', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),

                ..._habits.map((habit) {
                  final isDoneToday = habit.completedDates.contains(today);

                  return InkWell(
                    onTap: () => _toggleHabitToday(habit),
                    onLongPress: () => _showHabitOptionsSheet(habit),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDoneToday ? const Color(0xFF5FE0A0) : const Color(0xFFE2E8F0)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: Text(habit.icon, style: const TextStyle(fontSize: 28)),
                        title: Text(
                          habit.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDoneToday ? const Color(0xFF64748B) : const Color(0xFF172033),
                            fontWeight: FontWeight.bold,
                            decoration: isDoneToday ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Wrap(
                          spacing: 2,
                          runSpacing: 2,
                          children: [
                            Text('${habit.category} • ', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            Text('🔥 ${habit.streakCount} day streak', style: const TextStyle(color: Color(0xFFFFB86B), fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(' (best: ${habit.longestStreak}d)', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                        trailing: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDoneToday ? const Color(0xFF5FE0A0) : const Color(0xFFF8FAFC),
                            border: Border.all(color: isDoneToday ? const Color(0xFF5FE0A0) : Colors.grey),
                          ),
                          child: Icon(Icons.check, color: isDoneToday ? const Color(0xFF06282B) : Colors.grey, size: 20),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4F46E5),
        onPressed: () => _showAddOrEditHabitModal(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
