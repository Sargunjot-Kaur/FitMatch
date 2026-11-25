import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Friend {
  maya('Maya Patel', 'MP'),
  leo('Leo Martin', 'LM');

  const Friend(this.label, this.initials);

  final String label;
  final String initials;

  String get firstName => label.split(' ').first;
}

enum Outfit {
  tailored('Look A', 'The tailored edit', 'Camel blazer · Charcoal trousers'),
  relaxed('Look B', 'The relaxed edit', 'Cream knit · Light-wash denim');

  const Outfit(this.tag, this.title, this.description);

  final String tag;
  final String title;
  final String description;
}

enum EventType {
  inviteSent('invite_sent', 'Invite sent'),
  inviteAccepted('invite_accepted', 'Invite accepted'),
  outfitVoted('outfit_voted', 'Vote submitted');

  const EventType(this.key, this.label);

  final String key;
  final String label;
}

class PollEvent {
  const PollEvent({
    required this.type,
    required this.inviteId,
    required this.friend,
    required this.occurredAt,
    this.outfit,
  });

  PollEvent.fromJson(Map<String, dynamic> json)
    : type = EventType.values.byName(json['type'] as String),
      inviteId = json['invite_id'] as int,
      friend = Friend.values.byName(json['friend'] as String),
      occurredAt = DateTime.parse(json['occurred_at'] as String).toUtc(),
      outfit = json['outfit'] == null
          ? null
          : Outfit.values.byName(json['outfit'] as String);

  final EventType type;
  final int inviteId;
  final Friend friend;
  final DateTime occurredAt;
  final Outfit? outfit;

  Map<String, Object?> toJson() => {
    'type': type.name,
    'invite_id': inviteId,
    'friend': friend.name,
    'occurred_at': occurredAt.toIso8601String(),
    'outfit': outfit?.name,
  };
}

class Invite {
  const Invite(this.id, this.friend, {this.accepted = false, this.vote});

  final int id;
  final Friend friend;
  final bool accepted;
  final Outfit? vote;
}

abstract interface class EventStorage {
  Future<List<PollEvent>> read();
  Future<void> write(List<PollEvent> events);
}

class PreferencesEventStorage implements EventStorage {
  PreferencesEventStorage(this.preferences);

  static const _key = 'fitmatch.events.v1';
  final SharedPreferencesAsync preferences;

  @override
  Future<List<PollEvent>> read() async {
    final data = await preferences.getString(_key);
    if (data == null) return [];
    return (jsonDecode(data) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(PollEvent.fromJson)
        .toList();
  }

  @override
  Future<void> write(List<PollEvent> events) =>
      preferences.setString(_key, jsonEncode(events));
}

class PollController extends ChangeNotifier {
  PollController(this._storage, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final EventStorage _storage;
  final DateTime Function() _clock;
  List<PollEvent> _events = [];
  Future<void> _queue = Future.value();

  List<PollEvent> get events => List.unmodifiable(_events);

  Future<void> load() async {
    _events = await _storage.read();
    notifyListeners();
  }

  List<Invite> get invites {
    final invites = <int, Invite>{};
    for (final event in _events) {
      invites[event.inviteId] = switch (event.type) {
        EventType.inviteSent => Invite(event.inviteId, event.friend),
        EventType.inviteAccepted => Invite(
          event.inviteId,
          event.friend,
          accepted: true,
        ),
        EventType.outfitVoted => Invite(
          event.inviteId,
          event.friend,
          accepted: true,
          vote: event.outfit,
        ),
      };
    }
    return invites.values.toList().reversed.toList();
  }

  bool canInvite(Friend friend) =>
      !invites.any((invite) => invite.friend == friend && invite.vote == null);

  Invite invite(int id) => invites.firstWhere((invite) => invite.id == id);

  int count(EventType type) =>
      _events.where((event) => event.type == type).length;

  int votesFor(Outfit outfit) =>
      _events.where((event) => event.outfit == outfit).length;

  Future<int> send(Friend friend) => _serial(() async {
    if (!canInvite(friend)) {
      throw StateError('${friend.firstName} already has an open invite.');
    }
    final id = invites.isEmpty ? 1 : invites.first.id + 1;
    await _record(EventType.inviteSent, Invite(id, friend));
    return id;
  });

  Future<void> accept(int id) => _serial(() async {
    final current = invite(id);
    if (current.accepted) return;
    await _record(EventType.inviteAccepted, current);
  });

  Future<void> vote(int id, Outfit outfit) => _serial(() async {
    final current = invite(id);
    if (!current.accepted) throw StateError('Accept the invitation first.');
    if (current.vote != null) return;
    await _record(EventType.outfitVoted, current, outfit: outfit);
  });

  Future<T> _serial<T>(Future<T> Function() action) {
    final next = _queue.then((_) => action());
    _queue = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  Future<void> _record(EventType type, Invite invite, {Outfit? outfit}) async {
    final updated = [
      ..._events,
      PollEvent(
        type: type,
        inviteId: invite.id,
        friend: invite.friend,
        occurredAt: _clock().toUtc(),
        outfit: outfit,
      ),
    ];
    await _storage.write(updated);
    _events = updated;
    notifyListeners();
  }

  String exportCsv() {
    final rows = [
      'event_name,invite_id,friend,occurred_at,outfit',
      for (final event in _events)
        [
          event.type.key,
          event.inviteId,
          event.friend.name,
          event.occurredAt.toIso8601String(),
          event.outfit?.name ?? '',
        ].join(','),
    ];
    return '${rows.join('\n')}\n';
  }
}
