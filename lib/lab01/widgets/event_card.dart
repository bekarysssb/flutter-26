import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../models/category.dart';
import '../utils/format.dart';

/// R18 + R19: the one reusable card. Avatar Stack on the left, Expanded
/// column in the middle, favourite button on the right.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onFavourite,
  });

  final CampusEvent event;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final badge = event.isFull
        ? 'FULL'
        : event.free <= 5
            ? '${event.free} left'
            : null;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: categoryColor(event.category, colors),
                    foregroundColor: colors.surface,
                    child: Icon(event.category.icon),
                  ),
                  if (badge != null)
                    Positioned(
                      top: -8,
                      right: -12,
                      child: _Badge(text: badge),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    Text(
                      event.isPast
                          ? '${formatDateTime(event.starts)} · past'
                          : formatDateTime(event.starts),
                      style: text.bodySmall,
                    ),
                    Text(
                      event.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavourite,
                icon: Icon(
                  event.favourite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onInverseSurface,
          ),
        ),
      ),
    );
  }
}
