import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design.dart';
import 'poll.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key, required this.poll, required this.openInbox});

  final PollController poll;
  final VoidCallback openInbox;

  Future<void> _showInvite(BuildContext context) async {
    final id = await showDialog<int>(
      context: context,
      builder: (context) => InviteDialog(poll: poll),
    );
    if (id == null || !context.mounted) return;
    final friend = poll.invite(id).friend;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invite sent to ${friend.firstName}.')),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const PageHeading(
        label: 'Saturday dinner',
        title: 'What should I wear?',
        description:
            'Two looks for Saturday night. Ask a friend to help you choose.',
      ),
      const SizedBox(height: 25),
      LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.maxWidth >= 805;
          final looks = Looks(controller: poll);
          final panel = _InvitePanel(
            poll: poll,
            openInbox: openInbox,
            showInvite: () => _showInvite(context),
            compact: constraints.maxWidth < 520,
          );
          if (!side) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [looks, const SizedBox(height: 18), panel],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: looks),
              const SizedBox(width: 22),
              SizedBox(width: 300, child: panel),
            ],
          );
        },
      ),
    ],
  );
}

class _InvitePanel extends StatelessWidget {
  const _InvitePanel({
    required this.poll,
    required this.openInbox,
    required this.showInvite,
    required this.compact,
  });

