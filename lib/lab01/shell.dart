import 'package:flutter/material.dart';

import 'data/seed.dart';
import 'models/campus_event.dart';
import 'models/profile.dart';
import 'routes.dart';
import 'tabs/events_tab.dart';
import 'tabs/favourites_tab.dart';
import 'tabs/profile_tab.dart';

const _titles = ['Campus events', 'Favourites', 'Profile'];

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeMode,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeMode;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  // R10: the list and the profile live here; tabs get them as parameters
  // and send changes up as callbacks. The list is replaced, never mutated.
  List<CampusEvent> _events = buildSeed();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _goTo(int index) => setState(() => _tab = index);

  void _replace(CampusEvent updated) => setState(
        () => _events = [
          for (final e in _events)
            if (e.id == updated.id) updated else e,
        ],
      );

  void _delete(CampusEvent gone) => setState(
        () => _events = [
          for (final e in _events)
            if (e.id != gone.id) e,
        ],
      );

  void _toggleFavourite(CampusEvent e) =>
      _replace(e.copyWith(favourite: !e.favourite));

  void _setProfile(Profile p) => setState(() => _profile = p);

  void _openDetail(CampusEvent e) {
    Navigator.of(context).pushNamed(
      Routes.detail,
      arguments: DetailArgs(
        event: e,
        userName: _profile.name,
        onChanged: _replace,
        onDelete: _delete,
        onOpenProfile: () => _goTo(2), // R28: tab switch via a shell callback
      ),
    );
  }

  /// R27: await, check null, check mounted, then setState.
  Future<void> _openForm() async {
    final created = await Navigator.of(context).pushNamed<CampusEvent>(
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null) return;
    if (!mounted) return;
    setState(() => _events = [..._events, created]);
  }

  /// R32: the tile closes the drawer with Navigator.pop, then acts.
  void _about() {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About'),
        content: const Text('Campus Events. Lab 1: all data lives in memory.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    Navigator.of(context).pop();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text('Events return to the seed, the profile is cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    setState(() {
      _events = buildSeed();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Campus Events'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: _about,
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset data'),
              onTap: _resetData,
            ),
          ],
        ),
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _openForm,
              child: const Icon(Icons.add),
            )
          : null,
      body: IndexedStack(
        index: _tab,
        children: [
          EventsTab(
            events: _events,
            onOpen: _openDetail,
            onFavourite: _toggleFavourite,
            onAdd: _openForm,
          ),
          FavouritesTab(
            events: _events,
            onOpen: _openDetail,
            onFavourite: _toggleFavourite,
            onBrowse: () => _goTo(0),
          ),
          ProfileTab(
            profile: _profile,
            events: _events,
            themeMode: widget.themeMode,
            onProfile: _setProfile,
            onThemeMode: widget.onThemeMode,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favourites'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
