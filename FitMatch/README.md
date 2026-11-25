# FitMatch

FitMatch is a Flutter and Dart demo that lets a friend help choose between two outfits. The event screen shows the invite funnel and provides a CSV for exploring the same events in SQL.

## Try it

1. Open **Outfit board**, choose **Invite a friend**, then select Maya Patel and send the invite.
2. Open **Friend inbox**, select Maya's invitation, and choose **Accept invite**.
3. Pick Look A or Look B and select **Submit vote**. The outfit board shows the vote.
4. Open **Event log**. You'll see one invite sent, one accepted, one vote cast, and a 100% acceptance rate for this demo session.

The outfit poll and contacts are preloaded. The same app simulates both sides of the invitation. Each browser profile or app installation has its own local event log.

## Run it

With [Flutter 3.38.7 or newer](https://docs.flutter.dev/get-started/install) and Chrome:

```sh
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

The project includes Android and iOS targets for use with the corresponding Flutter platform toolchains.

If you downloaded the demo bundle, use the included browser build from the parent directory even without the Flutter SDK:

```sh
python3 -m http.server 8080 --directory web-preview
```

Then open [localhost:8080](http://localhost:8080). To rebuild from source:

```sh
flutter build web --release --no-web-resources-cdn --base-href / --pwa-strategy none
```

## Explore the event data

| Event | Recorded when |
| --- | --- |
| `invite_sent` | The outfit owner sends the invite to a demo contact |
| `invite_accepted` | The demo contact accepts the invite |
| `outfit_voted` | The demo contact submits an outfit choice |

An invite ID connects the events for each invitation. Timestamps are stored in UTC. Acceptance rate is accepted invites divided by sent invites. The rate is blank until an invite is sent. An accepted invite and a vote are tracked separately.

In **Event log**, select **Copy CSV** and save the clipboard contents as `events.csv` in the project root. Run this with SQLite 3.32 or newer:

```sh
sqlite3 :memory: < analytics/invite_funnel.sql
```

The outfit photography was generated for this demo. DM Sans, Playfair Display, and the Roboto fallback use the SIL Open Font License. Their license files are in `assets/fonts`.
