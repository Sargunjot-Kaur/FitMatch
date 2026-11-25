# FitMatch

FitMatch started as a digital wardrobe concept. This Flutter demo lets you ask a friend to choose between two outfits. The demo also tracks whether friends accept the invitation and cast a vote.

[Download the 38-second demo recording](docs/FitMatch-Demo.mp4)

## Try the demo

1. Open **Outfit board**, select **Invite a friend**, and send the poll to Maya Patel.
2. Open **Friend inbox**, select Maya’s invite, and tap **Accept invite**.
3. Pick Look A or Look B and submit your vote. Go back to **Outfit board** to see the result.
4. Open **Event log** to see how many invites were sent, accepted, and followed by a vote.

The demo comes with two sample outfits and fictional contacts. You can play both sides of the invitation in the same app. Events are stored locally and stay available after a refresh.

## Run locally

With Flutter 3.38.7 or newer and Chrome installed, run these commands from the directory containing `pubspec.yaml`.

```bash
flutter pub get
flutter run -d chrome
```

If you downloaded the project bundle, you can use the prebuilt version with Python 3. Run this from the extracted directory containing `web-preview`.

```bash
python3 -m http.server 8080 --directory web-preview
```

Open [localhost:8080](http://localhost:8080) in your browser.

## Invite tracking

| Event | When it fires |
| --- | --- |
| `invite_sent` | The outfit owner sends an invitation. |
| `invite_accepted` | The friend accepts the invitation. |
| `outfit_voted` | The friend submits their choice. |

All three events share an invite ID, so you can follow the same invitation from send to vote. **Acceptance rate** is accepted invites divided by invites sent. For example, if one of two invites is accepted, the dashboard shows **50%**. Recording acceptance and voting separately shows whether people who accept actually make a choice.

Select **Copy CSV** in the event log, save the clipboard contents as `events.csv` next to `pubspec.yaml`, and run the included query with the SQLite command-line tool.

```bash
sqlite3 :memory: < analytics/invite_funnel.sql
```

## Code and tests

- [`lib/screens.dart`](lib/screens.dart) contains the outfit board, friend inbox, voting screen, and event log.
- [`lib/poll.dart`](lib/poll.dart) handles invitations, voting, local event storage, and CSV export.
- [`analytics/invite_funnel.sql`](analytics/invite_funnel.sql) calculates the funnel from exported events.

Run `flutter analyze` and `flutter test` from the project directory. The tests cover repeated actions, restoring saved events, and handling a failed save.

The outfit photos were generated for the demo. Font licenses are in [`assets/fonts`](assets/fonts).
