import 'package:flutter/material.dart';

enum EventCategory {
  tech('Tech', Icons.code),
  sport('Sport', Icons.sports_soccer),
  music('Music', Icons.music_note),
  art('Art', Icons.palette),
  career('Career', Icons.work),
  social('Social', Icons.groups);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// R2: exhaustive switch expression, no default: add a value and the
/// compiler lists every place that must follow.
Color categoryColor(EventCategory c, ColorScheme s) => switch (c) {
      EventCategory.tech => s.primary,
      EventCategory.sport => s.secondary,
      EventCategory.music => s.tertiary,
      EventCategory.art => s.error,
      EventCategory.career => s.outline,
      EventCategory.social => s.onSurfaceVariant,
    };
