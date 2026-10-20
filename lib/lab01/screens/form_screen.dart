import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../models/category.dart';
import '../utils/format.dart';
import '../utils/keyboard.dart';

/// One screen for "new" (event == null) and "edit".
class FormScreen extends StatefulWidget {
  const FormScreen({super.key, this.event});

  final CampusEvent? event;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // R35: controllers and focus nodes are fields, created once, disposed.
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _place = TextEditingController();
  final _capacity = TextEditingController();
  final _description = TextEditingController();
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _capacityFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  late final bool _isNew;
  late final CampusEvent _base; // the event being edited, or the defaults
  late final EventCategory? _initialCategory;
  late final DateTime? _initialDate;
  late final TimeOfDay? _initialTime;

  EventCategory? _category;
  DateTime? _date; // date only
  TimeOfDay? _time;
  late bool _online;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _isNew = e == null;
    _base = e ?? CampusEvent.empty(); // R3
    _title.text = _base.title;
    _place.text = _base.location;
    _capacity.text = '${_base.capacity}';
    _description.text = _base.description ?? '';
    _online = _base.online;
    if (e == null) {
      _initialCategory = null;
      _initialDate = null;
      _initialTime = null;
    } else {
      _initialCategory = e.category;
      _initialDate = DateTime(e.starts.year, e.starts.month, e.starts.day);
      _initialTime = TimeOfDay.fromDateTime(e.starts);
      _dateText.text = formatDay(_initialDate ?? e.starts);
      _timeText.text = formatTime(e.starts);
    }
    _category = _initialCategory;
    _date = _initialDate;
    _time = _initialTime;
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _place,
      _capacity,
      _description,
      _dateText,
      _timeText,
    ]) {
      c.dispose();
    }
    for (final f in [
      _titleFocus,
      _placeFocus,
      _capacityFocus,
      _descriptionFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  /// R30: current values against the values the form opened with.
  bool _differs() =>
      _title.text != _base.title ||
      _place.text != _base.location ||
      _capacity.text != '${_base.capacity}' ||
      _description.text != (_base.description ?? '') ||
      _online != _base.online ||
      _category != _initialCategory ||
      _date != _initialDate ||
      _time != _initialTime;

  void _checkDirty() => setState(() => _dirty = _differs());

  // ---- validators (R33, R34) ----

  String? _validateTitle(String? v) {
    final s = (v ?? '').trim();
    return s.length < 3 || s.length > 60 ? 'Title: 3 to 60 characters' : null;
  }

  String? _validatePlace(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Required';
    if (_online && !s.contains('://')) return 'A link must contain ://';
    return null;
  }

  String? _validateCapacity(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 1 || n > 500) return 'A whole number from 1 to 500';
    if (!_isNew && n < _base.count) {
      return 'Not below ${_base.count} already registered';
    }
    return null;
  }

  String? _futureError() {
    final date = _date;
    final time = _time;
    if (!_isNew || date == null || time == null) return null;
    final when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return when.isAfter(DateTime.now()) ? null : 'Must be in the future';
  }

  String? _validateDate(String? value) =>
      _date == null ? 'Pick a date' : _futureError();

  String? _validateTime(String? value) =>
      _time == null ? 'Pick a time' : _futureError();

  // ---- pickers (R36): Cancel returns null and changes nothing ----

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _date = picked);
    _dateText.text = formatDay(picked); // notifies the Form -> _checkDirty
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _time = picked);
    _timeText.text = '${two(picked.hour)}:${two(picked.minute)}';
  }

  // ---- save (R17) ----

  Future<void> _save() async {
    if (_saving) return; // a double tap never saves twice
    // The Form is in the tree: _save is only called from inside it.
    if (!_formKey.currentState!.validate()) return;

    final date = _date;
    final time = _time;
    final category = _category;
    if (date == null || time == null || category == null) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final description = _description.text.trim();
    Navigator.of(context).pop(
      CampusEvent(
        id: _base.id,
        title: _title.text.trim(),
        category: category,
        starts: DateTime(date.year, date.month, date.day, time.hour, time.minute),
        location: _place.text.trim(),
        // validated above, so this parse cannot fail
        capacity: int.parse(_capacity.text.trim()),
        online: _online,
        attendees: List<String>.of(_base.attendees),
        description: description.isEmpty ? null : description,
        favourite: _base.favourite,
      ),
    );
  }

  Future<bool> _confirmDiscard() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // R30: a clean form pops freely; a dirty one asks. Save pops directly
    // with Navigator.pop, which never goes through PopScope.
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final discard = await _confirmDiscard();
        if (!mounted) return;
        if (discard) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New event' : 'Edit event')),
        // R37: the form scrolls; no Spacer inside.
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: _checkDirty,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                TextFormField(
                  controller: _title,
                  focusNode: _titleFocus,
                  maxLength: 60,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  onTapOutside: dismissKeyboard,
                  validator: _validateTitle,
                ),
                DropdownButtonFormField<EventCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final c in EventCategory.values)
                      DropdownMenuItem(value: c, child: Text(c.label)),
                  ],
                  onChanged: (c) => setState(() {
                    _category = c;
                    _dirty = _differs();
                  }),
                  validator: (c) => c == null ? 'Choose a category' : null,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online event'),
                  value: _online,
                  onChanged: (v) => setState(() {
                    _online = v;
                    _dirty = _differs();
                  }),
                ),
                TextFormField(
                  controller: _place,
                  focusNode: _placeFocus,
                  decoration: InputDecoration(
                    labelText: _online ? 'Link' : 'Place',
                  ),
                  keyboardType: _online ? TextInputType.url : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                  onTapOutside: dismissKeyboard,
                  validator: _validatePlace,
                ),
                TextFormField(
                  controller: _dateText,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _pickDate,
                  validator: _validateDate,
                ),
                TextFormField(
                  controller: _timeText,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    suffixIcon: Icon(Icons.schedule),
                  ),
                  onTap: _pickTime,
                  validator: _validateTime,
                ),
                TextFormField(
                  controller: _capacity,
                  focusNode: _capacityFocus,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                  onTapOutside: dismissKeyboard,
                  validator: _validateCapacity,
                ),
                TextFormField(
                  controller: _description,
                  focusNode: _descriptionFocus,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  onTapOutside: dismissKeyboard,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
