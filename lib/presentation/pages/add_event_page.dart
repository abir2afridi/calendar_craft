import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../domain/models/event.dart';
import '../providers/event_provider.dart';

class AddEventPage extends ConsumerStatefulWidget {
  final Event? event;
  final DateTime? initialDate;

  const AddEventPage({super.key, this.event, this.initialDate});

  @override
  ConsumerState<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends ConsumerState<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isAllDay = false;
  EventCategory _category = EventCategory.personal;
  EventPriority _priority = EventPriority.medium;
  RepeatType _repeatType = RepeatType.none;
  Color _selectedColor = Colors.blue;
  List<DateTime> _reminderTimes = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    if (widget.event != null) {
      _populateFields(widget.event!);
    } else {
      _reminderTimes = [_selectedDate];
    }
  }

  void _populateFields(Event event) {
    _titleController.text = event.title;
    _descriptionController.text = event.description ?? '';
    _locationController.text = event.location ?? '';
    _selectedDate = event.date;
    _startTime = event.startTime != null
        ? TimeOfDay.fromDateTime(event.startTime!)
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = event.endTime != null
        ? TimeOfDay.fromDateTime(event.endTime!)
        : const TimeOfDay(hour: 10, minute: 0);
    _isAllDay = event.isAllDay;
    _category = event.category;
    _priority = event.priority;
    _repeatType = event.repeatType;
    _selectedColor = event.uiColor;
    _reminderTimes = List.from(event.reminderTimes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final event = Event(
      id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
      repeatType: _repeatType,
      color: '#${_selectedColor.value.toRadixString(16).padLeft(8, '0')}',
      reminderTimes: _reminderTimes,
      createdAt: widget.event?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.event == null) {
        await ref.read(eventProvider.notifier).addEvent(event);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event added successfully')),
          );
        }
      } else {
        await ref.read(eventProvider.notifier).updateEvent(event);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event updated successfully')),
          );
        }
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _addReminder() {
    final reminderTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour - 1,
      _startTime.minute,
    );
    setState(() {
      _reminderTimes.add(reminderTime);
    });
  }

  void _removeReminder(int index) {
    setState(() {
      _reminderTimes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: widget.event != null
                ? () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Event'),
                        content: const Text(
                          'Are you sure you want to delete this event?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref
                          .read(eventProvider.notifier)
                          .deleteEvent(widget.event!.id);
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Event deleted')),
                        );
                      }
                    }
                  }
                : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              // Date and Time
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date & Time',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 5),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('All Day'),
                        value: _isAllDay,
                        onChanged: (value) {
                          setState(() {
                            _isAllDay = value ?? false;
                          });
                        },
                      ),
                      if (!_isAllDay) ...[
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(
                            'Start Time: ${_startTime.format(context)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _startTime,
                            );
                            if (time != null) {
                              setState(() {
                                _startTime = time;
                              });
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text('End Time: ${_endTime.format(context)}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _endTime,
                            );
                            if (time != null) {
                              setState(() {
                                _endTime = time;
                              });
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category and Priority
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<EventCategory>(
                              value: _category,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: EventCategory.values.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _category = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<EventPriority>(
                              value: _priority,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: EventPriority.values.map((priority) {
                                return DropdownMenuItem(
                                  value: priority,
                                  child: Text(priority.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _priority = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Color Picker
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Color',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Pick a color'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: _selectedColor,
                                  onColorChanged: (color) {
                                    setState(() {
                                      _selectedColor = color;
                                    });
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Done'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Center(
                            child: Text(
                              'Tap to change color',
                              style: TextStyle(
                                color: _selectedColor.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Repeat Type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repeat',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<RepeatType>(
                        value: _repeatType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: RepeatType.values.map((repeatType) {
                          return DropdownMenuItem(
                            value: repeatType,
                            child: Text(repeatType.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _repeatType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reminders
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reminders',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addReminder,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_reminderTimes.isEmpty)
                        const Text('No reminders set')
                      else
                        ..._reminderTimes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final reminder = entry.value;
                          return ListTile(
                            leading: const Icon(Icons.notifications),
                            title: Text(
                              '${reminder.hour}:${reminder.minute.toString().padLeft(2, '0')} before event',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () => _removeReminder(index),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    widget.event == null ? 'Add Event' : 'Update Event',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
