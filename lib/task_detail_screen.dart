import 'package:flutter/material.dart';

import 'app_data.dart';
import 'constants/spacing.dart';
import 'task.dart';
import 'theme.dart';
import 'widgets/back_button.dart';
import 'widgets/checklist_item.dart';
import 'widgets/dropdown_field.dart';
import 'widgets/primary_button.dart';

/// Add a task when [initialTask] is null, edit it in place otherwise.
/// Saves straight into [appData] and pops — Home re-reads appData.tasks
/// when this screen returns, so no result needs to be threaded back.
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.appData,
    this.initialTask,
  });

  final AppData appData;
  final Task? initialTask;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _newSubtaskController;
  DateTime? _date;
  TimeOfDay? _time;
  late List<Subtask> _subtasks;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _newSubtaskController = TextEditingController();
    _date = task?.date;
    _time = task?.time;
    // Copy, not alias — Cancel (back button) should not mutate the
    // original task's subtask list.
    _subtasks = task?.subtasks
            .map((s) => Subtask(title: s.title, isDone: s.isDone))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _newSubtaskController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _addSubtask() {
    final text = _newSubtaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks.add(Subtask(title: text));
      _newSubtaskController.clear();
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return; // Task Title is required — nothing to save.
    final task = Task(
      title: title,
      date: _date,
      time: _time,
      subtasks: _subtasks,
    );
    widget.appData.addOrUpdateTask(task, replacing: widget.initialTask);
    Navigator.of(context).pop();
  }

  String _formatDate(DateTime d) => '${d.month}/${d.day}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: kSpacingStandard),
              Row(
                children: [
                  AppBackButton(onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: kSpacingStandard),
                  Text('Add/Edit', style: textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: kSpacingStandard),
              Expanded(
                child: ListView(
                  children: [
                    Text('Task Title', style: textTheme.labelSmall),
                    const SizedBox(height: kSpacingTight / 2),
                    TextField(
                      controller: _titleController,
                      style: textTheme.bodyMedium,
                      cursorColor: kPrimary,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: kSurface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: kSpacingStandard,
                          vertical: kSpacingTight + 4,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: kSpacingStandard),
                    DropdownField(
                      label: 'Select Date',
                      leadingIcon: Icons.calendar_today,
                      value: _date == null ? 'Choose a date' : _formatDate(_date!),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: kSpacingStandard),
                    DropdownField(
                      label: 'Time',
                      leadingIcon: Icons.access_time,
                      value: _time == null ? 'Choose a time' : _time!.format(context),
                      onTap: _pickTime,
                    ),
                    const SizedBox(height: kSpacingStandard),
                    Text('Subtasks', style: textTheme.headlineSmall),
                    const SizedBox(height: kSpacingTight),
                    for (final subtask in _subtasks)
                      ChecklistItem(
                        label: subtask.title,
                        value: subtask.isDone,
                        onChanged: (v) => setState(() => subtask.isDone = v),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newSubtaskController,
                            style: textTheme.bodyMedium,
                            cursorColor: kPrimary,
                            decoration: InputDecoration(
                              hintText: 'Add a subtask',
                              hintStyle: textTheme.labelSmall,
                              isDense: true,
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: kMuted),
                              ),
                            ),
                            onSubmitted: (_) => _addSubtask(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: kPrimary),
                          onPressed: _addSubtask,
                          tooltip: 'Add subtask',
                        ),
                      ],
                    ),
                    const SizedBox(height: kSpacingStandard),
                  ],
                ),
              ),
              PrimaryButton(label: 'Save', onPressed: _save),
              const SizedBox(height: kSpacingStandard),
            ],
          ),
        ),
      ),
    );
  }
}
