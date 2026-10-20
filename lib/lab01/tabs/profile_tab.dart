import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../models/profile.dart';
import '../utils/format.dart';
import '../utils/keyboard.dart';

final _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{4}$');

/// Tab 3. The profile and the theme mode come from above; changes go
/// back up through callbacks.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.events,
    required this.themeMode,
    required this.onProfile,
    required this.onThemeMode,
  });

  final Profile profile;
  final List<CampusEvent> events;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfile;
  final ValueChanged<ThemeMode> onThemeMode;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _group;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  /// "Reset data" in the drawer clears the profile from outside, so the
  /// controllers must follow the model.
  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.name != oldWidget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (widget.profile.group != oldWidget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  void _commit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onProfile(
        Profile(name: _name.text.trim(), group: _group.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // Computed on every build, never stored.
    final lists = widget.events
        .where((e) => e.contains(widget.profile.name))
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  helperText: 'Press Done to save',
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _commit(),
                onTapOutside: dismissKeyboard,
                validator: (v) =>
                    (v ?? '').trim().length < 2 ? 'At least 2 characters' : null,
              ),
              TextFormField(
                controller: _group,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  hintText: 'IT-2301',
                  helperText: 'Press Done to save',
                ),
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                onFieldSubmitted: (_) => _commit(),
                onTapOutside: dismissKeyboard,
                validator: (v) {
                  final s = (v ?? '').trim();
                  return s.isEmpty || _groupPattern.hasMatch(s)
                      ? null
                      : 'Use a format like IT-2301';
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('You are on $lists lists', style: text.titleMedium),
        const SizedBox(height: 24),
        Text('Theme', style: text.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final m in ThemeMode.values)
              ChoiceChip(
                label: Text(capitalize(m.name)),
                selected: widget.themeMode == m,
                onSelected: (_) => widget.onThemeMode(m),
              ),
          ],
        ),
      ],
    );
  }
}
