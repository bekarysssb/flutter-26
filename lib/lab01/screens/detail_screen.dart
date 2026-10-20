import 'dart:async';

import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../models/category.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

/// If this lab lives in its own repository, change it to
/// 'assets/header.png' (and the pubspec entry to `- assets/`).
const kHeaderAsset = 'lib/lab01/assets/header.png';

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late CampusEvent _event;
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _event = widget.args.event;
    // R13: created in initState, cancelled in dispose.
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _ask(String title, String yes) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(yes),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  /// R28: leave this screen (if it is still there), then ask the shell
  /// to switch the tab.
  void _openProfile() {
    if (mounted) Navigator.of(context).pop();
    widget.args.onOpenProfile();
  }

  /// R15: Register / Leave. Asks first, acts on true.
  Future<void> _primary() async {
    final name = widget.args.userName.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in the profile first'),
          action: SnackBarAction(label: 'Profile', onPressed: _openProfile),
        ),
      );
      return;
    }
    final joined = _event.contains(name);
    // Registering asks first; leaving is its opposite and acts at once.
    if (!joined) {
      final ok = await _ask('Register for "${_event.title}"?', 'Register');
      if (!ok) return;
      if (!mounted) return;
    }
    final updated = joined ? _event.leave(name) : _event.join(name);
    setState(() => _event = updated);
    widget.args.onChanged(updated);
  }

  /// R27 on the edit side: await, null, mounted, setState.
  Future<void> _edit() async {
    final updated = await Navigator.of(context).pushNamed<CampusEvent>(
      Routes.form,
      arguments: FormArgs(event: _event),
    );
    if (updated == null) return;
    if (!mounted) return;
    setState(() => _event = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _delete() async {
    final ok = await _ask('Delete "${_event.title}"?', 'Delete');
    if (!ok) return;
    if (!mounted) return;
    widget.args.onDelete(_event);
    Navigator.of(context).pop();
  }

  Widget _header(ColorScheme scheme) {
    return SizedBox(
      height: 160,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(kHeaderAsset, fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: scheme.surface,
              foregroundColor: categoryColor(_event.category, scheme),
              child: Icon(_event.category.icon, size: 36),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: _Pill(text: _event.category.label),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _Pill(text: countdownText(_event.countdownAt(_now))),
          ),
        ],
      ),
    );
  }

  Widget _about() {
    // R5: destructured where it is shown.
    final (taken: taken, free: free) = _event.places;
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(formatDateTime(_event.starts)),
        ),
        ListTile(
          leading: Icon(_event.online ? Icons.link : Icons.place),
          title: Text(_event.location),
        ),
        ListTile(
          leading: const Icon(Icons.event_seat),
          title: Text('$taken taken · $free free of ${_event.capacity}'),
        ),
        // R6: optional text, shown only when present.
        if (_event.description case final text?)
          ListTile(leading: const Icon(Icons.notes), title: Text(text)),
      ],
    );
  }

  Widget _names(String me, ColorScheme scheme) {
    if (_event.count == 0) {
      return const EmptyState(
        icon: Icons.group_off,
        message: 'Nobody has registered yet',
      );
    }
    return ListView(
      children: [
        for (final n in _event.attendees)
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(n),
            tileColor: n == me ? scheme.primaryContainer : null,
            trailing: n == me ? const Chip(label: Text('You')) : null,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final me = widget.args.userName.trim();
    final joined = _event.contains(me);
    final blocked = !joined && _event.isFull; // R16

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // R31: no back arrow written anywhere, the AppBar adds it.
        appBar: AppBar(
          title: Text(_event.title),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (a) => switch (a) {
                _MenuAction.edit => _edit(),
                _MenuAction.delete => _delete(),
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'About'),
              Tab(text: 'Names (${_event.count})'),
            ],
          ),
        ),
        body: Column(
          children: [
            _header(scheme),
            Expanded(
              child: TabBarView(children: [_about(), _names(me, scheme)]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: blocked ? null : _primary,
                  child: Text(
                    joined
                        ? 'Leave'
                        : blocked
                            ? 'Full'
                            : 'Register',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(text, style: theme.textTheme.labelMedium),
      ),
    );
  }
}
