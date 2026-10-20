import 'package:flutter/material.dart';

import 'models/campus_event.dart';

/// R25: the only file with route-name literals.
class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

/// R26: the detail receives the event AND callbacks through its route
/// arguments, so it never needs to know who owns the list.
class DetailArgs {
  const DetailArgs({
    required this.event,
    required this.userName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final CampusEvent event;
  final String userName;
  final ValueChanged<CampusEvent> onChanged;
  final ValueChanged<CampusEvent> onDelete;
  final VoidCallback onOpenProfile;
}

/// R26: the form receives an optional event (null = new) and RETURNS
/// the result through Navigator.pop.
class FormArgs {
  const FormArgs({this.event});

  final CampusEvent? event;
}
