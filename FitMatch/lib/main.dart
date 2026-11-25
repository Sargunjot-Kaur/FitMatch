import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'design.dart';
import 'poll.dart';
import 'screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitMatchApp());
}

class FitMatchApp extends StatefulWidget {
  const FitMatchApp({super.key});

  @override
  State<FitMatchApp> createState() => _FitMatchAppState();
}

class _FitMatchAppState extends State<FitMatchApp> {
  late final PollController _poll;
  late Future<void> _loaded;

  @override
  void initState() {
    super.initState();
    _poll = PollController(PreferencesEventStorage(SharedPreferencesAsync()));
    _loaded = _poll.load();
  }

  @override
  void dispose() {
    _poll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FitMatch',
    debugShowCheckedModeBanner: false,
    theme: fitMatchTheme(),
    home: FutureBuilder<void>(
      future: _loaded,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('FitMatch couldn’t open the saved demo.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() => _loaded = _poll.load()),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Workspace(poll: _poll);
      },
    ),
  );
}

enum Section {
  board('Outfit board', Icons.checkroom_outlined),
  inbox('Friend inbox', Icons.inbox_outlined),
  events('Event log', Icons.bar_chart_rounded);

  const Section(this.label, this.icon);

  final String label;
  final IconData icon;
}

class Workspace extends StatefulWidget {
  const Workspace({super.key, required this.poll});

  final PollController poll;

  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  Section _section = Section.board;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 880;
      return Scaffold(
        bottomNavigationBar: desktop
            ? null
            : NavigationBar(
                selectedIndex: _section.index,
                onDestinationSelected: (index) =>
                    setState(() => _section = Section.values[index]),
                backgroundColor: paper,
                indicatorColor: blush,
                height: 69,
                destinations: [
                  for (final section in Section.values)
                    NavigationDestination(
                      icon: Icon(section.icon),
                      label: section.label,
                    ),
                ],
              ),
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (desktop) _sidebar(),
              Expanded(
                child: AnimatedBuilder(
                  animation: widget.poll,
                  builder: (context, child) => CustomScrollView(
                    key: PageStorageKey(_section),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1150),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                desktop ? 49 : 20,
                                desktop ? 27 : 17,
                                desktop ? 49 : 20,
                                32,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (desktop)
                                        Text(
                                          _section.label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: muted,
                                          ),
                                        )
                                      else
                                        const Brand(),
                                      const StatusPill('Interactive demo'),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  const Divider(height: 1),
                                  SizedBox(height: desktop ? 32 : 24),
                                  switch (_section) {
                                    Section.board => BoardScreen(
                                      poll: widget.poll,
                                      openInbox: () => setState(
                                        () => _section = Section.inbox,
                                      ),
                                    ),
                                    Section.inbox => InboxScreen(
                                      poll: widget.poll,
                                    ),
                                    Section.events => EventScreen(
                                      poll: widget.poll,
                                    ),
                                  },
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _sidebar() => Container(
    width: 213,
    decoration: const BoxDecoration(
      color: paper,
      border: Border(right: BorderSide(color: border)),
    ),
    padding: const EdgeInsets.fromLTRB(17, 26, 17, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(left: 8), child: Brand()),
        const SizedBox(height: 45),
        for (final section in Section.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: _section == section ? blush : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Semantics(
                selected: _section == section,
                button: true,
                child: InkWell(
                  onTap: () => setState(() => _section = section),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Icon(section.icon, color: plum, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          section.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _section == section
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _section == section ? plum : muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        const Divider(),
        const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 5),
          leading: CircleAvatar(
            backgroundColor: rose,
            foregroundColor: ink,
            radius: 18,
            child: Text(
              'SK',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          minLeadingWidth: 0,
          title: Text(
            'Sargun',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            'Poll creator',
            style: TextStyle(fontSize: 11, color: muted),
          ),
        ),
      ],
    ),
  );
}
