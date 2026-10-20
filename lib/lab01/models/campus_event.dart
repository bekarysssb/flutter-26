import 'dart:collection';

import 'category.dart';

/// How long an event lasts after it starts (used by the countdown).
const eventLength = Duration(hours: 2);

/// R9: sealed, so every `switch` over it must cover all three cases.
sealed class Countdown {
  const Countdown();
}

class Upcoming extends Countdown {
  const Upcoming(this.left);

  final Duration left;
}

class Started extends Countdown {
  const Started(this.ago);

  final Duration ago;
}

class Ended extends Countdown {
  const Ended();
}

/// R1: immutable. All fields are final, the constructor is const,
/// the names list is private and only exposed as an unmodifiable view.
class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.starts,
    required this.location,
    required this.capacity,
    required this.online,
    List<String> attendees = const [],
    this.description,
    this.favourite = false,
  }) : _attendees = attendees;

  /// R3: defaults of a new event.
  CampusEvent.empty()
      : id = DateTime.now().microsecondsSinceEpoch.toString(),
        title = '',
        category = EventCategory.tech,
        starts = DateTime.now().add(const Duration(days: 1)),
        location = '',
        capacity = 30,
        online = false,
        _attendees = const [],
        description = null,
        favourite = false;

  final String id;
  final String title;
  final EventCategory category;
  final DateTime starts;
  final String location;
  final int capacity;
  final bool online; // mode: online means `location` is a link
  final List<String> _attendees;
  final String? description; // optional text
  final bool favourite;

  List<String> get attendees => UnmodifiableListView(_attendees);

  // R4: derived values are getters, never fields.
  int get count => _attendees.length;
  int get free => capacity - count;
  bool get isFull => count >= capacity;
  bool get isPast => starts.isBefore(DateTime.now());

  bool contains(String name) => _attendees.contains(name);

  // R5: record getter.
  ({int taken, int free}) get places => (taken: count, free: free);

  Countdown countdownAt(DateTime now) {
    if (starts.isAfter(now)) return Upcoming(starts.difference(now));
    final ago = now.difference(starts);
    return ago < eventLength ? Started(ago) : const Ended();
  }

  Countdown get countdown => countdownAt(DateTime.now());

  CampusEvent copyWith({
    String? title,
    EventCategory? category,
    DateTime? starts,
    String? location,
    int? capacity,
    bool? online,
    List<String>? attendees,
    String? description,
    bool? favourite,
  }) =>
      CampusEvent(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        starts: starts ?? this.starts,
        location: location ?? this.location,
        capacity: capacity ?? this.capacity,
        online: online ?? this.online,
        attendees: attendees ?? _attendees,
        description: description ?? this.description,
        favourite: favourite ?? this.favourite,
      );

  CampusEvent join(String name) => copyWith(attendees: [..._attendees, name]);

  CampusEvent leave(String name) => copyWith(
        attendees: [
          for (final n in _attendees)
            if (n != name) n,
        ],
      );
}
