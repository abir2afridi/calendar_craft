import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/event.dart';
import '../providers/event_provider.dart';
import '../providers/notification_provider.dart';

class AddEventPage extends ConsumerStatefulWidget {
  final Event? event;
  final DateTime? initialDate;

  const AddEventPage({super.key, this.event, this.initialDate});

  @override
  ConsumerState<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends ConsumerState<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isAllDay;
  late EventCategory _category;
  late EventPriority _priority;
  late int? _reminderMinutes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.event?.description ?? '',
    );
    _locationController = TextEditingController(
      text: widget.event?.location ?? '',
    );

    _selectedDate = widget.event?.date ?? widget.initialDate ?? DateTime.now();
    _startTime = widget.event?.startTime != null
        ? TimeOfDay.fromDateTime(widget.event!.startTime!)
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.event?.endTime != null
        ? TimeOfDay.fromDateTime(widget.event!.endTime!)
        : const TimeOfDay(hour: 10, minute: 0);
    _isAllDay = widget.event?.isAllDay ?? false;
    _category = widget.event?.category ?? EventCategory.personal;
    _priority = widget.event?.priority ?? EventPriority.medium;

    // Initialize reminder from existing event or default settings
    if (widget.event != null && widget.event!.reminderTimes.isNotEmpty) {
      final diff = widget.event!.startTime != null
          ? widget.event!.startTime!
                .difference(widget.event!.reminderTimes.first)
                .inMinutes
          : widget.event!.date
                .difference(widget.event!.reminderTimes.first)
                .inMinutes;
      _reminderMinutes = diff;
    } else if (widget.event == null) {
      // For new events, we'll fetch from ref in build or just use a default here
      // but since we are in initState, we can't use ref easily.
      // We'll set it to null and fetch in build if it remains null.
      _reminderMinutes = null;
    } else {
      _reminderMinutes = null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final event = Event(
      id: widget.event?.id ?? now.millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      date: _selectedDate,
      startTime: _isAllDay
          ? null
          : DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _startTime.hour,
              _startTime.minute,
            ),
      endTime: _isAllDay
          ? null
          : DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _endTime.hour,
              _endTime.minute,
            ),
      isAllDay: _isAllDay,
      category: _category,
      priority: _priority,
      reminderTimes: _calculateReminderTimes(),
      color: widget.event?.color ?? _category.color,
      createdAt: widget.event?.createdAt ?? now,
      updatedAt: now,
      isSyncPending: true,
      isCompleted: false,
    );

    if (widget.event == null) {
      await ref.read(eventProvider.notifier).addEvent(event);
    } else {
      await ref.read(eventProvider.notifier).updateEvent(event);
    }

    if (mounted) Navigator.pop(context);
  }

  List<DateTime> _calculateReminderTimes() {
    if (_reminderMinutes == null) return [];

    final eventStart = _isAllDay
        ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
        : DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _startTime.hour,
            _startTime.minute,
          );

    return [eventStart.subtract(Duration(minutes: _reminderMinutes!))];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('01 . CORE IDENTITY'),
                      const SizedBox(height: 16),
                      _buildTitleField(context),
                      const SizedBox(height: 24),
                      _buildPremiumField(
                        context,
                        controller: _locationController,
                        hint: 'Where will this happen?',
                        icon: Icons.location_on_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildPremiumField(
                        context,
                        controller: _descriptionController,
                        hint: 'Additional notes...',
                        icon: Icons.notes_rounded,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 48),
                      _buildSectionLabel('02 . TEMPORAL CONTEXT'),
                      const SizedBox(height: 20),
                      _buildDateTimePicker(context),
                      const SizedBox(height: 16),
                      _buildAllDayToggle(context),
                      const SizedBox(height: 48),
                      _buildSectionLabel('03 . CATEGORIZATION'),
                      const SizedBox(height: 20),
                      _buildCategoryGrid(context),
                      const SizedBox(height: 48),
                      _buildSectionLabel('04 . STRATEGIC IMPORTANCE'),
                      const SizedBox(height: 20),
                      _buildPriorityPicker(context),
                      const SizedBox(height: 48),
                      _buildSectionLabel('05 . REMAINDER & ALERTS'),
                      const SizedBox(height: 20),
                      _buildReminderSelector(context, ref),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildSaveButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 140,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 64, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calendar Craft',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.grey,
              ),
            ),
            Text(
              widget.event == null ? 'Craft New Event' : 'Edit Manifest',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return TextFormField(
      controller: _titleController,
      validator: (v) => v?.isEmpty ?? true ? 'A title is required' : null,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
        height: 1.2,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'What is the goal?',
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildPremiumField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          icon: Icon(
            icon,
            size: 20,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          hintText: hint,
          border: InputBorder.none,
          hintStyle: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Column(
      children: [
        _buildPickerAction(
          context,
          icon: Icons.event_rounded,
          label: 'SCHEDULED DATE',
          value: DateFormat('MMMM d, yyyy').format(_selectedDate),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) setState(() => _selectedDate = date);
          },
        ),
        if (!_isAllDay) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPickerAction(
                  context,
                  icon: Icons.schedule_rounded,
                  label: 'START',
                  value: _startTime.format(context),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                    );
                    if (time != null) setState(() => _startTime = time);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPickerAction(
                  context,
                  icon: Icons.timer_off_rounded,
                  label: 'END',
                  value: _endTime.format(context),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _endTime,
                    );
                    if (time != null) setState(() => _endTime = time);
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPickerAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDayToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.all_inclusive_rounded,
                size: 24,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 16),
              Text(
                'Full Day Commitment',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: _isAllDay,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            onChanged: (v) => setState(() => _isAllDay = v),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: EventCategory.values.length,
      itemBuilder: (context, index) {
        final cat = EventCategory.values[index];
        final isSelected = _category == cat;
        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  _getCategoryIcon(cat),
                  color: isSelected
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  cat.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityPicker(BuildContext context) {
    return Row(
      children: EventPriority.values.map((p) {
        final isSelected = _priority == p;
        final color = p == EventPriority.high
            ? Colors.redAccent
            : (p == EventPriority.medium
                  ? Colors.orangeAccent
                  : Colors.blueAccent);
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(
                right: p == EventPriority.values.last ? 0 : 12,
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Center(
                child: Text(
                  p.displayName.toUpperCase(),
                  style: TextStyle(
                    color: isSelected
                        ? color
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          foregroundColor: Theme.of(context).colorScheme.surface,
          minimumSize: const Size(double.infinity, 72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 12,
          shadowColor: Colors.black.withValues(alpha: 0.4),
        ),
        child: const Text(
          'CONFIRM CREATION',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.personal:
        return Icons.person_rounded;
      case EventCategory.work:
        return Icons.work_rounded;
      case EventCategory.health:
        return Icons.favorite_rounded;
      case EventCategory.education:
        return Icons.school_rounded;
      case EventCategory.entertainment:
        return Icons.movie_rounded;
      case EventCategory.social:
        return Icons.group_rounded;
      case EventCategory.travel:
        return Icons.flight_rounded;
      case EventCategory.birthday:
        return Icons.cake_rounded;
      case EventCategory.other:
        return Icons.category_rounded;
    }
  }

  Widget _buildReminderSelector(BuildContext context, WidgetRef ref) {
    final notificationSettings = ref.watch(notificationProvider);

    // Set default if not already set
    if (_reminderMinutes == null && widget.event == null) {
      _reminderMinutes = notificationSettings.enabled
          ? notificationSettings.defaultReminderMinutes
          : null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          _reminderMinutes == null
              ? 'No Reminder'
              : '${_reminderMinutes}m before',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        leading: Icon(
          _reminderMinutes == null
              ? Icons.notifications_off_rounded
              : Icons.notifications_active_rounded,
          color: _reminderMinutes == null
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
        ),
        subtitle: const Text(
          'Tap to adjust timing',
          style: TextStyle(fontSize: 12),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 16),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        children: [
          const Divider(),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildReminderChip(null, 'None'),
              _buildReminderChip(5, '5m'),
              _buildReminderChip(10, '10m'),
              _buildReminderChip(15, '15m'),
              _buildReminderChip(30, '30m'),
              _buildReminderChip(60, '1h'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderChip(int? minutes, String label) {
    final isSelected = _reminderMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _reminderMinutes = minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
