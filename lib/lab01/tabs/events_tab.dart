import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../models/category.dart';
import '../utils/keyboard.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_list.dart';

/// Upcoming first (soonest first), past items last.
int _byDate(CampusEvent a, CampusEvent b) {
  if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
  return a.starts.compareTo(b.starts);
}

/// Tab 1. The events come from the shell; search text and filters are
/// local to this tab, so they live in its own State.
class EventsTab extends StatefulWidget {
  const EventsTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
    required this.onAdd,
  });

  final List<CampusEvent> events;
  final ValueChanged<CampusEvent> onOpen;
  final ValueChanged<CampusEvent> onFavourite;
  final VoidCallback onAdd;

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final _search = TextEditingController();
  String _query = '';
  EventCategory? _category; // null means "All"
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// R7: where + a sorted COPY; the state list is never sorted in place.
  List<CampusEvent> get _visible {
    final q = _query.trim().toLowerCase();
    return [
      ...widget.events.where(
        (e) =>
            (_showPast || !e.isPast) &&
            (_category == null || e.category == _category) &&
            e.title.toLowerCase().contains(q),
      ),
    ]..sort(_byDate);
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search events',
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
            ),
            textInputAction: TextInputAction.search,
            onChanged: (v) => setState(() => _query = v),
            onTapOutside: dismissKeyboard,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final c in EventCategory.values)
                ChoiceChip(
                  avatar: Icon(c.icon),
                  label: Text(c.label),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                ),
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (v) => setState(() => _showPast = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? (widget.events.isEmpty
                  ? EmptyState(
                      icon: Icons.event_busy,
                      message: 'No events yet',
                      actionLabel: 'Add event',
                      onAction: widget.onAdd,
                    )
                  : EmptyState(
                      icon: Icons.search_off,
                      message: 'No events match',
                      actionLabel: 'Clear search',
                      onAction: _clearSearch,
                    ))
              : EventList(
                  events: visible,
                  onOpen: widget.onOpen,
                  onFavourite: widget.onFavourite,
                ),
        ),
      ],
    );
  }
}
