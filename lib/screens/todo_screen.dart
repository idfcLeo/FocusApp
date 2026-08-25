import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class TodoScreen extends StatefulWidget {
  final VoidCallback? onTaskUpdated;
  const TodoScreen({super.key, this.onTaskUpdated});
  @override State<TodoScreen> createState() => _TodoScreenState();
}
class _TodoScreenState extends State<TodoScreen> {
  static const purple = Color(0xFF4F46E5);
  List<TaskItem> tasks = [];
  String filter = 'All';
  bool loading = true;
  @override void initState() { super.initState(); StorageService.changes.addListener(_refreshFromStorage); load(); }
  void _refreshFromStorage() { if (mounted) load(); }
  @override void dispose() { StorageService.changes.removeListener(_refreshFromStorage); super.dispose(); }
  Future<void> load() async { final saved = await StorageService.loadTasks(); if (mounted) setState(() { tasks = saved; loading = false; }); }
  Future<void> save(List<TaskItem> next) async { await StorageService.saveTasks(next); setState(() => tasks = next); widget.onTaskUpdated?.call(); }
  Future<void> createTask(String title, String category, {String priority = 'Medium'}) async {
    final task = TaskItem(id: 't_${DateTime.now().microsecondsSinceEpoch}', title: title, category: category, priority: priority, dueTime: DateTime.now().add(const Duration(hours: 2)));
    await save([...tasks, task]);
    await NotificationService.showTaskNotification(id: task.id.hashCode, title: 'Task reminder: $title', body: 'Due ${DateFormat('h:mm a').format(task.dueTime!)}');
  }
  Future<void> toggle(TaskItem task) async { final i = tasks.indexWhere((item) => item.id == task.id); await save([...tasks]..[i] = task.copyWith(isCompleted: !task.isCompleted, completedAt: task.isCompleted ? null : DateTime.now())); }
  Future<void> deleteTask(TaskItem task) async { await save(tasks.where((item) => item.id != task.id).toList()); }
  void taskOptions(TaskItem task) => showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))), builder: (sheetContext) => SafeArea(child: Wrap(children: [
    ListTile(leading: const Icon(Icons.edit_outlined, color: purple), title: const Text('Edit task'), onTap: () { Navigator.pop(sheetContext); editTask(task); }),
    ListTile(leading: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)), title: const Text('Delete task', style: TextStyle(color: Color(0xFFDC2626))), onTap: () async { Navigator.pop(sheetContext); await deleteTask(task); }),
  ])));
  void editTask(TaskItem task) { final controller = TextEditingController(text: task.title); showDialog(context: context, builder: (dialogContext) => AlertDialog(title: const Text('Edit task'), content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Task title')), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton(onPressed: () async { final title = controller.text.trim(); if (title.isEmpty) return; final i = tasks.indexWhere((item) => item.id == task.id); await save([...tasks]..[i] = task.copyWith(title: title)); if (dialogContext.mounted) Navigator.pop(dialogContext); }, child: const Text('Save'))])); }
  void showAddSheet() {
    final controller = TextEditingController(); String category = 'Study'; String priority = 'Medium';
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))), builder: (sheetContext) => StatefulBuilder(builder: (sheetContext, setSheetState) => Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Add a task', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 14), TextField(controller: controller, autofocus: true, decoration: InputDecoration(hintText: 'What needs your attention?', filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))), const SizedBox(height: 12),
      Row(children: [Expanded(child: selector(category, ['Study', 'Project', 'Coursework', 'Placement prep'], (value) => setSheetState(() => category = value!))), const SizedBox(width: 10), Expanded(child: selector(priority, ['High', 'Medium', 'Low'], (value) => setSheetState(() => priority = value!)))]), const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: () async { if (controller.text.trim().isEmpty) return; await createTask(controller.text.trim(), category, priority: priority); if (sheetContext.mounted) Navigator.pop(sheetContext); }, style: FilledButton.styleFrom(backgroundColor: purple, padding: const EdgeInsets.all(16)), child: const Text('Save task')))
    ]))));
  }
  Widget selector(String value, List<String> choices, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(value: value, decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: choices.map((choice) => DropdownMenuItem<String>(value: choice, child: Text(choice))).toList(), onChanged: onChanged);
  @override Widget build(BuildContext context) {
    final shown = (filter == 'All' ? tasks : tasks.where((task) => task.category == filter)).toList();
    shown.sort((a, b) => (a.dueTime ?? DateTime(2100)).compareTo(b.dueTime ?? DateTime(2100)));
    return Scaffold(backgroundColor: const Color(0xFFF7F8FC), appBar: AppBar(title: const Text('Tasks', style: TextStyle(fontWeight: FontWeight.w800)), actions: [IconButton(onPressed: showAddSheet, icon: const Icon(Icons.add_circle_outline, color: purple))]), floatingActionButton: FloatingActionButton(onPressed: showAddSheet, backgroundColor: purple, child: const Icon(Icons.add, color: Colors.white)), body: loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 100), children: [
      const Text('Quick add', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF172033))), const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: [ActionChip(avatar: const Icon(Icons.add, size: 16), label: const Text('Add quick task'), onPressed: showAddSheet), quick('Project commit', 'Project')]), const SizedBox(height: 22),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['All', 'Study', 'Project', 'Coursework', 'Placement prep'].map((item) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(item), selected: filter == item, selectedColor: const Color(0xFFE0E7FF), onSelected: (_) => setState(() => filter = item)))).toList())), const SizedBox(height: 18),
      Text(filter == 'All' ? 'Everything' : '$filter tasks', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF172033))), const SizedBox(height: 8), if (shown.isEmpty) const Padding(padding: EdgeInsets.only(top: 30), child: Center(child: Text('Clear slate. Add what matters.', style: TextStyle(color: Color(0xFF64748B))))), ...shown.map(taskCard)
    ]));
  }
  Widget quick(String title, String category) => ActionChip(label: Text(title, overflow: TextOverflow.ellipsis), avatar: const Icon(Icons.add, size: 16), onPressed: () => createTask(title, category));
  Widget taskCard(TaskItem task) => InkWell(onLongPress: () => taskOptions(task), borderRadius: BorderRadius.circular(16), child: Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [InkWell(onTap: () => toggle(task), child: Container(width: 25, height: 25, decoration: BoxDecoration(color: task.isCompleted ? const Color(0xFF10B981) : Colors.transparent, border: Border.all(color: task.isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8), width: 2), borderRadius: BorderRadius.circular(8)), child: task.isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, color: task.isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF172033), decoration: task.isCompleted ? TextDecoration.lineThrough : null)), const SizedBox(height: 5), Text('${task.category} • ${task.dueTime == null ? 'No deadline' : DateFormat('EEE, h:mm a').format(task.dueTime!)}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))]))])));
}
