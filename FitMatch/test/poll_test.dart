import 'package:fitmatch/poll.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryEventStorage implements EventStorage {
  List<PollEvent> saved = [];
  bool failNextWrite = false;

  @override
  Future<List<PollEvent>> read() async => saved;

  @override
  Future<void> write(List<PollEvent> events) async {
    if (failNextWrite) {
      failNextWrite = false;
      throw StateError('Write failed');
    }
    saved = events;
  }
}

void main() {
  late MemoryEventStorage storage;
  late PollController poll;

  setUp(() {
    storage = MemoryEventStorage();
    poll = PollController(storage, clock: () => DateTime.utc(2026, 11, 25));
    addTearDown(poll.dispose);
  });

  test(
    'one invite records one acceptance and one vote despite repeat taps',
    () async {
      final id = await poll.send(Friend.maya);
      await expectLater(poll.send(Friend.maya), throwsStateError);
      await expectLater(poll.vote(id, Outfit.tailored), throwsStateError);
      await Future.wait([poll.accept(id), poll.accept(id)]);
      await Future.wait([
        poll.vote(id, Outfit.relaxed),
        poll.vote(id, Outfit.tailored),
      ]);

      expect(poll.events.map((event) => event.type), EventType.values);
      expect(poll.votesFor(Outfit.relaxed), 1);
      expect(poll.votesFor(Outfit.tailored), 0);
      expect(poll.events.map((event) => event.inviteId).toSet(), {id});
    },
  );

  test(
    'a reload restores independent invites and exports their events',
    () async {
      final firstId = await poll.send(Friend.maya);
      final secondId = await poll.send(Friend.leo);
      await poll.accept(secondId);

      final reloaded = PollController(storage);
      addTearDown(reloaded.dispose);
      await reloaded.load();

      expect(reloaded.invite(firstId).accepted, false);
      expect(reloaded.invite(secondId).accepted, true);
      expect(reloaded.count(EventType.inviteSent), 2);
      expect(
        reloaded.exportCsv(),
        contains('invite_accepted,2,leo,2026-11-25'),
      );
    },
  );

  test(
    'a failed write leaves the invite and its funnel counts consistent',
    () async {
      storage.failNextWrite = true;
      await expectLater(poll.send(Friend.maya), throwsStateError);
      expect(poll.events, isEmpty);
      expect(poll.invites, isEmpty);

      expect(await poll.send(Friend.maya), 1);
      expect(poll.count(EventType.inviteSent), 1);
    },
  );
}