  final PollController poll;
  final VoidCallback openInbox;
  final VoidCallback showInvite;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final invites = poll.invites;
    final hasAvailableFriend = Friend.values.any(poll.canInvite);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Panel(
          fill: const Color(0xFFF5EAF0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!compact) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: IconTile(Icons.group_outlined, fill: paper),
                ),
                const SizedBox(height: 13),
              ],
              const Text(
                'A second opinion',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w500,
                  fontSize: 27,
                  letterSpacing: -.65,
                ),
              ),
              const SizedBox(height: 6),
              const BodyCopy(
                'Send both looks to a friend and see which one they pick.',
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: hasAvailableFriend ? showInvite : null,
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                label: const Text('Invite a friend'),
              ),
              if (!hasAvailableFriend) ...[
                const SizedBox(height: 8),
                const BodyCopy('Both friends have an open invite.', size: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Panel(
          padding: const EdgeInsets.fromLTRB(17, 14, 17, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Invite activity',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 7),
              if (invites.isEmpty)
                const BodyCopy(
                  'Your invites and votes will appear here.',
                  size: 12,
                )
              else ...[
                for (final invite in invites.take(2))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            invite.friend.label,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        InviteStatus(invite: invite),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: openInbox,
                  icon: const Icon(Icons.inbox_outlined, size: 16),
                  label: const Text('Open friend inbox'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class InviteStatus extends StatelessWidget {
  const InviteStatus({super.key, required this.invite});

  final Invite invite;

  @override
  Widget build(BuildContext context) => StatusPill(
    invite.vote != null
        ? 'Voted'
        : invite.accepted
        ? 'Accepted'
        : 'Pending',
    fill: invite.accepted ? green : blush,
    color: invite.accepted ? greenInk : plum,
  );
}

class InviteDialog extends StatefulWidget {
  const InviteDialog({super.key, required this.poll});

  final PollController poll;

  @override
  State<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  Friend? _friend;
  bool _sending = false;
  String? _error;

  Future<void> _send() async {
    final friend = _friend;
    if (friend == null || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final id = await widget.poll.send(friend);
      if (mounted) Navigator.of(context).pop(id);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = widget.poll.canInvite(friend)
            ? 'The invite couldn’t be saved. Try again.'
            : '${friend.firstName} already has an open invite.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_sending,
    child: AlertDialog(
      scrollable: true,
      constraints: const BoxConstraints(maxWidth: 420, minWidth: 290),
      title: const Text(
        'Invite a friend',
        style: TextStyle(
          fontFamily: 'Playfair Display',
          fontWeight: FontWeight.w500,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BodyCopy(
            'Choose a demo contact for your Saturday dinner poll.',
          ),
          const SizedBox(height: 14),
          RadioGroup<Friend>(
            groupValue: _friend,
            onChanged: (selected) => setState(() => _friend = selected),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final friend in Friend.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Material(
                      color: _friend == friend ? blush : canvas,
                      borderRadius: BorderRadius.circular(11),
                      clipBehavior: Clip.antiAlias,
                      child: RadioListTile<Friend>(
                        value: friend,
                        enabled: !_sending && widget.poll.canInvite(friend),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        secondary: FriendAvatar(friend),
                        subtitle: widget.poll.canInvite(friend)
                            ? null
                            : const Text('Invite open'),
                        title: Text(
                          friend.label,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _friend == null || _sending ? null : _send,
          child: Text(_sending ? 'Sending…' : 'Send invite'),
        ),
      ],
    ),
  );
}

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key, required this.poll});

  final PollController poll;

  @override
  Widget build(BuildContext context) {
    final invites = poll.invites;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          label: 'Friend view',
          title: 'Friend inbox',
          description: 'Open an invite below to respond as that demo contact.',
        ),
        const SizedBox(height: 24),
        if (invites.isEmpty)
          const Panel(
            child: Row(
              children: [
                IconTile(Icons.inbox_outlined),
                SizedBox(width: 13),
                Expanded(
                  child: BodyCopy(
                    'Send an invite from the outfit board to get started.',
                  ),
                ),
              ],
            ),
          ),
        for (final invite in invites)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Panel(
              padding: const EdgeInsets.all(9),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                leading: FriendAvatar(invite.friend),
                title: Text(
                  invite.friend.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: const Text(
                  'Saturday dinner',
                  style: TextStyle(color: muted),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InviteStatus(invite: invite),
                    const SizedBox(width: 5),
                    const Icon(Icons.chevron_right, size: 19),
                  ],
                ),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        FriendScreen(poll: poll, inviteId: invite.id),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key, required this.poll, required this.inviteId});

  final PollController poll;
  final int inviteId;

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  Outfit? _choice;
  bool _busy = false;

  Future<void> _save(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your response couldn’t be saved. Try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.poll,
    builder: (context, child) {
      final invite = widget.poll.invite(widget.inviteId);
      final submitted = invite.vote;
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Friend inbox',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          backgroundColor: paper,
          surfaceTintColor: paper,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 690),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PageHeading(
                        label: 'Responding as ${invite.friend.firstName}',
                        title: submitted != null
                            ? 'Vote submitted'
                            : invite.accepted
                            ? 'Pick a look'
                            : 'Sargun wants your vote',
                        description: submitted != null
                            ? 'You picked ${submitted.title.toLowerCase()} for Saturday dinner.'
                            : invite.accepted
                            ? 'Which outfit should Sargun wear to Saturday dinner?'
                            : 'Accept the Saturday dinner invite to vote on these two looks.',
                      ),
                      const SizedBox(height: 20),
                      Looks(
                        selected: submitted ?? _choice,
                        onSelected:
                            invite.accepted && submitted == null && !_busy
                            ? (choice) => setState(() => _choice = choice)
                            : null,
                      ),
                      const SizedBox(height: 17),
                      if (submitted != null)
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Back to inbox'),
                        )
                      else if (invite.accepted)
                        ElevatedButton.icon(
                          onPressed: _choice == null || _busy
                              ? null
                              : () => _save(
                                  () => widget.poll.vote(invite.id, _choice!),
                                ),
                          icon: const Icon(Icons.check, size: 19),
                          label: const Text('Submit vote'),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _busy
                              ? null
                              : () =>
                                    _save(() => widget.poll.accept(invite.id)),
                          icon: const Icon(Icons.check, size: 19),
                          label: const Text('Accept invite'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class EventScreen extends StatelessWidget {
  const EventScreen({super.key, required this.poll});

  final PollController poll;

  Future<void> _copy(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: poll.exportCsv()));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Event CSV copied.')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard unavailable. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sent = poll.count(EventType.inviteSent);
    final accepted = poll.count(EventType.inviteAccepted);
    final voted = poll.count(EventType.outfitVoted);
    final rate = sent == 0 ? '—' : '${(100 * accepted / sent).round()}%';
    final metrics = [
      ('Invites sent', '$sent', Icons.near_me_outlined),
      ('Accepted', '$accepted', Icons.how_to_reg_outlined),
      ('Votes cast', '$voted', Icons.how_to_vote_outlined),
      ('Acceptance rate', rate, Icons.show_chart),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          label: 'Growth tracking',
          title: 'Invite funnel',
          description: 'Track how many outfit invites lead to a response.',
          trailing: OutlinedButton.icon(
            onPressed: sent == 0 ? null : () => _copy(context),
            icon: const Icon(Icons.copy_all_outlined, size: 17),
            label: const Text('Copy CSV'),
          ),
        ),
        const SizedBox(height: 21),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 730 ? 4 : 2;
            const gap = 12.0;
            final tileWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final (name, value, icon) in metrics)
                  SizedBox(
                    width: tileWidth,
                    child: Panel(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconTile(icon, size: 34),
                          const SizedBox(height: 9),
                          Text(
                            value,
                            style: const TextStyle(
                              fontFamily: 'Playfair Display',
                              fontWeight: FontWeight.w500,
                              fontSize: 32,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            name,
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Panel(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Event history',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              if (poll.events.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 7),
                  child: BodyCopy(
                    'Events will appear here after you send your first invite.',
                  ),
                ),
              for (final event in poll.events.reversed) ...[
                const Divider(height: 1),
                _EventRow(event: event),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final PollEvent event;

  @override
  Widget build(BuildContext context) {
    final local = event.occurredAt.toLocal();
    final date = MaterialLocalizations.of(context).formatShortDate(local);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(local));
    final detail = [
      event.friend.firstName,
      'Invite #${event.inviteId}',
      if (event.outfit != null) event.outfit!.tag,
    ].join(' · ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(
        switch (event.type) {
          EventType.inviteSent => Icons.near_me_outlined,
          EventType.inviteAccepted => Icons.check_circle_outline,
          EventType.outfitVoted => Icons.how_to_vote_outlined,
        },
        color: plum,
        size: 19,
      ),
      title: Text(
        event.type.key,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      subtitle: Text(
        detail,
        style: const TextStyle(fontSize: 12, color: muted),
      ),
      trailing: Text(
        '$date\n$time',
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 11, color: muted),
      ),
    );
  }
}
