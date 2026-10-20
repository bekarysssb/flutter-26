import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import 'event_card.dart';

/// R20: phones get a ListView.separated, 600 px and up a GridView.builder
/// with cells of at most 360 px. The decision is made by LayoutBuilder
/// (the width this widget is given), not by MediaQuery.
class EventList extends StatelessWidget {
  const EventList({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<CampusEvent> events;
  final ValueChanged<CampusEvent> onOpen;
  final ValueChanged<CampusEvent> onFavourite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget card(CampusEvent e) => EventCard(
              event: e,
              onTap: () => onOpen(e),
              onFavourite: () => onFavourite(e),
            );

        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 124,
            ),
            itemCount: events.length,
            itemBuilder: (context, i) => card(events[i]),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: events.length,
          separatorBuilder: (context, i) => const SizedBox(height: 4),
          itemBuilder: (context, i) => card(events[i]),
        );
      },
    );
  }
}
