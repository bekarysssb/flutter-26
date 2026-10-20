import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_list.dart';

/// Tab 2. Stateless: everything comes from the shell.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
    required this.onBrowse,
  });

  final List<CampusEvent> events;
  final ValueChanged<CampusEvent> onOpen;
  final ValueChanged<CampusEvent> onFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = [...events.where((e) => e.favourite)]
      ..sort((a, b) => a.starts.compareTo(b.starts));

    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        actionLabel: 'Browse events',
        onAction: onBrowse,
      );
    }
    return EventList(
      events: favourites,
      onOpen: onOpen,
      onFavourite: onFavourite,
    );
  }
}
